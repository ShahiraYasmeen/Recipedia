import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeCreationScreen extends StatefulWidget {
  const RecipeCreationScreen({super.key});

  @override
  _RecipeCreationScreenState createState() => _RecipeCreationScreenState();
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
  final List<String> units = ['gram', 'kg', 'ml', 'oz', 'can'];
  final List<String> durationUnits = ['sec', 'mins', 'hours'];

  List<Map<String, String>> ingredients = [];
  List<String> steps = [];

  String amount = '';
  String unit = 'gram';
  String ingredientName = '';
  int? editingIngredientIndex;

  String stepInstruction = '';
  int? editingStepIndex;

  void _pickImage() async {
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

  void _editIngredient(int index) {
    final ing = ingredients[index];
    setState(() {
      amount = ing['amount']!;
      unit = ing['unit']!;
      ingredientName = ing['name']!;
      editingIngredientIndex = index;
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

  void _editStep(int index) {
    setState(() {
      stepInstruction = steps[index];
      editingStepIndex = index;
    });
  }

  void _deleteStep(int index) {
    setState(() {
      steps.removeAt(index);
      if (editingStepIndex == index) editingStepIndex = null;
    });
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _uploadRecipe() async {
    if (_imageBytes == null ||
        recipeNameController.text.isEmpty ||
        servingsController.text.isEmpty ||
        durationController.text.isEmpty ||
        ingredients.isEmpty ||
        steps.isEmpty) {
      _showSnackBar("Please complete all fields including image!", Colors.red);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar("User not logged in!", Colors.red);
      return;
    }

    final base64Image = base64Encode(_imageBytes!);

    final doc = {
      'title': recipeNameController.text.trim(),
      'category': category,
      'servings': servingsController.text.trim(),
      'duration': '${durationController.text.trim()} $durationUnit',
      'ingredients': ingredients,
      'steps': steps,
      'spiciness': spiciness,
      'difficulty': difficulty,
      'image': base64Image,
      'private': isPrivate,
      'uid': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('recipes').add(doc);
      _showSnackBar('Recipe uploaded successfully!', Colors.blue);
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error uploading: $e', Colors.red);
    }
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      );

  Widget _customCard(Widget child) => Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: child,
      );

  void _cancelRecipe() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B0000),
        title: const Text('Create New Recipe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(_imageBytes!, height: 180, fit: BoxFit.cover, width: double.infinity),
                  )
                : Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text('No image selected')),
                  ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFE0B2),
                foregroundColor: Colors.black,
              ),
              icon: const Icon(Icons.upload),
              label: const Text('Upload Image'),
            ),
            const SizedBox(height: 20),
            _fieldLabel('Recipe Name'),
            _customCard(TextField(controller: recipeNameController, decoration: const InputDecoration.collapsed(hintText: 'Enter recipe name'))),
            _fieldLabel('Category'),
            _customCard(
              DropdownButton<String>(
                isExpanded: true,
                value: category,
                onChanged: (val) => setState(() => category = val!),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              ),
            ),
            _fieldLabel('Servings'),
            _customCard(TextField(controller: servingsController, decoration: const InputDecoration.collapsed(hintText: 'e.g. 4'))),
            _fieldLabel('Cook Duration'),
            _customCard(
              Row(
                children: [
                  Expanded(child: TextField(controller: durationController, keyboardType: TextInputType.number, decoration: const InputDecoration.collapsed(hintText: 'e.g. 30'))),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: durationUnit,
                    onChanged: (val) => setState(() => durationUnit = val!),
                    items: durationUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  ),
                ],
              ),
            ),
            _fieldLabel('Ingredients'),
            _customCard(
              Row(
                children: [
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
                ],
              ),
            ),
            ...ingredients.asMap().entries.map((entry) {
              final i = entry.key;
              final ing = entry.value;
              return _customCard(
                Row(
                  children: [
                    Expanded(child: Text('- ${ing['amount']} ${ing['unit']} ${ing['name']}')),
                    IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _editIngredient(i)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteIngredient(i)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
            _fieldLabel('Steps'),
            _customCard(
              Row(
                children: [
                  Expanded(child: TextField(onChanged: (val) => stepInstruction = val, controller: TextEditingController(text: stepInstruction), decoration: const InputDecoration(hintText: 'Enter step'))),
                  IconButton(icon: Icon(editingStepIndex == null ? Icons.add : Icons.check, color: Colors.orange), onPressed: _addOrUpdateStep),
                ],
              ),
            ),
            ...steps.asMap().entries.map((entry) {
              final i = entry.key;
              final step = entry.value;
              return _customCard(
                Row(
                  children: [
                    Expanded(child: Text('${i + 1}. $step')),
                    IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _editStep(i)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteStep(i)),
                  ],
                ),
              );
            }),
            _fieldLabel('Spiciness'),
            _customCard(Slider(value: spiciness, min: 1, max: 5, divisions: 4, label: spiciness.round().toString(), onChanged: (v) => setState(() => spiciness = v))),
            _fieldLabel('Difficulty'),
            _customCard(Slider(value: difficulty, min: 1, max: 5, divisions: 4, label: difficulty.round().toString(), onChanged: (v) => setState(() => difficulty = v))),
            const SizedBox(height: 10),
            Row(
              children: [
                Switch(value: isPrivate, onChanged: (v) => setState(() => isPrivate = v)),
                Text("Private? Only show on Homepage", style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(onPressed: _uploadRecipe, child: const Text('Upload')),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _cancelRecipe, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Cancel')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
