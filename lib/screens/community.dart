import 'package:flutter/material.dart';
import 'community_recipe_detail_page.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int selectedCategoryIndex = 0;

  final List<String> categories = ['Appetizer', 'Main Course', 'Dessert', 'Beverages', 'Snacks'];

  final List<List<Map<String, dynamic>>> recipeData = [
    [ // Appetizer
      {'title': 'Salmon Toast', 'duration': '30 mins', 'difficulty': 'Easy', 'servings': '8', 'image': 'assets/App0.jpg', 'author': 'Amy Wong'},
      {'title': 'Cheese Bites', 'duration': '25 mins', 'difficulty': 'Easy', 'servings': '8', 'image': 'assets/App1.jpg', 'author': 'John Smith'},
      {'title': 'Spring Rolls', 'duration': '40 mins', 'difficulty': 'Medium', 'servings': '6', 'image': 'assets/App2.jpg', 'author': 'Lisa Chen'},
      {'title': 'Mini Quiche', 'duration': '35 mins', 'difficulty': 'Medium', 'servings': '6', 'image': 'assets/App3.jpg', 'author': 'Kevin Tan'},
    ],
    [ // Main Course
      {'title': 'Grilled Chicken', 'duration': '50 mins', 'difficulty': 'Hard', 'servings': '4', 'image': 'assets/MC0.jpg', 'author': 'Emma Lee'},
      {'title': 'Chicken Curry', 'duration': '45 mins', 'difficulty': 'Medium', 'servings': '5', 'image': 'assets/MC1.jpg', 'author': 'Raj Kumar'},
      {'title': 'Beef Stew', 'duration': '60 mins', 'difficulty': 'Hard', 'servings': '6', 'image': 'assets/MC2.jpg', 'author': 'Ahmad Zaki'},
      {'title': 'Seafood Pasta', 'duration': '40 mins', 'difficulty': 'Medium', 'servings': '4', 'image': 'assets/MC3.jpg', 'author': 'Nina Wong'},
    ],
    [ // Dessert
      {'title': 'Strawberry Tart', 'duration': '30 mins', 'difficulty': 'Easy', 'servings': '6', 'image': 'assets/Dess0.jpg', 'author': 'Lina'},
      {'title': 'Lava Cake', 'duration': '25 mins', 'difficulty': 'Medium', 'servings': '4', 'image': 'assets/Dess1.jpg', 'author': 'Ravi'},
      {'title': 'Berry Tart', 'duration': '35 mins', 'difficulty': 'Easy', 'servings': '5', 'image': 'assets/Dess2.jpg', 'author': 'Cindy'},
      {'title': 'Cheesecake', 'duration': '45 mins', 'difficulty': 'Medium', 'servings': '6', 'image': 'assets/Dess3.jpg', 'author': 'James'},
    ],
    [ // Beverages
      {'title': 'Mojito', 'duration': '10 mins', 'difficulty': 'Easy', 'servings': '2', 'image': 'assets/Bev0.jpg', 'author': 'Ali'},
      {'title': 'Lemonade', 'duration': '8 mins', 'difficulty': 'Easy', 'servings': '3', 'image': 'assets/Bev1.jpg', 'author': 'Aisha'},
      {'title': 'Iced Coffee', 'duration': '5 mins', 'difficulty': 'Easy', 'servings': '1', 'image': 'assets/Bev2.jpg', 'author': 'Ben'},
      {'title': 'Smoothie', 'duration': '7 mins', 'difficulty': 'Easy', 'servings': '2', 'image': 'assets/Bev3.jpg', 'author': 'Maya'},
    ],
    [ // Snacks
      {'title': 'Nachos', 'duration': '15 mins', 'difficulty': 'Easy', 'servings': '4', 'image': 'assets/Sna0.jpg', 'author': 'Jake'},
      {'title': 'Popcorn', 'duration': '5 mins', 'difficulty': 'Easy', 'servings': '2', 'image': 'assets/Sna1.jpg', 'author': 'Sam'},
      {'title': 'Chips', 'duration': '10 mins', 'difficulty': 'Easy', 'servings': '3', 'image': 'assets/Sna2.jpg', 'author': 'Kim'},
      {'title': 'Nuggets', 'duration': '12 mins', 'difficulty': 'Easy', 'servings': '4', 'image': 'assets/Sna3.jpg', 'author': 'Chris'},
    ],
  ];

  final Set<String> savedRecipes = {};

  @override
  Widget build(BuildContext context) {
    final currentRecipes = recipeData[selectedCategoryIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipedia',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // ✅ updated text color
          ),
        ),
        backgroundColor: const Color(0xFF8B0000),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 50,
            margin: const EdgeInsets.only(top: 10, left: 15),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedCategoryIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => selectedCategoryIndex = index);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isSelected ? const Color(0xFF8B0000) : Colors.transparent,
                        boxShadow: isSelected
                            ? [const BoxShadow(color: Color(0xFF8B0000), blurRadius: 7, offset: Offset(1, 1))]
                            : [],
                      ),
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.white : Colors.black,
                          fontFamily: 'roboto',
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Recipes Title
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(left: 15, top: 15),
            child: const Text('Recipes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'roboto')),
          ),

          // Recipe List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: currentRecipes.length,
              itemBuilder: (context, index) {
                final recipe = currentRecipes[index];
                final isSaved = savedRecipes.contains(recipe['title']);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommunityRecipeDetailPage(recipe: recipe),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 15, offset: Offset(1, 1))],
                    ),
                    child: Row(
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                          child: Image.asset(
                            recipe['image'],
                            height: 140,
                            width: 130,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Details
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isSaved
                                            ? savedRecipes.remove(recipe['title'])
                                            : savedRecipes.add(recipe['title']);
                                      });
                                    },
                                    child: Icon(
                                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                                      color: const Color(0xFF8B0000),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(recipe['title'],
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 5),
                                      Text(recipe['author'], style: const TextStyle(color: Colors.grey)),
                                      const SizedBox(height: 10),
                                      Text(
                                        '${recipe['duration']} • ${recipe['difficulty']} • ${recipe['servings']} servings',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
