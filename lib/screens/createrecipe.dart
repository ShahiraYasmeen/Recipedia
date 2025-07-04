// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class RecipeCreationScreen extends StatefulWidget {
  final Map<String, dynamic>? recipeData;
  final String? docId;

  const RecipeCreationScreen({super.key, this.recipeData, this.docId});

  @override
  State<RecipeCreationScreen> createState() => _RecipeCreationScreenState();
}

class _RecipeCreationScreenState extends State<RecipeCreationScreen> {
  final ImagePicker picker = ImagePicker();
  Uint8List? _imageBytes;

  final recipeNameController = TextEditingController();
  final servingsController = TextEditingController();
  final durationController = TextEditingController();

  bool isPrivate = false;
  double spiciness = 1;
  double difficulty = 1;
  String category = 'Appetizer';
  String durationUnit = 'mins';

  final List<String> categories = ['Appetizer', 'Main Course', 'Dessert', 'Beverage', 'Snacks'];
  final List<String> units = ['gram', 'kg', 'ml', 'oz', 'can', 'pcs', 'cup', 'tbsp', 'tsp', 'cm', 'inch'];
  final List<String> durationUnits = ['sec', 'mins', 'hours'];

  List<Map<String, String>> ingredients = [];
  List<String> steps = [];

  String amount = '';
  String unit = 'gram';
  String ingredientName = '';
  int? editingIngredientIndex;

  String stepInstruction = '';
  int? editingStepIndex;

