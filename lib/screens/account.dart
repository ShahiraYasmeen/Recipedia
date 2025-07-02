import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  void _reauthenticateAndUpdateEmail(BuildContext context, String newEmail) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final TextEditingController currentPasswordController = TextEditingController();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Enter Current Password"),
          content: TextField(
            controller: currentPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Current Password"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000)),
              onPressed: () async {
                final cred = EmailAuthProvider.credential(
                  email: user.email!,
                  password: currentPasswordController.text,
                );

                try {
                  await user.reauthenticateWithCredential(cred);
                  await user.updateEmail(newEmail);
                  await user.sendEmailVerification(); // Send verification

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Email updated. Please verify the new email."),
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
              child: const Text("Confirm", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  void _reauthenticateAndUpdatePassword(BuildContext context, String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final TextEditingController currentPasswordController = TextEditingController();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Enter Current Password"),
          content: TextField(
            controller: currentPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Current Password"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000)),
              onPressed: () async {
                final cred = EmailAuthProvider.credential(
                  email: user.email!,
                  password: currentPasswordController.text,
                );

                try {
                  await user.reauthenticateWithCredential(cred);
                  await user.updatePassword(newPassword);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password updated successfully")),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
              child: const Text("Confirm", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  void _showEmailDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Change Email"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: "New Email"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000)),
            onPressed: () {
              Navigator.pop(context);
              _reauthenticateAndUpdateEmail(context, emailController.text.trim());
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    final TextEditingController passController = TextEditingController();
    final TextEditingController confirmPassController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm Password"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000)),
            onPressed: () {
              if (passController.text == confirmPassController.text &&
                  passController.text.length >= 6) {
                Navigator.pop(context);
                _reauthenticateAndUpdatePassword(context, passController.text.trim());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password too short or doesn't match")),
                );
              }
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete your account?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.currentUser!.delete();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8B0000),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCardTile(
            icon: Icons.email,
            label: "Change Email",
            onTap: () => _showEmailDialog(context),
          ),
          _buildCardTile(
            icon: Icons.lock,
            label: "Change Password",
            onTap: () => _showPasswordDialog(context),
          ),
          _buildCardTile(
            icon: Icons.delete_forever,
            label: "Delete Account",
            onTap: () => _confirmDeleteAccount(context),
            iconColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildCardTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF8B0000),
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(label),
        onTap: onTap,
      ),
    );
  }
}
