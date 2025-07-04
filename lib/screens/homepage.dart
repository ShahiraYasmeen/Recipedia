
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recipe_detail_page.dart';
import 'recipe_data.dart';
import 'community_recipe_detail_page.dart';

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

  List<Map<String, dynamic>> firebaseRecipes = [];
  List<Map<String, dynamic>> savedRecipesData = [];
  List<Map<String, dynamic>> savedCommunityRecipes = [];

  Future<List<Map<String, dynamic>>> fetchSavedCommunityRecipes() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('saved_recipes')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'title': data['title'],
        'image': data['image'],
        'cat': 'Saved',
        'ingredients': data['ingredients'] ?? [],
        'steps': data['steps'] ?? [],
      };
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    uid = user?.uid ?? '';
    _loadSaved();
    _loadFirebaseRecipes();
    _loadSavedCommunity();

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

  void _loadSavedCommunity() async {
    final saved = await fetchSavedCommunityRecipes();
    setState(() {
      savedCommunityRecipes = saved;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('saved_recipes')
        .get();
    setState(() {
      savedRecipes = snap.docs.map((doc) => doc.id).toSet();
      savedRecipesData = snap.docs.map((doc) => doc.data()).toList();
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

  Future<void> _loadFirebaseRecipes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      firebaseRecipes = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'cat': data['category'] ?? '',
          'index': data['index'] ?? 0,
          'ingredients': data['ingredients'] ?? [],
          'steps': data['steps'] ?? [],
          'isPrivate': data['isPrivate'] ?? true,
          'createdAt': data['createdAt'],
        };
      }).toList();
    });
  }

  List<Map<String, dynamic>> _getFilteredRecipes() {
    List<Map<String, dynamic>> result = [];

    if (selectedCategory == 'Saved') {
      result.addAll(savedCommunityRecipes);
    }

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

    for (final recipe in firebaseRecipes) {
      // ignore: unused_local_variable
      final isPrivate = recipe['isPrivate'] == true;
      final isSaved = savedRecipes.contains(recipe['id']);

      if (selectedCategory == 'Saved') {
        if (isSaved) {
          result.add(recipe);
        }
      } else {
        if (selectedCategory == 'All' || recipe['cat'] == selectedCategory) {
          result.add(recipe);
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
            child: Text("Popular Category", style: TextStyle(fontSize: 20, color: Color(0xFF8B0000))),
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
                                ? [const BoxShadow(color: Color(0xFF8B0000), blurRadius: 7, offset: Offset(1, 1))]
                                : [],
                          ),
                          child: Center(
                            child: Text(cat,
                                style: TextStyle(fontSize: 16, color: isSelected ? Colors.white : Colors.black)),
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
                      decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF8B0000)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Recipes', style: TextStyle(fontSize: 20, color: Colors.black)),
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

                      final imageWidget = r['imageUrl'] != null && r['imageUrl'] != ''
                          ? Image.network(r['imageUrl'], fit: BoxFit.cover)
                          : Image.asset(r['image'] ?? 'assets/placeholder.jpg', fit: BoxFit.cover);

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 15, offset: Offset(1, 1))],
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
                            GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RecipeDetailPage(
                                      recipe: r,
                                      docId: r['id'],
                                    ),
                                  ),
                                );

                                if (result == 'refresh') {
                                  _loadFirebaseRecipes();
                                  _loadSaved();
                                  _loadSavedCommunity();
                                }
                                final isStatic = r['image'] != null;
                                final isCommunitySaved = r['cat'] == 'Saved' && r['image'] != null && r['imageUrl'] == null;

                                List<String> ingredients = [];
                                List<String> steps = [];

                                if (isStatic) {
                                  final data = staticRecipeData[r['title']];
                                  ingredients = List<String>.from(data?['ingredients'] ?? []);
                                  steps = List<String>.from(data?['steps'] ?? []);
                                } else {
                                  ingredients = List<String>.from(r['ingredients'] ?? []);
                                  steps = List<String>.from(r['steps'] ?? []);
                                }

                                if (isCommunitySaved) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CommunityRecipeDetailPage(
                                        recipe: r,
                                        ingredients: ingredients,
                                        steps: steps,
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RecipeDetailPage(
                                        recipe: r,
                                        docId: r['id'],
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: Container(
                                      height: 120,
                                      width: 129,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        image: DecorationImage(
                                          image: imageWidget.image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    r['title'] ?? '',
                                    style: const TextStyle(fontSize: 18, color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
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
