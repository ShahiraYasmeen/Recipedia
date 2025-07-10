// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'createrecipe.dart';

class CommunityRecipeDetailPage extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final List<String> ingredients;
  final List<String> steps;

  const CommunityRecipeDetailPage({
    super.key,
    required this.recipe,
    required this.ingredients,
    required this.steps,
  });

  @override
  State<CommunityRecipeDetailPage> createState() => _CommunityRecipeDetailPageState();
}

class _CommunityRecipeDetailPageState extends State<CommunityRecipeDetailPage> {
  bool isSaved = false;
  String? userId;
  bool isOwner = false;
  String formattedDate = '';

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _checkIfSaved();
    _checkIfOwner();
    _formatTimestamp();
  }

  void _checkIfOwner() {
    if (userId == widget.recipe['userId']) {
      setState(() => isOwner = true);
    }
  }

  void _formatTimestamp() {
    final ts = widget.recipe['createdAt'];
    if (ts != null && ts is Timestamp) {
      final date = ts.toDate();
      formattedDate = DateFormat.yMMMd().add_jm().format(date);
    }
  }

  Future<void> _checkIfSaved() async {
    if (userId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('saved_recipes')
          .doc(widget.recipe['title'])
          .get();
      setState(() {
        isSaved = doc.exists;
      });
    }
  }

  Future<void> _deleteRecipe() async {
    try {
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipe['id'])
          .delete();

      Navigator.pop(context, 'refresh');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  void _editRecipe() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeCreationScreen(
          recipeData: widget.recipe,
          docId: widget.recipe['id'],
        ),
      ),
    );

    if (result == 'refresh') {
      Navigator.pop(context, 'refresh');
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    final List<String> ingredients = (recipe['ingredients'] as List<dynamic>? ?? [])
        .map((i) {
          if (i is String) return i;
          if (i is Map) return '${i['amount']} ${i['unit']} ${i['name']}';
          return i.toString();
        }).toList();

    final List<String> steps = (recipe['steps'] as List<dynamic>? ?? []).map((s) => s.toString()).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Detail'),
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
        actions: isOwner
            ? [
                IconButton(icon: const Icon(Icons.edit), onPressed: _editRecipe),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete Recipe?'),
                        content: const Text('Are you sure you want to delete this recipe?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteRecipe();
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: Builder(
                    builder: (context) {
                      final image1 = recipe['imageUrl']?.toString() ?? '';
                      final image2 = recipe['image']?.toString() ?? '';
                      ImageProvider imageProvider;

                      if (image1.startsWith('http')) {
                        imageProvider = NetworkImage(image1);
                      } else if (image2.startsWith('http')) {
                        imageProvider = NetworkImage(image2);
                      } else {
                        imageProvider = const AssetImage('assets/placeholder.jpg');
                      }

                      return Image(
                        image: imageProvider,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: const Color(0xFF8B0000),
                      ),
                      onPressed: () async {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid == null) return;

                        final docRef = FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .collection('saved_recipes')
                            .doc(recipe['title']);

                        final doc = await docRef.get();

                        if (doc.exists) {
                          await docRef.delete();
                          setState(() => isSaved = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Recipe unsaved')),
                          );
                        } else {
                          await docRef.set({
                            'title': recipe['title'],
                            'author': recipe['author'],
                            'image': recipe['imageUrl'] ?? recipe['image'],
                            'duration': recipe['duration'],
                            'difficulty': recipe['difficulty'],
                            'servings': recipe['servings'],
                            'ingredients': recipe['ingredients'],
                            'steps': recipe['steps'],
                            'category': recipe['category'],
                          });
                          setState(() => isSaved = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Recipe saved')),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe['title'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text("By ${recipe['author'] ?? 'Unknown'}"),
                  if (formattedDate.isNotEmpty)
                    Text('Posted on $formattedDate', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(recipe['duration'] ?? ''),
                      const SizedBox(width: 16),
                      const Icon(Icons.local_fire_department, size: 16),
                      const SizedBox(width: 4),
                      Text(recipe['difficulty'].toString()),
                      const SizedBox(width: 16),
                      const Icon(Icons.people, size: 16),
                      const SizedBox(width: 4),
                      Text('${recipe['servings']} servings'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...ingredients.map((item) => Text('- $item')),
                  const SizedBox(height: 20),
                  const Text('Steps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...steps.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('${entry.key + 1}. ${entry.value}'),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
