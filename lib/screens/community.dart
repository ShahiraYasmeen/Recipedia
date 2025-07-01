import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        30,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showScrollHint = false;
          });
        }
      });
    });
  }

  final List<String> categories = [
    'All',
    'Appetizer',
    'Main Course',
    'Dessert',
    'Beverages',
    'Snacks'
  ];

  final Set<String> likedRecipes = {};

  final List<List<Map<String, dynamic>>> recipeData = [
    [ // Appetizer
      {'title': 'Salmon Toast', 'duration': '20 mins', 'difficulty': 'Easy', 'servings': '2', 'image': 'assets/App0.jpg', 'author': 'Amy Wong', 'likes': 2},
      {'title': 'Cheese Bites', 'duration': '25 mins', 'difficulty': 'Medium', 'servings': '3', 'image': 'assets/App1.jpg', 'author': 'John Smith', 'likes': 3},
      {'title': 'Spring Rolls', 'duration': '30 mins', 'difficulty': 'Hard', 'servings': '4', 'image': 'assets/App2.jpg', 'author': 'Lisa Chen', 'likes': 4},
      {'title': 'Mini Quiche', 'duration': '35 mins', 'difficulty': 'Easy', 'servings': '5', 'image': 'assets/App3.jpg', 'author': 'Karen Lee', 'likes': 5},
    ],
    [ // Main Course
      {'title': 'Grilled Chicken', 'duration': '20 mins', 'difficulty': 'Easy', 'servings': '2', 'image': 'assets/MC0.jpg', 'author': 'Emma Lee', 'likes': 2},
      {'title': 'Chicken Curry', 'duration': '25 mins', 'difficulty': 'Medium', 'servings': '3', 'image': 'assets/MC1.jpg', 'author': 'Raj Kumar', 'likes': 3},
      {'title': 'Beef Stew', 'duration': '30 mins', 'difficulty': 'Hard', 'servings': '4', 'image': 'assets/MC2.jpg', 'author': 'Ahmad Zaki', 'likes': 4},
      {'title': 'Seafood Pasta', 'duration': '35 mins', 'difficulty': 'Easy', 'servings': '5', 'image': 'assets/MC3.jpg', 'author': 'Nina Wong', 'likes': 5},
    ],
    [ // Dessert
      {'title': 'Strawberry Tart', 'duration': '20 mins', 'difficulty': 'Easy', 'servings': '2', 'image': 'assets/Dess0.jpg', 'author': 'Lina', 'likes': 2},
      {'title': 'Lava Cake', 'duration': '25 mins', 'difficulty': 'Medium', 'servings': '3', 'image': 'assets/Dess1.jpg', 'author': 'Farah Lim', 'likes': 3},
      {'title': 'Ice Cream Sandwich', 'duration': '30 mins', 'difficulty': 'Hard', 'servings': '4', 'image': 'assets/Dess2.jpg', 'author': 'Ken Wong', 'likes': 4},
      {'title': 'Pudding Cup', 'duration': '35 mins', 'difficulty': 'Easy', 'servings': '5', 'image': 'assets/Dess3.jpg', 'author': 'Chloe Tan', 'likes': 5},
    ],
    [ // Beverages
      {'title': 'Fruit Smoothie', 'duration': '20 mins', 'difficulty': 'Easy', 'servings': '2', 'image': 'assets/Bev0.jpg', 'author': 'Izzah Rahim', 'likes': 2},
      {'title': 'Iced Latte', 'duration': '25 mins', 'difficulty': 'Medium', 'servings': '3', 'image': 'assets/Bev1.jpg', 'author': 'Jason Ong', 'likes': 3},
      {'title': 'Matcha Tea', 'duration': '30 mins', 'difficulty': 'Hard', 'servings': '4', 'image': 'assets/Bev2.jpg', 'author': 'Tina Hee', 'likes': 4},
      {'title': 'Lemonade', 'duration': '35 mins', 'difficulty': 'Easy', 'servings': '5', 'image': 'assets/Bev3.jpg', 'author': 'Ain Adam', 'likes': 5},
    ],
    [ // Snacks
      {'title': 'Nachos', 'duration': '20 mins', 'difficulty': 'Easy', 'servings': '2', 'image': 'assets/Sna0.jpg', 'author': 'Sarah Chia', 'likes': 2},
      {'title': 'Popcorn Mix', 'duration': '25 mins', 'difficulty': 'Medium', 'servings': '3', 'image': 'assets/Sna1.jpg', 'author': 'Adam Lim', 'likes': 3},
      {'title': 'Potato Wedges', 'duration': '30 mins', 'difficulty': 'Hard', 'servings': '4', 'image': 'assets/Sna2.jpg', 'author': 'Lim Wei', 'likes': 4},
      {'title': 'Granola Bars', 'duration': '35 mins', 'difficulty': 'Easy', 'servings': '5', 'image': 'assets/Sna3.jpg', 'author': 'Joanne Lee', 'likes': 5},
    ],
  ];

  List<Map<String, dynamic>> getFilteredRecipes() {
    if (selectedCategoryIndex == 0) {
      return recipeData.expand((list) => list).toList(); // All
    } else {
      return recipeData[selectedCategoryIndex - 1];
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipes = getFilteredRecipes();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      appBar: AppBar(
        title: const Text(
          'Recipedia',
          style: TextStyle(
            fontWeight: FontWeight.normal, // Not bold
            color: Colors.white,
          ),
        ),
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
                                fontWeight: FontWeight.normal, // Not bold
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
                      child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Recipes',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                final recipeKey = recipe['title'];
                recipe['likes'] ??= 0;
                final isLiked = likedRecipes.contains(recipeKey);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommunityRecipeDetailPage(recipe: recipe)),
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
                          child: Image.asset(recipe['image'], width: 100, height: 100, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(recipe['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(recipe['author'], style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                '${recipe['duration']} • ${recipe['difficulty']} • ${recipe['servings']} servings',
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
                                    likedRecipes.remove(recipeKey);
                                    recipe['likes'] = (recipe['likes'] ?? 1) - 1;
                                  } else {
                                    likedRecipes.add(recipeKey);
                                    recipe['likes'] = (recipe['likes'] ?? 0) + 1;
                                  }
                                });
                              },
                            ),
                            Text('${recipe['likes']}', style: const TextStyle(fontSize: 12)),
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
