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

  TableRow _tableRow(String label, Widget field) {
    return TableRow(children: [
      Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text(label)),
      Padding(padding: EdgeInsets.symmetric(vertical: 8), child: field),
    ]);
  }

  Widget _field(Widget child) {
    return Padding(padding: EdgeInsets.all(4), child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create New Recipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image Frame & Upload
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: selectedImage == null
                        ? Center(child: Text('No image selected'))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(selectedImage!, fit: BoxFit.cover, width: double.infinity),
                          ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.upload),
                  label: Text('Upload Image'),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Recipe Info
            Table(
              columnWidths: {
                0: FixedColumnWidth(140),
                1: FlexColumnWidth(),
              },
              children: [
                _tableRow('Recipe Name', TextField(controller: recipeNameController)),
                _tableRow('Servings', TextField(controller: servingsController)),
                _tableRow('Cook Duration', TextField(controller: durationController, keyboardType: TextInputType.number)),
                _tableRow('Private', Switch(value: isPrivate, onChanged: (val) => setState(() => isPrivate = val))),
              ],
            ),

            SizedBox(height: 20),
            Divider(),

            // Ingredients Section
            Align(alignment: Alignment.centerLeft, child: Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            SizedBox(height: 10),
            Table(columnWidths: {
              0: FixedColumnWidth(70),
              1: FixedColumnWidth(90),
              2: FlexColumnWidth(),
              3: FixedColumnWidth(40),
            }, children: [
              TableRow(children: [
                _field(TextField(
                  onChanged: (val) => amount = val,
                  controller: TextEditingController(text: amount),
                  decoration: InputDecoration(hintText: 'Amount'),
                )),
                _field(DropdownButton<String>(
                  isExpanded: true,
                  value: unit,
                  onChanged: (val) => setState(() => unit = val!),
                  items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                )),
                _field(TextField(
                  onChanged: (val) => ingredientName = val,
                  controller: TextEditingController(text: ingredientName),
                  decoration: InputDecoration(hintText: 'Ingredient'),
                )),
                IconButton(
                  icon: Icon(editingIngredientIndex == null ? Icons.add : Icons.check, color: Colors.green),
                  onPressed: _addOrUpdateIngredient,
                )
              ]),
            ]),
            ...ingredients.asMap().entries.map((entry) {
              final i = entry.key;
              final ing = entry.value;
              return Row(
                children: [
                  Expanded(child: Text('- ${ing['amount']} ${ing['unit']} ${ing['name']}')),
                  IconButton(onPressed: () => _editIngredient(i), icon: Icon(Icons.edit, color: Colors.orange)),
                  IconButton(onPressed: () => _confirmDeleteIngredient(i), icon: Icon(Icons.delete, color: Colors.red)),
                ],
              );
            }),

            SizedBox(height: 20),
            Divider(),

            // Steps Section
            Align(alignment: Alignment.centerLeft, child: Text('Steps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            SizedBox(height: 10),
            Table(columnWidths: {
              0: FlexColumnWidth(),
              1: FixedColumnWidth(40),
            }, children: [
              TableRow(children: [
                _field(TextField(
                  onChanged: (val) => stepInstruction = val,
                  controller: TextEditingController(text: stepInstruction),
                  decoration: InputDecoration(hintText: 'Enter step'),
                )),
                IconButton(
                  icon: Icon(editingStepIndex == null ? Icons.add : Icons.check, color: Colors.orange),
                  onPressed: _addOrUpdateStep,
                ),
              ])
            ]),
            ...directions.asMap().entries.map((entry) {
              final i = entry.key;
              final step = entry.value;
              return Row(
                children: [
                  Expanded(child: Text('${i + 1}. $step')),
                  IconButton(onPressed: () => _editStep(i), icon: Icon(Icons.edit, color: Colors.orange)),
                  IconButton(onPressed: () => _confirmDeleteStep(i), icon: Icon(Icons.delete, color: Colors.red)),
                ],
              );
            }),

            SizedBox(height: 20),
            Divider(),

            // Slider
            Row(children: [
              Text('Spiciness'),
              Expanded(
                child: Slider(
                  value: sliderValue,
                  onChanged: (val) => setState(() => sliderValue = val),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: sliderValue.round().toString(),
                ),
              ),
            ]),

            SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(onPressed: _uploadRecipe, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: Text('Upload')),
                SizedBox(width: 10),
                ElevatedButton(onPressed: _cancelRecipe, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text('Cancel')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
