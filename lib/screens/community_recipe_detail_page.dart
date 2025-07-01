import 'package:flutter/material.dart';

class CommunityRecipeDetailPage extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const CommunityRecipeDetailPage({super.key, required this.recipe});

  @override
  State<CommunityRecipeDetailPage> createState() => _CommunityRecipeDetailPageState();
}

class _CommunityRecipeDetailPageState extends State<CommunityRecipeDetailPage> {
  bool isSaved = false;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

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
            // Recipe image with bookmark icon
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: Image.asset(
                    recipe['image'],
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isSaved = !isSaved;
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: const Color(0xFF8B0000),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Recipe details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['title'],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'By ${recipe['author']}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(recipe['duration']),
                      const SizedBox(width: 16),
                      const Icon(Icons.local_fire_department, size: 16),
                      const SizedBox(width: 4),
                      Text(recipe['difficulty']),
                      const SizedBox(width: 16),
                      const Icon(Icons.people, size: 16),
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
            ),
          ],
        ),
      ),
    );
  }
}
