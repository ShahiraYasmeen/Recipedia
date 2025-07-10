import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'community_recipe_detail_page.dart';

class LikedRecipeScreen extends StatefulWidget {
  const LikedRecipeScreen({super.key});

  @override
  State<LikedRecipeScreen> createState() => _LikedRecipeScreenState();
}

class _LikedRecipeScreenState extends State<LikedRecipeScreen> {
  List<Map<String, dynamic>> likedRecipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLikedRecipes();
  }

  Future<void> _fetchLikedRecipes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('liked_recipes')
          .get();

      setState(() {
        likedRecipes = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liked Recipes", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8B0000),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : likedRecipes.isEmpty
              ? const Center(child: Text("No liked recipes yet."))
              : ListView.builder(
                  itemCount: likedRecipes.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final recipe = likedRecipes[index];

                    final ingredients = (recipe['ingredients'] as List<dynamic>? ?? []).map((i) {
                      if (i is String) return i;
                      if (i is Map) return '${i['amount']} ${i['unit']} ${i['name']}';
                      return i.toString();
                    }).toList();

                    final steps = (recipe['steps'] as List<dynamic>? ?? []).map((s) => s.toString()).toList();

                    final imageUrl = recipe['imageUrl']?.toString() ?? recipe['image']?.toString() ?? '';
                    final isNetworkImage = imageUrl.startsWith('http');

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommunityRecipeDetailPage(
                              recipe: recipe,
                              ingredients: ingredients,
                              steps: steps,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: isNetworkImage
                                    ? Image.network(
                                        imageUrl,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                                      )
                                    : const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe['title'] ?? '',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      recipe['author'] ?? '',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${recipe['duration'] ?? '-'} • Difficulty: ${recipe['difficulty'] ?? '-'} • ${recipe['servings'] ?? '-'} servings',
                                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
