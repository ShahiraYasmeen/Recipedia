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
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showScrollHint = false;
        });
      }
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

  final List<List<Map<String, dynamic>>> recipeData = [
    [ // Appetizer (cat 0)
      {'title': 'Salmon Toast', 'duration': '20 mins', 'difficulty': 'Easy', 'servings': '2', 'image': 'assets/App0.jpg', 'author': 'Amy Wong', 'likes': 2, 'cat': 0, 'index': 0},
      {'title': 'Cheese Bites', 'duration': '25 mins', 'difficulty': 'Medium', 'servings': '3', 'image': 'assets/App1.jpg', 'author': 'John Smith', 'likes': 3, 'cat': 0, 'index': 1},
      {'title': 'Spring Rolls', 'duration': '30 mins', 'difficulty': 'Hard', 'servings': '4', 'image': 'assets/App2.jpg', 'author': 'Lisa Chen', 'likes': 4, 'cat': 0, 'index': 2},
      {'title': 'Mini Quiche', 'duration': '35 mins', 'difficulty': 'Easy', 'servings': '5', 'image': 'assets/App3.jpg', 'author': 'Karen Lee', 'likes': 5, 'cat': 0, 'index': 3},
    ],
    [ // Main Course (cat 1)
      {'title': 'Grilled Chicken', 'duration': '20 mins', 'difficulty': 'Easy', 'servings': '2', 'image': 'assets/MC0.jpg', 'author': 'Emma Lee', 'likes': 2, 'cat': 1, 'index': 0},
      {'title': 'Chicken Curry', 'duration': '25 mins', 'difficulty': 'Medium', 'servings': '3', 'image': 'assets/MC1.jpg', 'author': 'Raj Kumar', 'likes': 3, 'cat': 1, 'index': 1},
      {'title': 'Beef Stew', 'duration': '30 mins', 'difficulty': 'Hard', 'servings': '4', 'image': 'assets/MC2.jpg', 'author': 'Ahmad Zaki', 'likes': 4, 'cat': 1, 'index': 2},
      {'title': 'Seafood Pasta', 'duration': '35 mins', 'difficulty': 'Easy', 'servings': '5', 'image': 'assets/MC3.jpg', 'author': 'Nina Wong', 'likes': 5, 'cat': 1, 'index': 3},
    ],
    [ // Dessert (cat 2)
      {'title': 'Strawberry Tart', 'duration': '20 mins', 'difficulty': 'Easy', 'servings': '2', 'image': 'assets/Dess0.jpg', 'author': 'Lina', 'likes': 2, 'cat': 2, 'index': 0},
      {'title': 'Lava Cake', 'duration': '25 mins', 'difficulty': 'Medium', 'servings': '3', 'image': 'assets/Dess1.jpg', 'author': 'Farah Lim', 'likes': 3, 'cat': 2, 'index': 1},
      {'title': 'Ice Cream Sandwich', 'duration': '30 mins', 'difficulty': 'Hard', 'servings': '4', 'image': 'assets/Dess2.jpg', 'author': 'Ken Wong', 'likes': 4, 'cat': 2, 'index': 2},
      {'title': 'Pudding Cup', 'duration': '35 mins', 'difficulty': 'Easy', 'servings': '5', 'image': 'assets/Dess3.jpg', 'author': 'Chloe Tan', 'likes': 5, 'cat': 2, 'index': 3},
    ],
    [ // Beverages (cat 3)
      {'title': 'Fruit Smoothie', 'duration': '20 mins', 'difficulty': 'Easy', 'servings': '2', 'image': 'assets/Bev0.jpg', 'author': 'Izzah Rahim', 'likes': 2, 'cat': 3, 'index': 0},
      {'title': 'Iced Latte', 'duration': '25 mins', 'difficulty': 'Medium', 'servings': '3', 'image': 'assets/Bev1.jpg', 'author': 'Jason Ong', 'likes': 3, 'cat': 3, 'index': 1},
      {'title': 'Matcha Tea', 'duration': '30 mins', 'difficulty': 'Hard', 'servings': '4', 'image': 'assets/Bev2.jpg', 'author': 'Tina Hee', 'likes': 4, 'cat': 3, 'index': 2},
      {'title': 'Lemonade', 'duration': '35 mins', 'difficulty': 'Easy', 'servings': '5', 'image': 'assets/Bev3.jpg', 'author': 'Ain Adam', 'likes': 5, 'cat': 3, 'index': 3},
    ],
    [ // Snacks (cat 4)
      {'title': 'Nachos', 'duration': '20 mins', 'difficulty': 'Easy', 'servings': '2', 'image': 'assets/Sna0.jpg', 'author': 'Sarah Chia', 'likes': 2, 'cat': 4, 'index': 0},
      {'title': 'Popcorn Mix', 'duration': '25 mins', 'difficulty': 'Medium', 'servings': '3', 'image': 'assets/Sna1.jpg', 'author': 'Adam Lim', 'likes': 3, 'cat': 4, 'index': 1},
      {'title': 'Potato Wedges', 'duration': '30 mins', 'difficulty': 'Hard', 'servings': '4', 'image': 'assets/Sna2.jpg', 'author': 'Lim Wei', 'likes': 4, 'cat': 4, 'index': 2},
      {'title': 'Granola Bars', 'duration': '35 mins', 'difficulty': 'Easy', 'servings': '5', 'image': 'assets/Sna3.jpg', 'author': 'Joanne Lee', 'likes': 5, 'cat': 4, 'index': 3},
    ],
  ];

  final Set<String> likedRecipes = {};

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
        title: const Text('Recipedia', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF8B0000),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal Category Pills with arrow hint
          Container(
            padding: const EdgeInsets.only(left: 12, top: 16, bottom: 16),
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(categories.length, (index) {
                      final isSelected = selectedCategoryIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategoryIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF8B0000) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          child: Text(
                            categories[index],
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                if (_showScrollHint)
                  Positioned(
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, const Color(0xFFFFF8F5)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Text("Recipes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

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
                      MaterialPageRoute(builder: (context) => CommunityRecipeDetailPage(recipe: recipe)),
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
