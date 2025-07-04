// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _messageController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _locationController.text = data['location'] ?? '';
        _messageController.text = data['message'] ?? '';
        setState(() {
          _existingImageUrl = data['imageUrl'];
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<String> _uploadImageToCloudinary(XFile imageFile) async {
    final cloudName = 'dufmk32fr';
    final uploadPreset = 'flutter_Recipedia';
    
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload?upload_preset=$uploadPreset');

    final bytes = await imageFile.readAsBytes();
    final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: imageFile.path.split('/').last  ));
  
    final response = await request.send();

  if (response.statusCode == 200) {
    final responseData = await http.Response.fromStream(response);
    final data = json.decode(responseData.body);
    return data['secure_url'] as String;
  } else {
    throw Exception('Failed to upload image: ${response.statusCode}');
  }
}

Future<void> _saveProfile() async {
  if (_formKey.currentState!.validate()) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    String? imageUrl = _existingImageUrl;

    try {
      if (_selectedImage != null) {
        imageUrl = await _uploadImageToCloudinary(_selectedImage!);
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text,
        'bio': _bioController.text,
        'location': _locationController.text,
        'message': _messageController.text,
        'imageUrl': imageUrl,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    final avatar = _selectedImage != null
        ? Image.network(_selectedImage!.path).image
        : _existingImageUrl != null
            ? NetworkImage(_existingImageUrl!)
            : const AssetImage('assets/avatar.jpg') as ImageProvider;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8B0000),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: avatar,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.edit),
                          color: const Color.fromARGB(255, 0, 0, 0),
                          onPressed: _pickImage,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio / About Me',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message (max 50 words)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value != null && value.trim().split(RegExp(r'\s+')).length > 50) {
                      return 'Message cannot exceed 50 words';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B0000),
                    ),
                    child: const Text('Save', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
