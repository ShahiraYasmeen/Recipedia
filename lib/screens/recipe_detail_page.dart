import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipedia/main.dart';
import 'createrecipe.dart';

class RecipeDetailPage extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final String docId;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
    required this.docId,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  Future<void> _onDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this recipe?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseFirestore.instance.collection('recipes').doc(widget.docId).delete();
      if (!mounted) return;
      Navigator.pop(context); // close loader
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavBarExample()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recipe deleted successfully')));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  Future<void> _onEdit() async {
    final doc = await FirebaseFirestore.instance.collection('recipes').doc(widget.docId).get();
    if (!doc.exists) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recipe data not found.')));
      return;
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeCreationScreen(recipeData: doc.data()!, docId: widget.docId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    final ingredients = (recipe['ingredients'] as List<dynamic>? ?? []).map((i) {
      if (i is String) return i;
      if (i is Map) return '${i['amount']} ${i['unit']} ${i['name']}';
      return i.toString();
    }).toList();

    final steps = (recipe['steps'] as List<dynamic>? ?? []).map((s) => s.toString()).toList();

    final duration = recipe['duration'] ?? '—';
    final servings = recipe['servings']?.toString() ?? '1';
    final difficulty = recipe['difficulty'] ?? 1;

    final imageUrl = recipe['imageUrl'];
    final imageAsset = recipe['image'];

    ImageProvider imageProvider;
    if (imageUrl != null && imageUrl.toString().startsWith('http')) {
      imageProvider = NetworkImage(imageUrl);
    } else if (imageAsset != null && imageAsset.toString().startsWith('http')) {
      imageProvider = NetworkImage(imageAsset);
    } else {
      imageProvider = const NetworkImage('https://via.placeholder.com/600x400?text=No+Image');
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      appBar: AppBar(
        title: const Text('Recipe Detail', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF8B0000),
        centerTitle: true,
        foregroundColor: Colors.white,
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
                  child: Image(
                    image: imageProvider,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF8B0000)),
                          onPressed: _onEdit,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Color(0xFF8B0000)),
                          onPressed: _onDelete,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe['title'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(duration),
                      const SizedBox(width: 16),
                      const Icon(Icons.local_fire_department, size: 16),
                      const SizedBox(width: 4),
                      Text(_difficultyLabel(difficulty)),
                      const SizedBox(width: 16),
                      const Icon(Icons.people, size: 16),
                      const SizedBox(width: 4),
                      Text('$servings servings'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...ingredients.map((i) => Text('- $i')),
                  const SizedBox(height: 20),
                  const Text('Steps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...steps.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('${e.key + 1}. ${e.value}'),
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

  String _difficultyLabel(int value) {
    if (value <= 2) return 'Easy';
    if (value <= 4) return 'Medium';
    return 'Hard';
  }
}
