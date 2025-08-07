import 'package:flutter/material.dart';
import 'package:flora_desktop_app/providers/base_provider.dart';

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['categoryId'] ?? json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class CategoryManagementDialog extends StatefulWidget {
  final List<Category> initialCategories;

  const CategoryManagementDialog({Key? key, required this.initialCategories})
    : super(key: key);

  @override
  _CategoryManagementDialogState createState() =>
      _CategoryManagementDialogState();
}

class _CategoryManagementDialogState extends State<CategoryManagementDialog> {
  late List<Category> categories;
  final TextEditingController _newCategoryController = TextEditingController();
  final TextEditingController _editCategoryController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    categories = List.from(widget.initialCategories);
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    _editCategoryController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final name = _newCategoryController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await BaseApiService.post<Map<String, dynamic>>(
        '/Category',
        {'name': name},
        (data) => data as Map<String, dynamic>,
      );

      if (response.containsKey('categoryId') || response.containsKey('id')) {
        final newCategory = Category.fromJson(response);
        setState(() {
          categories.add(newCategory);
          _newCategoryController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to add category: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add category: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateCategory(Category category) async {
    final name = _editCategoryController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await BaseApiService.put<Map<String, dynamic>>(
        '/Category/${category.id}',
        {'categoryId': category.id, 'name': name},
        (data) => data as Map<String, dynamic>,
      );

      setState(() {
        final index = categories.indexWhere((c) => c.id == category.id);
        if (index >= 0) {
          categories[index] = Category(id: category.id, name: name);
        }
        Navigator.pop(context); // Close the edit dialog
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to update category: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update category: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteCategory(Category category) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final success = await BaseApiService.delete('/Category/${category.id}');
      if (success) {
        setState(() {
          categories.removeWhere((c) => c.id == category.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to delete category: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete category: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showEditDialog(Category category) {
    _editCategoryController.text = category.name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Category'),
          content: TextField(
            controller: _editCategoryController,
            decoration: InputDecoration(
              labelText: 'Category Name',
              hintText: 'Enter category name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _updateCategory(category),
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(Category category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Category'),
          content: Text(
            'Are you sure you want to delete "${category.name}"? This may affect products using this category.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCategory(category);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manage Categories',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: Icon(Icons.close),
                  splashRadius: 20,
                ),
              ],
            ),
            SizedBox(height: 16),
            if (errorMessage != null)
              Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCategoryController,
                    decoration: InputDecoration(
                      labelText: 'New Category',
                      hintText: 'Enter category name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: isLoading ? null : _addCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text('Add'),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Existing Categories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Flexible(
              child: Container(
                constraints: BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      title: Text(category.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(category),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteConfirmation(category),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
