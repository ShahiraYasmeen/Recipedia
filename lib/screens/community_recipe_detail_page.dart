import 'package:flutter/material.dart';

class CommunityRecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const CommunityRecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF4F5),
      appBar: AppBar(
        backgroundColor:  const Color(0xFF8B0000),
        title: const Text('Recipe Detail'),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                recipe['image'] ?? '',
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              recipe['title'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('By ${recipe['author'] ?? 'Unknown'}',
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 20, color: Colors.grey.shade700),
                const SizedBox(width: 6),
                Text(recipe['duration'] ?? ''),
                const SizedBox(width: 16),
                Icon(Icons.grade, size: 20, color: Colors.grey.shade700),
                const SizedBox(width: 6),
                Text(recipe['difficulty'] ?? ''),
                const SizedBox(width: 16),
                Icon(Icons.people, size: 20, color: Colors.grey.shade700),
                const SizedBox(width: 6),
                Text('${recipe['servings'] ?? ''} servings'),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Instructions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This is just a sample placeholder. The actual recipe instructions will be implemented later.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
