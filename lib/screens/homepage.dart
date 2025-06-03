import 'package:flutter/material.dart';

class HomepageScreen extends StatelessWidget {
  const HomepageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipedia Home is here!!'),
        actions: [
          IconButton(icon: const Icon(Icons.people), onPressed: () {
            Navigator.pushNamed(context, '/community');
          },
        ),

          IconButton(icon: const Icon(Icons.add), onPressed: () {
              Navigator.pushNamed(context, '/create');
            },
          ),
        ],
      ),
      body:const Center(
        child: Text('Welcome to Recipedia! Explore and create more recipes.'),
      ),
    );
  }
}
