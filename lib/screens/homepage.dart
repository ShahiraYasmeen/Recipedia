// Updated HomepageScreen with safe casting, full recipe saving, and image fallback

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'recipe_detail_page.dart';
// ignore: unused_import
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
    'Beverage',
    'Snacks',
  ];

  String selectedCategory = 'All';
  Set<String> savedRecipes = {};
  late String uid;

  List<Map<String, dynamic>> firebaseRecipes = [];
  List<Map<String, dynamic>> savedCommunityRecipes = [];

  Future<List<Map<String, dynamic>>> fetchSavedCommunityRecipes() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot =
        await FirebaseFirestore.instance
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
        ...data, // <-- include all fields from Firestore
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
    _loadFirebaseRecipes();
    _loadSavedRecipes();
  }

  Future<void> _loadFirebaseRecipes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      firebaseRecipes = snapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();
    });
  }

  Future<void> _loadSavedRecipes() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('saved_recipes')
        .get();

    setState(() {
      savedRecipes = snap.docs.map((doc) => doc.id).toSet();
      savedCommunityRecipes = snap.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data, 'cat': 'Saved'};
      }).toList();
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
      await ref.set({
        'title': data['title'],
        'cat': data['cat'],
        'index': data['index'],
        'imageUrl': data['imageUrl'] ?? '',
        'image': data['image'] ?? '',
        'duration': data['duration'] ?? '',
        'difficulty': data['difficulty'] ?? 1,
        'servings': data['servings'] ?? '',
        'ingredients': data['ingredients'] ?? [],
        'steps': data['steps'] ?? [],
        'createdAt': data['createdAt'],
        'userId': data['userId'] ?? '',
      });
      setState(() => savedRecipes.add(id));
    }
  }

  List<Map<String, dynamic>> _getFilteredRecipes() {
    final Set<String> addedIds = {};
    final List<Map<String, dynamic>> result = [];

    if (selectedCategory == 'Saved') {
      for (var r in savedCommunityRecipes) {
        if (addedIds.add(r['id'])) result.add(r);
      }
    }

    for (var recipe in firebaseRecipes) {
      final isPrivate = recipe['isPrivate'] == true;
      final isSaved = savedRecipes.contains(recipe['id']);

      if (selectedCategory == 'Saved' && isSaved) {
        if (addedIds.add(recipe['id'])) result.add(recipe);
      } else if (selectedCategory == 'All') {
        if (addedIds.add(recipe['id'])) result.add(recipe);
      } else if (selectedCategory == recipe['cat'] &&
          (!isPrivate || recipe['userId'] == uid)) {
        if (addedIds.add(recipe['id'])) result.add(recipe);
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
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Popular Category",
                style: TextStyle(fontSize: 20, color: Color(0xFF8B0000))),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: categories.map((cat) {
                final isSelected = cat == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => selectedCategory = cat),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFF8B0000) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected
                            ? [
                                const BoxShadow(
                                  color: Color(0xFF8B0000),
                                  blurRadius: 6,
                                  offset: Offset(1, 1),
                                )
                              ]
                            : [],
                      ),
                      child: Text(cat,
                          style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Recipes",
                style: TextStyle(fontSize: 20, color: Colors.black)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: recipes.isEmpty
                ? const Center(child: Text("No recipes found."))
                : GridView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    itemCount: recipes.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 270,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, i) {
                      final r = recipes[i];
                      final isSaved = savedRecipes.contains(r['id']);

                      final imageWidget = (r['imageUrl'] != null &&
                              r['imageUrl'].toString().startsWith('http'))
                          ? Image.network(r['imageUrl'], fit: BoxFit.cover)
                          : Image.asset(r['image'] ?? 'assets/placeholder.jpg',
                              fit: BoxFit.cover);

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 15,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: Icon(
                                  isSaved
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: isSaved
                                      ? const Color(0xFF8B0000)
                                      : Colors.black,
                                ),
                                onPressed: () => _toggleSave(r['id'], r),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                final ingredients = (r['ingredients']
                                            as List<dynamic>? ??
                                        [])
                                    .map((i) {
                                  if (i is String) return i;
                                  if (i is Map) {
                                    return '${i['amount']} ${i['unit']} ${i['name']}';
                                  }
                                  return i.toString();
                                }).toList();

                                final steps = (r['steps'] as List<dynamic>? ?? [])
                                    .map((s) => s.toString())
                                    .toList();

                                final isCommunitySaved =
                                    r['cat'] == 'Saved' &&
                                        (r['imageUrl'] == null ||
                                            r['userId'] != uid);

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
                                  Container(
                                    margin: const EdgeInsets.all(10),
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
                                  Text(
                                    r['title'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.black),
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
