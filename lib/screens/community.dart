import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'community_recipe_detail_page.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int selectedCategoryIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollHint = true;
  List<Map<String, dynamic>> publicRecipes = [];
  final Set<String> likedRecipes = {};

  final List<String> categories = [
    'All',
    'Appetizer',
    'Main Course',
    'Dessert',
    'Beverage',
    'Snacks',
  ];

  @override
  void initState() {
    super.initState();
    fetchPublicRecipes();
    fetchLikedRecipes();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(30,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showScrollHint = false);
      });
    });
  }

  Future<void> fetchPublicRecipes() async {
    final snap = await FirebaseFirestore.instance
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      publicRecipes = snap.docs.map((doc) {
        final data = doc.data();
        if (data['isPrivate'] == false || !data.containsKey('isPrivate')) {
          data['id'] = doc.id;
          return data;
        }
        return null;
      }).whereType<Map<String, dynamic>>().toList();
    });
  }

  Future<void> fetchLikedRecipes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('liked_recipes')
          .get();

      setState(() {
        likedRecipes.clear();
        likedRecipes.addAll(snap.docs.map((doc) => doc.id));
      });
    }
  }

  List<Map<String, dynamic>> getFilteredRecipes() {
    return selectedCategoryIndex == 0
        ? publicRecipes
        : publicRecipes
            .where((r) => r['category'] == categories[selectedCategoryIndex])
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = getFilteredRecipes();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipedia'),
        centerTitle: true,
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Share with others",
                style: TextStyle(fontSize: 20, color: Color(0xFF8B0000))),
          ),
          Stack(
            children: [
              SizedBox(
                height: 50,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedCategoryIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => selectedCategoryIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF8B0000)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isSelected
                                ? [
                                    const BoxShadow(
                                      color: Color(0xFF8B0000),
                                      blurRadius: 7,
                                      offset: Offset(1, 1),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_showScrollHint)
                Positioned(
                  right: 5,
                  top: 5,
                  bottom: 5,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _showScrollHint ? 1.0 : 0.0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.black54),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Recipes', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final r = recipes[index];
                final recipeId = r['id'];
                final isLiked = likedRecipes.contains(recipeId);
                final imageUrl = r['imageUrl'];

                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommunityRecipeDetailPage(
                          recipe: r,
                          ingredients: List<String>.from(
                            (r['ingredients'] as List<dynamic>? ?? []).map((i) {
                              if (i is String) return i;
                              if (i is Map) {
                                return '${i['amount']} ${i['unit']} ${i['name']}';
                              }
                              return i.toString();
                            }),
                          ),
                          steps: List<String>.from(r['steps'] ?? []),
                        ),
                      ),
                    );

                    if (result == 'refresh') fetchPublicRecipes();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: (imageUrl != null &&
                                  imageUrl.toString().startsWith('http'))
                              ? Image.network(imageUrl,
                                  width: 100, height: 100, fit: BoxFit.cover)
                              : Image.asset('assets/default_image.png',
                                  width: 100, height: 100),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r['title'] ?? 'Untitled',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(r['author'] ?? 'Unknown',
                                  style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                '${r['duration'] ?? '-'} • Difficulty: ${r['difficulty'] ?? 1} • ${r['servings'] ?? '-'} servings',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey,
                              ),
                              onPressed: () async {
                                final user =
                                    FirebaseAuth.instance.currentUser;
                                if (user == null) return;

                                final docRef = FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('liked_recipes')
                                    .doc(recipeId);

                                setState(() {
                                  if (isLiked) {
                                    likedRecipes.remove(recipeId);
                                    r['likes'] = (r['likes'] ?? 1) - 1;
                                  } else {
                                    likedRecipes.add(recipeId);
                                    r['likes'] = (r['likes'] ?? 0) + 1;
                                  }
                                });

                                try {
                                  final recipeRef = FirebaseFirestore.instance
                                      .collection('recipes')
                                      .doc(recipeId);

                                  if (!isLiked) {
                                    await docRef.set({
                                      'title': r['title'],
                                      'author': r['author'],
                                      'imageUrl': r['imageUrl'] ?? '',
                                      'image': r['image'] ?? '',
                                      'duration': r['duration'] ?? '',
                                      'difficulty': r['difficulty'] ?? 1,
                                      'servings': r['servings'] ?? '',
                                      'ingredients': r['ingredients'] ?? [],
                                      'steps': r['steps'] ?? [],
                                      'category': r['category'] ?? '',
                                      'createdAt': r['createdAt'],
                                      'userId': r['userId'] ?? '',
                                    });
                                    await recipeRef.update({
                                      'likes': FieldValue.increment(1),
                                    });
                                  } else {
                                    await docRef.delete();
                                    await recipeRef.update({
                                      'likes': FieldValue.increment(-1),
                                    });
                                  }
                                } catch (e) {
                                  print('Like update error: $e');
                                }
                              },
                            ),
                            Text('${r['likes'] ?? 0}',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
