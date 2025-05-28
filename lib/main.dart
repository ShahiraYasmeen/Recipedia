import 'package:flutter/material.dart';
import 'package:recipedia/screens/homepage.dart';
import 'package:recipedia/screens/login.dart';

void main() {
  runApp(const RecipediaApp());
}

class RecipediaApp extends StatelessWidget {
  const RecipediaApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipedia_App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BottomNavBarExample(),
    );
  }
}

class BottomNavBarExample extends StatefulWidget {
  const BottomNavBarExample({super.key});

  @override
  State<BottomNavBarExample> createState() => _BottomNavBarExampleState();
}

class _BottomNavBarExampleState extends State<BottomNavBarExample> {
  int _selectedIndex = 0;

  //pages for each tab
  final List<Widget> _pages = [
    const HomepageScreen(),
    const CommunityScreen(),
    const CreateRecipeScreen(),
    const ProfileSetupScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipedia')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.deepPurple, //set color bg here
        selectedItemColor: Colors.black, //color of select item
        unselectedItemColor: Colors.purple.shade200, //colorof unselected
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),

      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: const Text('/Login'),
        ),
      ),
    );
  }
}

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Setup')),

      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: const Text('/Set Up Profile'),
        ),
      ),
    );
  }
}

class HomepageScreen extends StatelessWidget {
  const HomepageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipedia Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.pushNamed(context, '/community');
            },
          ),

          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/create');
            },
          ),
        ],
      ),
      body: const Center(child: Text('Welcome to Recipedia!')),
    );
  }
}

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),

      body: const Center(child: Text('This is the Community page.')),
    );
  }
}

class CreateRecipeScreen extends StatelessWidget {
  const CreateRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Recipe')),

      body: const Center(child: Text('This is the Create Recipe page.')),
    );
  }
}


//kema cantikkkkkkkkkkk