  @override
  void initState() {
    super.initState();
    if (widget.recipeData != null) {
      final data = widget.recipeData!;
      recipeNameController.text = data['title'] ?? '';
      category = data['category'] ?? 'Appetizer';
      servingsController.text = data['servings'] ?? '';
      final durationParts = (data['duration'] ?? '30 mins').split(' ');
      if (durationParts.length == 2) {
        durationController.text = durationParts[0];
        durationUnit = durationParts[1];
      }
      spiciness = (data['spiciness'] ?? 1).toDouble();
      difficulty = (data['difficulty'] ?? 1).toDouble();
      isPrivate = data['isPrivate'] ?? false;
      ingredients = List<Map<String, String>>.from((data['ingredients'] ?? []).map((i) => Map<String, String>.from(i)));
      steps = List<String>.from(data['steps'] ?? []);
      final imageUrl = data['imageUrl'];
      if (imageUrl != null && imageUrl.toString().startsWith('http')) {
        http.get(Uri.parse(imageUrl)).then((res) {
          if (res.statusCode == 200) {
            setState(() => _imageBytes = res.bodyBytes);
          }
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  void _addOrUpdateIngredient() {
    if (amount.isEmpty || ingredientName.isEmpty) return;
    final ing = {'amount': amount, 'unit': unit, 'name': ingredientName};
    if (editingIngredientIndex == null) {
      ingredients.add(ing);
    } else {
      ingredients[editingIngredientIndex!] = ing;
      editingIngredientIndex = null;
    }
    setState(() {
      amount = '';
      ingredientName = '';
    });
  }

  void _deleteIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
      if (editingIngredientIndex == index) editingIngredientIndex = null;
    });
  }

  void _addOrUpdateStep() {
    if (stepInstruction.isEmpty) return;
    if (editingStepIndex == null) {
      steps.add(stepInstruction);
    } else {
      steps[editingStepIndex!] = stepInstruction;
      editingStepIndex = null;
    }
    setState(() {
      stepInstruction = '';
    });
  }

  void _deleteStep(int index) {
    setState(() {
      steps.removeAt(index);
      if (editingStepIndex == index) editingStepIndex = null;
    });
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cancel Upload'),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close),
              ),
            ],
          ),
          content: const Text('Are you sure you want to cancel? Your data will not be saved.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _uploadToCloudinary(Uint8List imageBytes) async {
    const cloudName = 'dufmk32fr';
    const uploadPreset = 'flutter_Recipedia';
    final fileName = recipeNameController.text.trim().replaceAll('/', '_');
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['public_id'] = fileName
      ..files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: '$fileName.jpg'));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final result = json.decode(responseData);
      return result['secure_url'];
    } else {
      final error = await response.stream.bytesToString();
      print('Cloudinary Upload Error: $error');
      return null;
    }
  }

  Future<void> _uploadRecipe() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw 'You must be logged in';

      if (recipeNameController.text.trim().isEmpty ||
          durationController.text.trim().isEmpty ||
          servingsController.text.trim().isEmpty ||
          _imageBytes == null ||
          ingredients.isEmpty ||
          steps.isEmpty) {
        _showSnackBar('Please complete all fields and upload an image.', Colors.orange);
        return;
      }

      _showSnackBar('Uploading recipe...', Colors.deepOrange);

      final imageUrl = await _uploadToCloudinary(_imageBytes!);
      if (imageUrl == null) throw 'Image upload failed';

      final recipeMap = {
        'userId': uid,
        'title': recipeNameController.text.trim(),
        'category': category,
        'duration': '${durationController.text.trim()} $durationUnit',
        'servings': servingsController.text.trim(),
        'difficulty': difficulty.round(),
        'spiciness': spiciness.round(),
        'ingredients': ingredients,
        'steps': steps,
        'isPrivate': isPrivate,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (widget.docId != null) {
        await FirebaseFirestore.instance.collection('recipes').doc(widget.docId).update(recipeMap);
        _showSnackBar('Recipe updated!', Colors.green);
      } else {
        await FirebaseFirestore.instance.collection('recipes').add(recipeMap);
        _showSnackBar('Recipe uploaded!', Colors.green);
      }

      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F0),
      appBar: AppBar(
        title: const Text('Create New Recipe'),
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(_imageBytes!, width: double.infinity, height: 180, fit: BoxFit.cover),
                  )
                : Container(
                    height: 180,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[300]),
                    child: const Center(child: Text('No image selected')),
                  ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload),
              label: const Text('Upload Image'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFE0B2), foregroundColor: Colors.black),
            ),

            _label('Recipe Name'),
            _card(TextField(controller: recipeNameController, decoration: const InputDecoration.collapsed(hintText: 'Enter name'))),
            _label('Category'),
            _card(DropdownButton<String>(
              isExpanded: true,
              value: category,
              onChanged: (val) => setState(() => category = val!),
              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            )),
            _label('Servings'),
            _card(TextField(controller: servingsController, decoration: const InputDecoration.collapsed(hintText: 'e.g. 4'))),
            _label('Cook Duration'),
            _card(Row(children: [
              Expanded(child: TextField(controller: durationController, keyboardType: TextInputType.number, decoration: const InputDecoration.collapsed(hintText: 'e.g. 30'))),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: durationUnit,
                onChanged: (val) => setState(() => durationUnit = val!),
                items: durationUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              ),
            ])),
            _label('Spiciness'),
            _card(Slider(value: spiciness, onChanged: (v) => setState(() => spiciness = v), min: 1, max: 5, divisions: 4, label: spiciness.round().toString())),
            _label('Difficulty'),
            _card(Slider(value: difficulty, onChanged: (v) => setState(() => difficulty = v), min: 1, max: 5, divisions: 4, label: difficulty.round().toString())),
            _label('Ingredients'),
            _card(Row(children: [
              Expanded(child: TextField(onChanged: (val) => amount = val, controller: TextEditingController(text: amount), decoration: const InputDecoration(hintText: 'Amount'))),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: unit,
                onChanged: (val) => setState(() => unit = val!),
                items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              ),
              const SizedBox(width: 8),
              Expanded(child: TextField(onChanged: (val) => ingredientName = val, controller: TextEditingController(text: ingredientName), decoration: const InputDecoration(hintText: 'Ingredient'))),
              IconButton(icon: Icon(editingIngredientIndex == null ? Icons.add : Icons.check, color: Colors.green), onPressed: _addOrUpdateIngredient),
            ])),
            ...ingredients.asMap().entries.map((entry) => _card(Row(
              children: [
                Expanded(child: Text('- ${entry.value['amount']} ${entry.value['unit']} ${entry.value['name']}')),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteIngredient(entry.key)),
              ],
            ))),

            _label('Steps'),
            _card(Row(children: [
              Expanded(child: TextField(onChanged: (val) => stepInstruction = val, controller: TextEditingController(text: stepInstruction), decoration: const InputDecoration(hintText: 'Enter step'))),
              IconButton(icon: Icon(editingStepIndex == null ? Icons.add : Icons.check, color: Colors.orange), onPressed: _addOrUpdateStep),
            ])),
            ...steps.asMap().entries.map((entry) => _card(Row(
              children: [
                Expanded(child: Text('${entry.key + 1}. ${entry.value}')),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteStep(entry.key)),
              ],
            ))),

            _label('Private? Only show on Homepage'),
            Switch(value: isPrivate, onChanged: (val) => setState(() => isPrivate = val), activeColor: const Color(0xFF8B0000)),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(onPressed: _uploadRecipe, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text('Upload')),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: () => _showCancelDialog(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Cancel')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _card(Widget child) => Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: child,
      );
}
