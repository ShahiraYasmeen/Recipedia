import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'community_recipe_detail_page.dart';
import 'community_recipe_data.dart';


class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int selectedCategoryIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollHint = true;
  final Set<String> likedRecipes = {};
  List<Map<String, dynamic>> publicUploaded = [];

  final List<String> categories = [
    'All',
    'Appetizer',
    'Main Course',
    'Dessert',
    'Beverages',
    'Snacks'
  ];

  final List<List<Map<String, dynamic>>> recipeData = [
    [
      {'title': 'Bruschetta', 'duration': '15 mins', 'difficulty': 'Easy', 'servings': '4', 'image': 'assets/CommApp0.jpeg', 'author': 'Luca Romano', 'likes': 5},
      {'title': 'Stuffed Mushrooms', 'duration': '25 mins', 'difficulty': 'Medium', 'servings': '6', 'image': 'assets/CommApp1.jpg', 'author': 'Clara Smith', 'likes': 3},
    ],
    [
      {'title': 'Spaghetti Carbonara', 'duration': '30 mins', 'difficulty': 'Medium', 'servings': '2', 'image': 'assets/CommMC0.jpeg', 'author': 'Marco Bellini', 'likes': 8},
      {'title': 'Grilled Chicken Rice Bowl', 'duration': '40 mins', 'difficulty': 'Hard', 'servings': '3', 'image': 'assets/CommMC1.jpg', 'author': 'Siti Aisyah', 'likes': 6},
    ],
    [
      {'title': 'Marshmallow Nougat', 'duration': '25 mins', 'difficulty': 'Easy', 'servings': '4', 'image': 'assets/CommDessert0.jpg', 'author': 'Noah James', 'likes': 9},
      {'title': 'Mango Pudding', 'duration': '20 mins', 'difficulty': 'Easy', 'servings': '4', 'image': 'assets/CommDessert1.jpg', 'author': 'Mei Lin', 'likes': 4},
    ],
    [
      {'title': 'Iced Matcha Latte', 'duration': '10 mins', 'difficulty': 'Easy', 'servings': '1', 'image': 'assets/CommBev0.jpeg', 'author': 'Hana Suzuki', 'likes': 7},
      {'title': 'Cha Ba Ang', 'duration': '15 mins', 'difficulty': 'Medium', 'servings': '2', 'image': 'assets/CommBev1.jpg', 'author': 'John Lee', 'likes': 5},
    ],
    [
      {'title': 'French Toast Bites', 'duration': '20 mins', 'difficulty': 'Easy', 'servings': '4', 'image': 'assets/CommSnacks0.jpg', 'author': 'Tommy Lee', 'likes': 6},
      {'title': 'Potato Pancakes', 'duration': '25 mins', 'difficulty': 'Medium', 'servings': '3', 'image': 'assets/CommSnacks1.jpg', 'author': 'Nur Alia', 'likes': 3},
    ],
  ];

  @override
  void initState() {
    super.initState();
    fetchPublicRecipes();
    fetchLikedRecipes();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        30,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _showScrollHint = false);
        }
      });
    });
  }

  Future<void> fetchPublicRecipes() async {
    final snap = await FirebaseFirestore.instance
        .collection('recipes')
        .where('isPrivate', isEqualTo: false)
        .get();

    setState(() {
      publicUploaded = snap.docs.map((doc) {
        final d = doc.data();
        d['id'] = doc.id;
        return d;
      }).toList();
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
    final base = selectedCategoryIndex == 0
        ? recipeData.expand((e) => e).toList()
        : recipeData[selectedCategoryIndex - 1];

    final public = publicUploaded.where((r) {
      if (selectedCategoryIndex == 0) return true;
      return r['category'] == categories[selectedCategoryIndex];
    });

    return [...base, ...public];
  }

  @override
  Widget build(BuildContext context) {
    final recipes = getFilteredRecipes();
    final List<Map<String, dynamic>> displayedRecipes;

    if (selectedCategoryIndex == 0) {
  // All: show all communityRecipes + all recipes
  displayedRecipes = [
    ...communityRecipes,
    ...recipes,
  ];
} else {
  // Filter communityRecipes by category
  final category = categories[selectedCategoryIndex];
  final communityByCategory = communityRecipes
      .where((r) => (r['category'] ?? '') == category)
      .toList();
  // Filter recipes by category (if needed)
  final recipesByCategory = recipes
      .where((r) => (r['category'] ?? '') == category)
      .toList();
  displayedRecipes = [
    ...communityByCategory,
    ...recipesByCategory,
  ];
}

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      appBar: AppBar(
        title: const Text('Recipedia', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8B0000),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
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
                        onTap: () => setState(() => selectedCategoryIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF8B0000) : Colors.transparent,
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
                                fontWeight: FontWeight.normal,
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
                      decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Recipes', style: TextStyle(fontSize: 20, color: Colors.black)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: displayedRecipes.length,
              itemBuilder: (context, index) {
                final r = displayedRecipes[index];

                if (r['image'] == null || r['image'].toString().isEmpty ||
                    r['title'] == null || r['title'].toString().isEmpty) {
                  return const SizedBox.shrink(); // Skip invalid entries
                }
                final isLiked = likedRecipes.contains(r['id'] ?? r['title']);
                final isBase64 = r['image']?.toString().startsWith('data:image') ?? false;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CommunityRecipeDetailPage(
                            recipe: r,
                            ingredients: List<String>.from(r['ingredients'] ?? []),
                            steps: List<String>.from(r['steps'] ?? []),
                          ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: isBase64
                              ? Image.memory(
                                  base64Decode(r['image'].split(',').last),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  r['image'] ?? 'assets/default_image.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r['title'] ?? 'Untitled',
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(r['author'] ?? 'Unknown', style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                '${r['duration']} • ${r['difficulty']} • ${r['servings']} servings',
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey,
                              ),
                              onPressed: () async {
                                final currentUser = FirebaseAuth.instance.currentUser;
                                if (currentUser == null) return;

                                final recipeId = r['id'] ?? r['title'];
                                final docRef = FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUser.uid)
                                    .collection('liked_recipes')
                                    .doc(recipeId);

                                setState(() {
                                  if (likedRecipes.contains(recipeId)) {
                                    likedRecipes.remove(recipeId);
                                    r['likes'] = (r['likes'] ?? 1) - 1;
                                  } else {
                                    likedRecipes.add(recipeId);
                                    r['likes'] = (r['likes'] ?? 0) + 1;
                                  }
                                });

                                try {
                                  final recipeRef = FirebaseFirestore.instance.collection('recipes').doc(r['id']);

                                  if (likedRecipes.contains(recipeId)) {
                                    // Save to liked_recipes and increment likes
                                    await docRef.set({
                                      'title': r['title'],
                                      'author': r['author'],
                                      'image': r['image'],
                                      'duration': r['duration'],
                                      'difficulty': r['difficulty'],
                                      'servings': r['servings'],
                                      'ingredients': List<String>.from(r['ingredients'] ?? []),
                                      'steps': List<String>.from(r['steps'] ?? []),
                                      'likedAt': FieldValue.serverTimestamp(),
                                    });
                                    if (r['id'] != null) {
                                      await recipeRef.update({'likes': FieldValue.increment(1)});
                                    }
                                  } else {
                                    // Remove from liked_recipes and decrement likes
                                    await docRef.delete();
                                    if (r['id'] != null) {
                                      await recipeRef.update({'likes': FieldValue.increment(-1)});
                                    }
                                  }
                                } catch (e) {
                                  print('Error updating like status: $e');
                                }
                              },
                              ),
                            Text('${r['likes'] ?? 0}', style: const TextStyle(fontSize: 12)),
                          ],
                        )
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
