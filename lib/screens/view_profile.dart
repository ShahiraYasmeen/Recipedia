import 'package:flutter/material.dart';
import 'edit_profile.dart';
import 'setting.dart';
import 'login.dart';

// import 'saved_recipes_screen.dart';
// import 'uploaded_recipes_screen.dart';

class ViewProfileScreen extends StatelessWidget {
  const ViewProfileScreen({super.key});

  void _showOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOption(context, Icons.edit, "Edit profile", const EditProfileScreen()),
              // _buildOption(context, Icons.bookmark, "Saved recipes", const SavedRecipesScreen()),
              // _buildOption(context, Icons.cloud_upload, "Uploaded recipes", const UploadedRecipesScreen()),
              _buildOption(context, Icons.settings, "Settings", const SettingsScreen()),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFF8B0000)),
                title: const Text("Log out"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(BuildContext context, IconData icon, String label, Widget screen) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8B0000)),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 246, 255),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/avatar.jpg'),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Olivia Baker",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              "I am a UI/UX designer",
              style: TextStyle(color: Colors.grey),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: const [
                      _StatItem(label: "Followers", value: "1.5k"),
                      SizedBox(width: 16),
                      _StatItem(label: "Following", value: "5"),
                      SizedBox(width: 16),
                      _StatItem(label: "Recipes", value: "12"),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showOptions(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Recipes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Expanded(
              child: Center(child: Text("No recipes posted yet.")),
            ),
          ],
        ),
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
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
