import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MaterialApp(home: RecipeCreationScreen()));

class RecipeCreationScreen extends StatefulWidget {
  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<RecipeCreationScreen> {
  bool isPrivate = false;
  double sliderValue = 1;
  double difficultyValue = 1;
  String category = 'Appetizer';
  String durationUnit = 'mins';
  File? selectedImage;
  final picker = ImagePicker();

  final recipeNameController = TextEditingController();
  final servingsController = TextEditingController();
  final durationController = TextEditingController();

  List<Map<String, String>> ingredients = [];
  List<String> directions = [];

  String amount = '';
  String unit = 'gram';
  String ingredientName = '';
  int? editingIngredientIndex;

  String stepInstruction = '';
  int? editingStepIndex;

  final List<String> units = ['gram', 'kg', 'ml', 'oz', 'can'];
  final List<String> categories = ['Appetizer', 'Main Course', 'Dessert', 'Beverage', 'Snacks'];
  final List<String> durationUnits = ['sec', 'mins', 'hours'];

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _uploadRecipe() {
    _showSnackBar('Recipe uploaded successfully!', Colors.blue);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage(category: category)),
    );
  }

  void _cancelRecipe() {
    _showSnackBar('Recipe upload cancelled.', Colors.red);
  }

  void _pickImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  void _addOrUpdateIngredient() {
    if (amount.isEmpty || ingredientName.isEmpty) return;

    if (editingIngredientIndex == null) {
      ingredients.add({'amount': amount, 'unit': unit, 'name': ingredientName});
    } else {
      ingredients[editingIngredientIndex!] = {'amount': amount, 'unit': unit, 'name': ingredientName};
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

  void _confirmDeleteIngredient(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Ingredient'),
        content: Text('Are you sure you want to delete this ingredient?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteIngredient(index);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
      directions.add(stepInstruction);
    } else {
      directions[editingStepIndex!] = stepInstruction;
      editingStepIndex = null;
    }

    setState(() {
      stepInstruction = '';
    });
  }

  void _editStep(int index) {
    setState(() {
      stepInstruction = directions[index];
      editingStepIndex = index;
    });
  }

  void _confirmDeleteStep(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Step'),
        content: Text('Are you sure you want to delete this step?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteStep(index);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteStep(int index) {
    setState(() {
      directions.removeAt(index);
      if (editingStepIndex == index) editingStepIndex = null;
    });
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      );

  Widget _card({required Widget child}) => Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF6F0),
      appBar: AppBar(
        backgroundColor: Color(0xFF8B0000),
        title: Text('Create New Recipe', style: TextStyle(fontFamily: 'Poppins')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: selectedImage == null
                  ? Center(child: Text('No image selected'))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(selectedImage!, fit: BoxFit.cover, width: double.infinity),
                    ),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFE0B2),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _pickImage,
              icon: Icon(Icons.upload),
              label: Text('Upload Image'),
            ),
            SizedBox(height: 20),
            _fieldLabel('Recipe Name'),
            _card(child: TextField(controller: recipeNameController, decoration: InputDecoration.collapsed(hintText: 'Enter name'))),
            _fieldLabel('Category'),
            _card(
              child: DropdownButton<String>(
                isExpanded: true,
                value: category,
                onChanged: (val) => setState(() => category = val!),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              ),
            ),
            _fieldLabel('Servings'),
            _card(child: TextField(controller: servingsController, decoration: InputDecoration.collapsed(hintText: 'e.g. 4'))),
            _fieldLabel('Cook Duration'),
            _card(
              child: Row(
                children: [
                  Expanded(child: TextField(controller: durationController, keyboardType: TextInputType.number, decoration: InputDecoration.collapsed(hintText: 'e.g. 30'))),
                  SizedBox(width: 8),
                  DropdownButton<String>(
                    value: durationUnit,
                    onChanged: (val) => setState(() => durationUnit = val!),
                    items: durationUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  ),
                ],
              ),
            ),
            _fieldLabel('Private'),
            Switch(value: isPrivate, onChanged: (val) => setState(() => isPrivate = val)),
            SizedBox(height: 20),
            _fieldLabel('Ingredients'),
            _card(
              child: Row(
                children: [
                  Expanded(child: TextField(onChanged: (val) => amount = val, controller: TextEditingController(text: amount), decoration: InputDecoration(hintText: 'Amount'))),
                  SizedBox(width: 8),
                  DropdownButton<String>(
                    value: unit,
                    onChanged: (val) => setState(() => unit = val!),
                    items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  ),
                  SizedBox(width: 8),
                  Expanded(child: TextField(onChanged: (val) => ingredientName = val, controller: TextEditingController(text: ingredientName), decoration: InputDecoration(hintText: 'Ingredient'))),
                  IconButton(icon: Icon(editingIngredientIndex == null ? Icons.add : Icons.check, color: Colors.green), onPressed: _addOrUpdateIngredient),
                ],
              ),
            ),
            ...ingredients.asMap().entries.map((entry) {
              final i = entry.key;
              final ing = entry.value;
              return _card(
                child: Row(
                  children: [
                    Expanded(child: Text('- ${ing['amount']} ${ing['unit']} ${ing['name']}')),
                    IconButton(onPressed: () => _editIngredient(i), icon: Icon(Icons.edit, color: Colors.orange)),
                    IconButton(onPressed: () => _confirmDeleteIngredient(i), icon: Icon(Icons.delete, color: Colors.red)),
                  ],
                ),
              );
            }),
            SizedBox(height: 20),
            _fieldLabel('Steps'),
            _card(
              child: Row(
                children: [
                  Expanded(child: TextField(onChanged: (val) => stepInstruction = val, controller: TextEditingController(text: stepInstruction), decoration: InputDecoration(hintText: 'Enter step'))),
                  IconButton(icon: Icon(editingStepIndex == null ? Icons.add : Icons.check, color: Colors.orange), onPressed: _addOrUpdateStep),
                ],
              ),
            ),
            ...directions.asMap().entries.map((entry) {
              final i = entry.key;
              final step = entry.value;
              return _card(
                child: Row(
                  children: [
                    Expanded(child: Text('${i + 1}. $step')),
                    IconButton(onPressed: () => _editStep(i), icon: Icon(Icons.edit, color: Colors.orange)),
                    IconButton(onPressed: () => _confirmDeleteStep(i), icon: Icon(Icons.delete, color: Colors.red)),
                  ],
                ),
              );
            }),
            SizedBox(height: 20),
            _fieldLabel('Spiciness'),
            _card(
              child: Slider(
                value: sliderValue,
                onChanged: (val) => setState(() => sliderValue = val),
                min: 1,
                max: 5,
                divisions: 4,
                label: sliderValue.round().toString(),
              ),
            ),
            _fieldLabel('Difficulty'),
            _card(
              child: Slider(
                value: difficultyValue,
                onChanged: (val) => setState(() => difficultyValue = val),
                min: 1,
                max: 5,
                divisions: 4,
                label: difficultyValue.round().toString(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _uploadRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text('Upload'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _cancelRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String category;

  HomePage({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$category Recipes')),
      body: Center(child: Text('Display $category recipes here...')),
    );
  }
}
