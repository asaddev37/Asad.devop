import 'package:flutter/material.dart';
import '../../database_helper.dart';

class CategoriesTaskPage extends StatefulWidget {
  final bool isDarkMode;
  final Color lightModeColor;
  final Color darkModeColor;
  final VoidCallback? onCategoriesChanged; // Add callback for category changes

  const CategoriesTaskPage({
    Key? key,
    required this.isDarkMode,
    required this.lightModeColor,
    required this.darkModeColor,
    this.onCategoriesChanged, // Optional callback
  }) : super(key: key);

  @override
  _CategoriesTaskPageState createState() => _CategoriesTaskPageState();
}

class _CategoriesTaskPageState extends State<CategoriesTaskPage> {
  final _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _categories = [];
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _dbHelper.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _addCategory(String name) async {
    if (name.isNotEmpty) {
      await _dbHelper.insertCategory({'name': name});
      await _loadCategories();
      _showSnackBar('Category added successfully');
      widget.onCategoriesChanged?.call(); // Notify listeners
    }
  }

  Future<void> _editCategory(int id, String currentName) async {
    _categoryController.text = currentName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          'Edit Category',
          style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
        ),
        content: TextField(
          controller: _categoryController,
          decoration: InputDecoration(
            hintText: 'Enter category name',
            hintStyle: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54),
          ),
          style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87)),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.updateCategory({'id': id, 'name': _categoryController.text});
              await _loadCategories();
              _showSnackBar('Category updated successfully');
              widget.onCategoriesChanged?.call(); // Notify listeners
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmFinalDeletion(int id, String name, bool deleteTasks) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          'Final Confirmation',
          style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
        ),
        content: Text(
          deleteTasks
              ? 'Are you absolutely sure you want to delete "$name" and all its tasks? This action cannot be undone.'
              : 'Are you absolutely sure you want to delete "$name"? Tasks will remain but lose their category. This action cannot be undone.',
          style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    ) ??
        false; // Return false if dialog is dismissed
  }

  Future<void> _deleteCategory(int id, {required bool deleteTasks}) async {
    final category = _categories.firstWhere((c) => c['id'] == id, orElse: () => {'name': 'Unknown'});
    final confirmed = await _confirmFinalDeletion(id, category['name'], deleteTasks);
    if (confirmed) {
      if (deleteTasks) {
        await _dbHelper.deleteTasksByCategory(id);
        await _dbHelper.deleteCategory(id);
        _showSnackBar('Category and its tasks deleted successfully');
      } else {
        await _dbHelper.deleteCategory(id); // Sets categoryId to null for tasks
        _showSnackBar('Category deleted successfully');
      }
      await _loadCategories();
      widget.onCategoriesChanged?.call(); // Notify listeners
    }
  }

  Future<void> _showDeleteOptions(int id) async {
    final category = _categories.firstWhere((c) => c['id'] == id, orElse: () => {'name': 'Unknown'});
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          'Delete "${category['name']}"',
          style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
        ),
        content: Text(
          'Choose an option:',
          style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(id, deleteTasks: false);
            },
            child: const Text('Delete Category Only', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(id, deleteTasks: true);
            },
            child: const Text('Delete Category and Tasks', style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87)),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDeleteCategory(int id, String name) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          'Delete "$name"',
          style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
        ),
        content: Text(
          'Choose an option:',
          style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'categoryOnly'),
            child: const Text('Delete Category Only', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'categoryAndTasks'),
            child: const Text('Delete Category and Tasks', style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: Text('Cancel', style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87)),
          ),
        ],
      ),
    );

    if (result == 'categoryOnly') {
      final confirmed = await _confirmFinalDeletion(id, name, false);
      if (confirmed) {
        await _dbHelper.deleteCategory(id);
        _showSnackBar('Category deleted successfully');
        widget.onCategoriesChanged?.call(); // Notify listeners
        return true;
      }
    } else if (result == 'categoryAndTasks') {
      final confirmed = await _confirmFinalDeletion(id, name, true);
      if (confirmed) {
        await _dbHelper.deleteTasksByCategory(id);
        await _dbHelper.deleteCategory(id);
        _showSnackBar('Category and its tasks deleted successfully');
        widget.onCategoriesChanged?.call(); // Notify listeners
        return true;
      }
    }
    return false; // Cancel or dialog dismissed
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87)),
        backgroundColor: widget.isDarkMode ? Colors.grey[800] : Colors.grey[300],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.isDarkMode
        ? [widget.darkModeColor, Colors.grey[800]!.withAlpha(78)]
        : [widget.lightModeColor, Colors.white.withAlpha(178)];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Categories',
          style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _categories.isEmpty
            ? Center(
          child: Text(
            'No categories yet!',
            style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87, fontSize: 16),
          ),
        )
            : ListView.builder(
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return Dismissible(
              key: Key(category['id'].toString()),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await _confirmDeleteCategory(category['id'], category['name']);
              },
              onDismissed: (direction) async {
                await _loadCategories();
              },
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
                child: ListTile(
                  title: Text(
                    category['name'],
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: 'Edit Category',
                        child: IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                          onPressed: () => _editCategory(category['id'], category['name']),
                        ),
                      ),
                      Tooltip(
                        message: 'Delete Category',
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _showDeleteOptions(category['id']),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Tooltip(
        message: 'Add New Category',
        child: FloatingActionButton(
          onPressed: () {
            _categoryController.clear();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
                title: Text(
                  'Add Category',
                  style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
                ),
                content: TextField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    hintText: 'Enter category name',
                    hintStyle: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                  style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black87),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87)),
                  ),
                  TextButton(
                    onPressed: () async {
                      await _addCategory(_categoryController.text);
                      Navigator.pop(context);
                    },
                    child: const Text('Add', style: TextStyle(color: Colors.green)),
                  ),
                ],
              ),
            );
          },
          child: Icon(
            Icons.add,
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
          backgroundColor: widget.isDarkMode ? widget.darkModeColor : widget.lightModeColor,
        ),
      ),
    );
  }
}