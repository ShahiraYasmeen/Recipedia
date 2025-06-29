import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/splash_screen.dart';
import 'screens/homepage.dart';
import 'screens/community.dart';
import 'screens/createrecipe.dart';
import 'screens/view_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const RecipediaApp());
}

class RecipediaApp extends StatelessWidget {
  const RecipediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipedia_App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFFAD7A0)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // Disable debug banner
      home: const SplashScreen(), // Starting screen
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

  final List<Widget> _pages = [
    const HomepageScreen(),
    const CommunityScreen(),
    RecipeCreationScreen(), // Use the correct class name as defined in createrecipe.dart
    const ViewProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF8B0000),
        selectedItemColor: const Color(0xFFFAD7A0),
        unselectedItemColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: _selectedIndex == 0 ? 30 : 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group, size: _selectedIndex == 1 ? 30 : 24),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, size: _selectedIndex == 2 ? 30 : 24),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: _selectedIndex == 3 ? 30 : 24),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
