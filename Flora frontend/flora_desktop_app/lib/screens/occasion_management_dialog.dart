import 'package:flutter/material.dart';
import 'package:flora_desktop_app/providers/base_provider.dart';

class Occasion {
  final int id;
  final String name;

  Occasion({required this.id, required this.name});

  factory Occasion.fromJson(Map<String, dynamic> json) {
    return Occasion(
      id: json['occasionId'] ?? json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class OccasionManagementDialog extends StatefulWidget {
  final List<Occasion> initialOccasions;

  const OccasionManagementDialog({Key? key, required this.initialOccasions})
    : super(key: key);

  @override
  _OccasionManagementDialogState createState() =>
      _OccasionManagementDialogState();
}

class _OccasionManagementDialogState extends State<OccasionManagementDialog> {
  late List<Occasion> occasions;
  final TextEditingController _newOccasionController = TextEditingController();
  final TextEditingController _editOccasionController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    occasions = List.from(widget.initialOccasions);
  }

  @override
  void dispose() {
    _newOccasionController.dispose();
    _editOccasionController.dispose();
    super.dispose();
  }

  Future<void> _addOccasion() async {
    final name = _newOccasionController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await BaseApiService.post<Map<String, dynamic>>(
        '/Occasion',
        {'name': name},
        (data) => data as Map<String, dynamic>,
      );

      if (response.containsKey('occasionId') || response.containsKey('id')) {
        final newOccasion = Occasion.fromJson(response);
        setState(() {
          occasions.add(newOccasion);
          _newOccasionController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Occasion added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to add occasion: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add occasion: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateOccasion(Occasion occasion) async {
    final name = _editOccasionController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await BaseApiService.put<Map<String, dynamic>>(
        '/Occasion/${occasion.id}',
        {'occasionId': occasion.id, 'name': name},
        (data) => data as Map<String, dynamic>,
      );

      setState(() {
        final index = occasions.indexWhere((o) => o.id == occasion.id);
        if (index >= 0) {
          occasions[index] = Occasion(id: occasion.id, name: name);
        }
        Navigator.pop(context); // Close the edit dialog
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Occasion updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to update occasion: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update occasion: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteOccasion(Occasion occasion) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final success = await BaseApiService.delete('/Occasion/${occasion.id}');
      if (success) {
        setState(() {
          occasions.removeWhere((o) => o.id == occasion.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Occasion deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to delete occasion: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete occasion: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showEditDialog(Occasion occasion) {
    _editOccasionController.text = occasion.name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Occasion'),
          content: TextField(
            controller: _editOccasionController,
            decoration: InputDecoration(
              labelText: 'Occasion Name',
              hintText: 'Enter occasion name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _updateOccasion(occasion),
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(Occasion occasion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Occasion'),
          content: Text(
            'Are you sure you want to delete "${occasion.name}"? This may affect products using this occasion.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteOccasion(occasion);
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
                  'Manage Occasions',
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
                    controller: _newOccasionController,
                    decoration: InputDecoration(
                      labelText: 'New Occasion',
                      hintText: 'Enter occasion name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: isLoading ? null : _addOccasion,
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
              'Existing Occasions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Flexible(
              child: Container(
                constraints: BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: occasions.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final occasion = occasions[index];
                    return ListTile(
                      title: Text(occasion.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(occasion),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteConfirmation(occasion),
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
