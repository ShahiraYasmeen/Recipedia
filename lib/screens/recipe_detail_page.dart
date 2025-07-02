import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'createrecipe.dart';

class RecipeDetailPage extends StatefulWidget {
  final String title;
  final String imagePath;
  final String docId; // ✅ Add docId from HomepageScreen

  const RecipeDetailPage({
    super.key,
    required this.title,
    required this.imagePath,
    required this.docId,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  void _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure to delete the recipe?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('recipes').doc(widget.docId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recipe deleted successfully")),
      );
      Navigator.pop(context);
    }
  }

  void _onEdit() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('recipes')
        .doc(widget.docId)
        .get();

    if (!docSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recipe data not found.")),
      );
      return;
    }

    final data = docSnapshot.data();

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeCreationScreen(
          recipeData: data!,
          docId: widget.docId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      appBar: AppBar(
        title: const Text(
          'Recipe Detail',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
                  child: widget.imagePath.startsWith('http')
                      ? Image.network(
                          widget.imagePath,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          widget.imagePath,
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

            // Static details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.access_time, size: 16),
                      SizedBox(width: 4),
                      Text('30 mins'),
                      SizedBox(width: 16),
                      Icon(Icons.local_fire_department, size: 16),
                      SizedBox(width: 4),
                      Text('Easy'),
                      SizedBox(width: 16),
                      Icon(Icons.people, size: 16),
                      SizedBox(width: 4),
                      Text('2 servings'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ingredients',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('- Sample Ingredient 1'),
                  const Text('- Sample Ingredient 2'),
                  const SizedBox(height: 20),
                  const Text(
                    'Steps',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('1. Sample step one.'),
                  const Text('2. Sample step two.'),
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
