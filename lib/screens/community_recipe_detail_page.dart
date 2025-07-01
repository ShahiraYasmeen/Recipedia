import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityRecipeDetailPage extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const CommunityRecipeDetailPage({super.key, required this.recipe});

  @override
  State<CommunityRecipeDetailPage> createState() => _CommunityRecipeDetailPageState();
}

class _CommunityRecipeDetailPageState extends State<CommunityRecipeDetailPage> {
  bool isSaved = false;
  late String uid;
  late String recipeId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    uid = user?.uid ?? '';

    // Make sure recipe has cat and index keys
    final cat = widget.recipe['cat'] ?? 0;
    final index = widget.recipe['index'] ?? 0;
    recipeId = '$cat-$index';

    _checkSavedStatus();
  }

  Future<void> _checkSavedStatus() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('saved_recipes')
        .doc(recipeId)
        .get();

    setState(() {
      isSaved = doc.exists;
    });
  }

  Future<void> _toggleSave() async {
    final recipe = widget.recipe;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('saved_recipes')
        .doc(recipeId);

    if (isSaved) {
      await ref.delete();
    } else {
      await ref.set({
        'title': recipe['title'],
        'cat': recipe['cat'],
        'index': recipe['index'],
      });
    }

    setState(() {
      isSaved = !isSaved;
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      appBar: AppBar(
        title: const Text('Recipe Detail'),
        backgroundColor: const Color(0xFF8B0000),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  recipe['image'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? const Color(0xFF8B0000) : Colors.black,
                  size: 30,
                ),
                onPressed: _toggleSave,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            recipe['title'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'By ${recipe['author']}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 4),
              Text(recipe['duration']),
              const SizedBox(width: 16),
              const Icon(Icons.whatshot, size: 16),
              const SizedBox(width: 4),
              Text(recipe['difficulty']),
              const SizedBox(width: 16),
              const Icon(Icons.group, size: 16),
              const SizedBox(width: 4),
              Text('${recipe['servings']} servings'),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Instructions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This is just a sample placeholder. The actual recipe instructions will be implemented later.',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
