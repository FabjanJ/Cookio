import 'package:flutter/material.dart';
import 'dart:io';
// ignore: unused_import
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const HelloApp());
}

class HelloApp extends StatelessWidget {
  const HelloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cookio',
      home: HelloHomePage(),
    );
  }
}

class HelloHomePage extends StatelessWidget {
  const HelloHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Anzahl der Tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: kToolbarHeight, // Standardhöhe
          automaticallyImplyLeading: false, // Kein zurück Pfeil
          titleSpacing: 0, // Kein Abstand für Titel
          surfaceTintColor: Colors.transparent, // Kein Schatten
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Erstellen'),
              Tab(text: 'Meine Rezepte'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CreateRecipeTab(), // Tab 1: Erstellen
            MyRecipesTab(),    // Tab 2: Meine Rezepte
          ],
        ),
      ),
    );
  }
}

// Tab 1: Erstellen
class CreateRecipeTab extends StatefulWidget {
  const CreateRecipeTab({super.key});

  @override
  State<CreateRecipeTab> createState() => _CreateRecipeTabState();
}

class _CreateRecipeTabState extends State<CreateRecipeTab> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  Future<void> _saveRecipe() async {
    if (_titleController.text.isEmpty) return;
    
    final directory = Directory('recipes');
    if (!await directory.exists()) {
      await directory.create();
    }

    final file = File('recipes/${_titleController.text}.txt');
    await file.writeAsString(_contentController.text);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rezept gespeichert!'))
    );
    
    _titleController.clear();
    _contentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Rezeptname',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _contentController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Rezept eingeben...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveRecipe,
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
}

// Tab 2: Meine Rezepte
class MyRecipesTab extends StatefulWidget {
  const MyRecipesTab({super.key});

  @override
  State<MyRecipesTab> createState() => _MyRecipesTabState();
}

class _MyRecipesTabState extends State<MyRecipesTab> {
  List<FileSystemEntity> _recipes = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final directory = Directory('recipes');
    if (await directory.exists()) {
      final files = await directory.list().toList();
      setState(() {
        _recipes = files;
      });
    }
  }

  List<FileSystemEntity> get _filteredRecipes {
    if (_searchQuery.isEmpty) return _recipes;
    return _recipes.where((file) => 
      file.path.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: const InputDecoration(
              labelText: 'Rezepte suchen',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredRecipes.length,
            itemBuilder: (context, index) {
              final file = _filteredRecipes[index];
              final name = file.path.split('/').last.replaceAll('.txt', '');
              return ListTile(
                title: Text(name),
                onTap: () async {
                  final content = await File(file.path).readAsString();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(name),
                      content: SingleChildScrollView(
                        child: Text(content),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Schließen'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
