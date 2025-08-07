import 'dart:convert';
import 'package:flora_desktop_app/providers/auth_provider.dart';
import 'package:flora_desktop_app/providers/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flora_desktop_app/layouts/constants.dart';
import 'package:flora_desktop_app/providers/product_provider.dart';

Future<bool?> showEditProductDialog(
  BuildContext context,
  Product product,
  List<Category> categories,
) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return EditProductDialog(product: product, categories: categories);
    },
  );
}

class EditProductDialog extends StatefulWidget {
  final Product product;
  final List<Category> categories;

  const EditProductDialog({
    Key? key,
    required this.product,
    required this.categories,
  }) : super(key: key);

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  late int? selectedCategoryId;
  late bool isNew;
  late bool isFeatured;
  late bool active;
  late bool isAvailable;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(
      text: widget.product.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );

    selectedCategoryId = widget.product.categoryId;
    isNew = widget.product.isNew;
    isFeatured = widget.product.isFeatured;
    active = widget.product.active;
    isAvailable = widget.product.isAvailable;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> updateProduct() async {
    setState(() {
      isUpdating = true;
    });

    try {
      final _headers = AuthProvider.getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/Product/${widget.product.id}'),
        headers: _headers,
        body: json.encode({
          'name': _nameController.text,
          'description': _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          'price': double.parse(_priceController.text),
          'categoryId': selectedCategoryId,
          'isNew': isNew,
          'isFeatured': isFeatured,
          'active': active,
          'isAvailable': isAvailable,
          'occasionId': widget.product.occasionId,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Product'),
      content: Container(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                  errorText: _nameController.text.trim().isEmpty
                      ? 'Product name is required'
                      : null,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Product name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price (KM)',
                  border: OutlineInputBorder(),
                  errorText: _priceController.text.trim().isEmpty
                      ? 'Price is required'
                      : (double.tryParse(_priceController.text) == null ||
                            double.tryParse(_priceController.text)! <= 0)
                      ? 'Please enter a valid price'
                      : null,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  errorText: selectedCategoryId == null
                      ? 'Category is required'
                      : null,
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null) {
                    return 'Category is required';
                  }
                  return null;
                },
                items: widget.categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategoryId = value;
                  });
                },
              ),
              SizedBox(height: 16),

              Text(
                'Status:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE91E63),
                ),
              ),
              SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('New'),
                      value: isNew,
                      onChanged: (value) {
                        setState(() {
                          isNew = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Color(0xFFE91E63),
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('Featured'),
                      value: isFeatured,
                      onChanged: (value) {
                        setState(() {
                          isFeatured = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Color(0xFFE91E63),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('Active'),
                      value: active,
                      onChanged: (value) {
                        setState(() {
                          active = value ?? true;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Color(0xFFE91E63),
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('Available'),
                      value: isAvailable,
                      onChanged: (value) {
                        setState(() {
                          isAvailable = value ?? true;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Color(0xFFE91E63),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isUpdating ? null : () => Navigator.of(context).pop(false),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isUpdating
              ? null
              : () async {
                  // Validation
                  if (_nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Product name is required'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (_priceController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Price is required'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final price = double.tryParse(_priceController.text);
                  if (price == null || price < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a valid price'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (selectedCategoryId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Category is required'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  await updateProduct();
                },
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE91E63)),
          child: isUpdating
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
