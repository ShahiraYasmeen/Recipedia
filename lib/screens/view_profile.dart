import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile.dart';
import 'account.dart';
import 'login.dart';
import 'liked_recipe.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  String? _name;
  String? _bio;
  String? _location;
  String? _message;
  String? _imageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _name = data['name'] ?? '';
            _bio = data['bio'] ?? '';
            _location = data['location'] ?? '';
            _message = data['message'] ?? '';
            _imageUrl = data['imageUrl'];
            isLoading = false;
          });
        } else {
          // no profile exists
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching user profile: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F0),
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8B0000),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w500,
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child:  ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    const SizedBox(height: 60),
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _imageUrl != null && _imageUrl!.isNotEmpty
                                ? NetworkImage(_imageUrl!)
                                : const AssetImage('assets/avatar.jpg')
                                    as ImageProvider,
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (_name != null && _name!.isNotEmpty)
                      Center(
                        child: Text(
                          _name!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),

                    if (_bio != null && _bio!.isNotEmpty)
                      Center(
                        child: Text(
                          _bio!,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),

                    if (_location != null && _location!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(0xFF8B0000),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _location!,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (_message != null && _message!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4,
                        ),
                        child: Center(
                          child: Text(
                            '"$_message"',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(color: Colors.black26),
                    ),

                    _buildTile(Icons.account_circle, "Account", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountsScreen(),
                        ),
                      );
                    }),

                    _buildTile(Icons.edit, "Edit Profile", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    }),

                     _buildTile(Icons.favorite, "Liked Recipes", () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (_) => const LikedRecipeScreen(),
                         ),
                       );
                     }),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            "Log Out",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B0000),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF8B0000)),
        title: Text(title, style: const TextStyle(color: Colors.black)),
        onTap: onTap,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
