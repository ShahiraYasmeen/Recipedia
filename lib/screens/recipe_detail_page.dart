import 'package:flutter/material.dart';
import 'recipe_data.dart';

class RecipeDetailPage extends StatefulWidget {
  final String title;
  final String imagePath;

  const RecipeDetailPage({
    super.key,
    required this.title,
    required this.imagePath,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  void _onDelete() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Delete button clicked (dummy)")),
    );
  }

  void _onEdit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Edit button clicked (dummy)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = recipes[widget.title];
    final ingredients = data?['ingredients'] as List<String>? ?? [];
    final steps = data?['steps'] as List<String>? ?? [];

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
                  child: Image.asset(
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

            // Recipe Details
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
                  ...ingredients.map((item) => Text('- $item')),

                  const SizedBox(height: 20),
                  const Text(
                    'Steps',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...steps.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('${entry.key + 1}. ${entry.value}'),
                        ),
                      ),
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
