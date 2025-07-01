import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recipe_detail_page.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  final List<String> categories = [
    'All',
    'Saved',
    'Appetizer',
    'Main Course',
    'Dessert',
    'Beverages',
    'Snacks'
  ];
  final List<String> categoryCode = ['App', 'MC', 'Dess', 'Bev', 'Sna'];
  final List<List<String>> foodNames = [
    ['Salmon Toast', 'Cheese Bites', 'Spring Rolls', 'Mini Quiche'],
    ['Grilled Chicken', 'Chicken Curry', 'Beef Stew', 'Seafood Pasta'],
    ['Strawberry Tart', 'Lava Cake', 'Berry Tart', 'Cheesecake'],
    ['Mojito', 'Lemonade', 'Iced Coffee', 'Smoothie'],
    ['Nachos', 'Popcorn', 'Chips', 'Nuggets'],
  ];

  String selectedCategory = 'All';
  Set<String> savedRecipes = {};
  late String uid;

  final ScrollController _scrollController = ScrollController();
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    uid = user?.uid ?? '';
    _loadSaved();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        30,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
      Future.delayed(const Duration(seconds: 3), () {
        setState(() => _showRightArrow = false);
      });
    });
  }

  Future<void> _loadSaved() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('saved_recipes')
        .get();
    setState(() {
      savedRecipes = snap.docs.map((doc) => doc.id).toSet();
    });
  }

  Future<void> _toggleSave(String id, Map<String, dynamic> data) async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('saved_recipes')
        .doc(id);

    if (savedRecipes.contains(id)) {
      await ref.delete();
      setState(() => savedRecipes.remove(id));
    } else {
      await ref.set(data);
      setState(() => savedRecipes.add(id));
    }
  }

  List<Map<String, dynamic>> _getFilteredRecipes() {
    List<Map<String, dynamic>> result = [];

    for (int cat = 0; cat < foodNames.length; cat++) {
      for (int i = 0; i < foodNames[cat].length; i++) {
        final id = '$cat-$i';
        final title = foodNames[cat][i];
        final image = 'assets/${categoryCode[cat]}$i.jpg';

        final item = {'id': id, 'cat': cat, 'index': i, 'title': title, 'image': image};

        if (selectedCategory == 'Saved' && savedRecipes.contains(id)) {
          result.add(item);
        } else if (selectedCategory == 'All' || selectedCategory == categories[cat + 2]) {
          result.add(item);
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final recipes = _getFilteredRecipes();

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
            child: Text(
              "Popular Category",
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF8B0000),
              ),
            ),
          ),
          const SizedBox(height: 5),
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
                    final cat = categories[index];
                    final isSelected = cat == selectedCategory;

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedCategory = cat),
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
                              cat == 'Saved' ? 'Saved' : cat,
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
              if (_showRightArrow)
                Positioned(
                  right: 5,
                  top: 5,
                  bottom: 5,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _showRightArrow ? 1.0 : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios, 
                        size: 16, 
                        color: Color(0xFF8B0000),),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Recipes',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: recipes.isEmpty
                ? const Center(child: Text('No recipes found.'))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 270,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (context, i) {
                      final r = recipes[i];
                      final isSaved = savedRecipes.contains(r['id']);

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.grey, blurRadius: 15, offset: Offset(1, 1)),
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                onPressed: () => _toggleSave(r['id'], {
                                  'title': r['title'],
                                  'cat': r['cat'],
                                  'index': r['index'],
                                }),
                                icon: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, anim) =>
                                      ScaleTransition(scale: anim, child: child),
                                  child: Icon(
                                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                                    key: ValueKey<bool>(isSaved),
                                    color: isSaved ? const Color(0xFF8B0000) : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Container(
                                height: 120,
                                width: 129,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: AssetImage(r['image']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RecipeDetailPage(
                                      title: r['title'],
                                      imagePath: r['image'],
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                r['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  
                                ),
                              ),
                            ),
                          ],
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
