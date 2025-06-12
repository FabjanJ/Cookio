import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const HelloApp());
}

class HelloApp extends StatelessWidget {
  const HelloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cookio',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color.fromARGB(255, 12, 90, 180),
          secondary: Colors.indigo.shade400,
          surface: Colors.white,
          background: Colors.grey.shade50,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 12, 90, 180),
          foregroundColor: Colors.white,
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              color: const Color.fromARGB(255, 255, 255, 255),
              width: 3.0,
            ),
          ),
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 12, 90, 180),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: const Color.fromARGB(255, 12, 90, 180), width: 2.0),
          ),
        ),
      ),
      home: const HelloHomePage(),
    );
  }
}

class HelloHomePage extends StatelessWidget {
  const HelloHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: kToolbarHeight,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Erstellen'),
              Tab(text: 'Meine Rezepte'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CreateRecipeTab(),
            MyRecipesTab(),
          ],
        ),
      ),
    );
  }
}

class CreateRecipeTab extends StatefulWidget {
  const CreateRecipeTab({super.key});

  @override
  State<CreateRecipeTab> createState() => _CreateRecipeTabState();
}

class _CreateRecipeTabState extends State<CreateRecipeTab> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final List<String> _availableLabels = [
    'Glutenfrei',
    'Laktosefrei',
    'Nussfrei',
    'Apfelfrei',
    'Seleriefrei'
  ];
  final Set<String> _selectedLabels = {};

  Future<void> _saveRecipe() async {
    if (_titleController.text.isEmpty) return;
    
    final appDir = await getApplicationDocumentsDirectory();
    final recipesDir = Directory('${appDir.path}/recipes');
    if (!await recipesDir.exists()) {
      await recipesDir.create();
    }

    final recipeData = {
      'title': _titleController.text,
      'content': _contentController.text,
      'labels': _selectedLabels.toList(),
    };
    final file = File('${recipesDir.path}/${_titleController.text}.json');
    await file.writeAsString(jsonEncode(recipeData));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rezept gespeichert!'))
    );
    
    _titleController.clear();
    _contentController.clear();
    setState(() => _selectedLabels.clear());
  }

  void _toggleLabel(String label) {
    setState(() {
      if (_selectedLabels.contains(label)) {
        _selectedLabels.remove(label);
      } else {
        _selectedLabels.add(label);
      }
    });
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
              labelStyle: TextStyle(color: Color.fromARGB(255, 12, 90, 180)),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Labels:', style: TextStyle(
                  color: const Color.fromARGB(255, 12, 90, 180),
                  fontWeight: FontWeight.bold,
                )),
                Wrap(
                  spacing: 8,
                  children: _availableLabels.map((label) {
                    return FilterChip(
                      label: Text(label),
                      selected: _selectedLabels.contains(label),
                      onSelected: (_) => _toggleLabel(label),
                      selectedColor: const Color.fromARGB(255, 12, 90, 180).withOpacity(0.2),
                      checkmarkColor: const Color.fromARGB(255, 12, 90, 180),
                      labelStyle: TextStyle(
                        color: _selectedLabels.contains(label)
                          ? const Color.fromARGB(255, 12, 90, 180)
                          : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.format_bold),
                      onPressed: () {
                        final selection = _contentController.selection;
                        _contentController.text = _contentController.text.replaceRange(
                          selection.start,
                          selection.end,
                          '**${selection.textInside(_contentController.text)}**'
                        );
                        _contentController.selection = selection.copyWith(
                          baseOffset: selection.start + 2,
                          extentOffset: selection.end + 2
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.format_italic),
                      onPressed: () {
                        final selection = _contentController.selection;
                        _contentController.text = _contentController.text.replaceRange(
                          selection.start,
                          selection.end,
                          '_${selection.textInside(_contentController.text)}_'
                        );
                        _contentController.selection = selection.copyWith(
                          baseOffset: selection.start + 1,
                          extentOffset: selection.end + 1
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.format_underline),
                      onPressed: () {
                        final selection = _contentController.selection;
                        _contentController.text = _contentController.text.replaceRange(
                          selection.start,
                          selection.end,
                          '<u>${selection.textInside(_contentController.text)}</u>'
                        );
                        _contentController.selection = selection.copyWith(
                          baseOffset: selection.start + 3,
                          extentOffset: selection.end + 3
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: 'Rezept eingeben...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        inherit: false,
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
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

class MyRecipesTab extends StatefulWidget {
  const MyRecipesTab({super.key});

  @override
  State<MyRecipesTab> createState() => _MyRecipesTabState();
}

class _MyRecipesTabState extends State<MyRecipesTab> {
  List<FileSystemEntity> _recipes = [];
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() => _isLoading = true);
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final recipesDir = Directory('${appDir.path}/recipes');
      if (await recipesDir.exists()) {
        final files = await recipesDir.list().toList();
        setState(() => _recipes = files.whereType<File>().toList());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden: ${e.toString()}'))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<FileSystemEntity>> _getFilteredRecipes() async {
    if (_searchQuery.isEmpty) return _recipes;
    
    final filtered = <FileSystemEntity>[];
    for (final file in _recipes) {
      try {
        final jsonString = await File(file.path).readAsString();
        final recipeData = jsonDecode(jsonString);
        final titleMatch = recipeData['title'].toString().toLowerCase()
          .contains(_searchQuery.toLowerCase());
        final labelMatch = recipeData['labels'] != null && 
          (recipeData['labels'] as List).any((label) => 
            label.toString().toLowerCase().contains(_searchQuery.toLowerCase()));
        
        if (titleMatch || labelMatch) {
          filtered.add(file);
        }
      } catch (e) {
        // Fallback to filename if JSON parsing fails
        if (file.path.toLowerCase().contains(_searchQuery.toLowerCase())) {
          filtered.add(file);
        }
      }
    }
    return filtered;
  }

  List<TextSpan> _parseContent(String text) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'(\*\*.*?\*\*|_.*?_|<u>.*?</u>)');
    int currentIndex = 0;
    
    for (final match in pattern.allMatches(text)) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }
      
      final matchedText = match.group(0)!;
      if (matchedText.startsWith('**')) {
        spans.add(TextSpan(
          text: matchedText.substring(2, matchedText.length - 2),
          style: const TextStyle(fontWeight: FontWeight.bold)
        ));
      } else if (matchedText.startsWith('_')) {
        spans.add(TextSpan(
          text: matchedText.substring(1, matchedText.length - 1),
          style: const TextStyle(fontStyle: FontStyle.italic)
        ));
      } else if (matchedText.startsWith('<u>')) {
        spans.add(TextSpan(
          text: matchedText.substring(3, matchedText.length - 4),
          style: const TextStyle(decoration: TextDecoration.underline)
        ));
      }
      
      currentIndex = match.end;
    }
    
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }
    
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              labelText: 'Rezepte suchen',
              labelStyle: TextStyle(color: const Color.fromARGB(255, 12, 90, 180)),
              prefixIcon: Icon(Icons.search, color: const Color.fromARGB(255, 12, 90, 180)),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<FileSystemEntity>>(
            future: _getFilteredRecipes(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final filtered = snapshot.data!;
              return filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty 
                            ? 'Keine Rezepte vorhanden' 
                            : 'Keine passenden Rezepte',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final file = filtered[index];
                      final name = file.path.split('/').last.replaceAll('.json', '');
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(name, style: TextStyle(color: const Color.fromARGB(255, 12, 90, 180))),
                          onTap: () => _showRecipeDialog(context, file, name),
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

  Future<void> _showRecipeDialog(BuildContext context, FileSystemEntity file, String name) async {
    try {
      final jsonString = await File(file.path).readAsString();
      final recipeData = jsonDecode(jsonString);
      if (!mounted) return;
      
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(recipeData['title']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recipeData['labels'] != null && recipeData['labels'].isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Labels:', style: TextStyle(
                        color: const Color.fromARGB(255, 12, 90, 180),
                        fontWeight: FontWeight.bold,
                      )),
                      Wrap(
                        spacing: 8,
                        children: (recipeData['labels'] as List).map((label) {
                          return Chip(
                            label: Text(label),
                            backgroundColor: const Color.fromARGB(255, 12, 90, 180).withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: const Color.fromARGB(255, 12, 90, 180),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: _parseContent(recipeData['content']),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Schließen'),
            ),
            TextButton(
              onPressed: () => _confirmDelete(context, file),
              child: const Text('Löschen', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Öffnen des Rezepts'))
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, FileSystemEntity file) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rezept löschen'),
        content: const Text('Möchten Sie dieses Rezept wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      try {
        await File(file.path).delete();
        await _loadRecipes();
        if (mounted) {
          Navigator.of(context).pop(); // Schließt das Löschdialogfenster
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rezept gelöscht!'))
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fehler beim Löschen'))
          );
        }
      }
    }
  }
}