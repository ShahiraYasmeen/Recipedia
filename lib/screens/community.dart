import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      {'title': 'Salmon Toast', 'duration': '20 mins', 'difficulty': 'Easy', 'servings': '2', 'image': 'assets/App0.jpg', 'author': 'Amy Wong', 'likes': 2},
      {'title': 'Cheese Bites', 'duration': '25 mins', 'difficulty': 'Medium', 'servings': '3', 'image': 'assets/App1.jpg', 'author': 'John Smith', 'likes': 3},
      {'title': 'Spring Rolls', 'duration': '30 mins', 'difficulty': 'Hard', 'servings': '4', 'image': 'assets/App2.jpg', 'author': 'Lisa Chen', 'likes': 4},
      {'title': 'Mini Quiche', 'duration': '35 mins', 'difficulty': 'Easy', 'servings': '5', 'image': 'assets/App3.jpg', 'author': 'Karen Lee', 'likes': 5},
    ],
    [
      {'title': 'Grilled Chicken', 'duration': '20 mins', 'difficulty': 'Easy', 'servings': '2', 'image': 'assets/MC0.jpg', 'author': 'Emma Lee', 'likes': 2},
      {'title': 'Chicken Curry', 'duration': '25 mins', 'difficulty': 'Medium', 'servings': '3', 'image': 'assets/MC1.jpg', 'author': 'Raj Kumar', 'likes': 3},
      {'title': 'Beef Stew', 'duration': '30 mins', 'difficulty': 'Hard', 'servings': '4', 'image': 'assets/MC2.jpg', 'author': 'Ahmad Zaki', 'likes': 4},
      {'title': 'Seafood Pasta', 'duration': '35 mins', 'difficulty': 'Easy', 'servings': '5', 'image': 'assets/MC3.jpg', 'author': 'Nina Wong', 'likes': 5},
    ],
    [
      {'title': 'Strawberry Tart', 'duration': '20 mins', 'difficulty': 'Easy', 'servings': '2', 'image': 'assets/Dess0.jpg', 'author': 'Lina', 'likes': 2},
      {'title': 'Lava Cake', 'duration': '25 mins', 'difficulty': 'Medium', 'servings': '3', 'image': 'assets/Dess1.jpg', 'author': 'Farah Lim', 'likes': 3},
      {'title': 'Ice Cream Sandwich', 'duration': '30 mins', 'difficulty': 'Hard', 'servings': '4', 'image': 'assets/Dess2.jpg', 'author': 'Ken Wong', 'likes': 4},
      {'title': 'Pudding Cup', 'duration': '35 mins', 'difficulty': 'Easy', 'servings': '5', 'image': 'assets/Dess3.jpg', 'author': 'Chloe Tan', 'likes': 5},
    ],
    [
      {'title': 'Fruit Smoothie', 'duration': '20 mins', 'difficulty': 'Easy', 'servings': '2', 'image': 'assets/Bev0.jpg', 'author': 'Izzah Rahim', 'likes': 2},
      {'title': 'Iced Latte', 'duration': '25 mins', 'difficulty': 'Medium', 'servings': '3', 'image': 'assets/Bev1.jpg', 'author': 'Jason Ong', 'likes': 3},
      {'title': 'Matcha Tea', 'duration': '30 mins', 'difficulty': 'Hard', 'servings': '4', 'image': 'assets/Bev2.jpg', 'author': 'Tina Hee', 'likes': 4},
      {'title': 'Lemonade', 'duration': '35 mins', 'difficulty': 'Easy', 'servings': '5', 'image': 'assets/Bev3.jpg', 'author': 'Ain Adam', 'likes': 5},
    ],
    [
      {'title': 'Nachos', 'duration': '20 mins', 'difficulty': 'Easy', 'servings': '2', 'image': 'assets/Sna0.jpg', 'author': 'Sarah Chia', 'likes': 2},
      {'title': 'Popcorn Mix', 'duration': '25 mins', 'difficulty': 'Medium', 'servings': '3', 'image': 'assets/Sna1.jpg', 'author': 'Adam Lim', 'likes': 3},
      {'title': 'Potato Wedges', 'duration': '30 mins', 'difficulty': 'Hard', 'servings': '4', 'image': 'assets/Sna2.jpg', 'author': 'Lim Wei', 'likes': 4},
      {'title': 'Granola Bars', 'duration': '35 mins', 'difficulty': 'Easy', 'servings': '5', 'image': 'assets/Sna3.jpg', 'author': 'Joanne Lee', 'likes': 5},
    ],
  ];

  @override
  void initState() {
    super.initState();
    fetchPublicRecipes();
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
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final r = recipes[index];
                final isLiked = likedRecipes.contains(r['id'] ?? r['title']);
                final isBase64 = r['image']?.toString().startsWith('data:image') ?? false;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CommunityRecipeDetailPage(recipe: r)),
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
                                  r['image'],
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
                              Text(r['title'],
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(r['author'] ?? '-', style: const TextStyle(color: Colors.grey)),
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
                              onPressed: () {
                                setState(() {
                                  if (isLiked) {
                                    likedRecipes.remove(r['id'] ?? r['title']);
                                    r['likes'] = (r['likes'] ?? 1) - 1;
                                  } else {
                                    likedRecipes.add(r['id'] ?? r['title']);
                                    r['likes'] = (r['likes'] ?? 0) + 1;
                                  }
                                });
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
