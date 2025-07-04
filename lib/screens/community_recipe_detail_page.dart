import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class CommunityRecipeDetailPage extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final List<String> ingredients;
  final List<String> steps;

  const CommunityRecipeDetailPage({
    super.key,
    required this.recipe,
    required this.ingredients,
    required this.steps,
  });

  @override
  State<CommunityRecipeDetailPage> createState() =>
      _CommunityRecipeDetailPageState();
}

class _CommunityRecipeDetailPageState
    extends State<CommunityRecipeDetailPage> {
  bool isSaved = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    if (userId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('saved_recipes')
          .doc(widget.recipe['title'])
          .get();
      setState(() {
        isSaved = doc.exists;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final List<String> ingredients = List<String>.from(recipe['ingredients'] ?? []);
    final List<String> steps = List<String>.from(recipe['steps'] ?? []) ;


    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe Detail',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8B0000),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image with save button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: Image.asset(
                    recipe['image'] ?? 'assets/placeholder.jpg',
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 100),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: const Color(0xFF8B0000),
                          ),
                          onPressed: () async {
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            final docRef = FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .collection('saved_recipes')
                                .doc(widget.recipe['title']); // unique id

                            final doc = await docRef.get();

                            if (doc.exists) {
                              await docRef.delete();
                              setState(() => isSaved = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Recipe unsaved'), duration: Duration(seconds: 2)),
                              );
                            } else {
                              await docRef.set({
                                'title': widget.recipe['title'],
                                'image': widget.recipe['image'],
                                'author': widget.recipe['author'],
                                'duration': widget.recipe['duration'],
                                'difficulty': widget.recipe['difficulty'],
                                'servings': widget.recipe['servings'],
                                'ingredients': List<String>.from(widget.recipe['ingredients'] ?? []),
                                'steps': List<String>.from(widget.recipe['steps'] ?? []),
                                'category': widget.recipe['category'] ?? 'Main Course',
                              });
                              setState(() => isSaved = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Recipe saved'), duration: Duration(seconds: 2)),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Details
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['title'] ?? '',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text("By ${recipe['author'] ?? 'Unknown'}"),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(recipe['duration'] ?? ''),
                      const SizedBox(width: 16),
                      const Icon(Icons.local_fire_department, size: 16),
                      const SizedBox(width: 4),
                      Text(recipe['difficulty'] ?? ''),
                      const SizedBox(width: 16),
                      const Icon(Icons.people, size: 16),
                      const SizedBox(width: 4),
                      Text('${recipe['servings']} servings'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ingredients',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...ingredients.map((item) => Text('- $item')),

                  const SizedBox(height: 20),
                  const Text(
                    'Steps',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...steps.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('${entry.key + 1}. ${entry.value}'),
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
