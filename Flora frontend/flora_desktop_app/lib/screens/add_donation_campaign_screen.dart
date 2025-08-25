import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../layouts/constants.dart';
import '../layouts/admin_main_layout.dart';
import '../providers/auth_provider.dart';
import '../models/donation_campaign_model.dart';

class AddDonationCampaignScreen extends StatefulWidget {
  final DonationCampaign? campaign; // For editing existing campaign

  const AddDonationCampaignScreen({Key? key, this.campaign}) : super(key: key);

  @override
  State<AddDonationCampaignScreen> createState() =>
      _AddDonationCampaignScreenState();
}

class _AddDonationCampaignScreenState extends State<AddDonationCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  DateTime? _selectedEndDate;
  XFile? _selectedImage;
  final _imagePicker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool get _isEditMode => widget.campaign != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _populateFieldsForEdit();
    }
  }

  void _populateFieldsForEdit() {
    final campaign = widget.campaign!;
    _titleController.text = campaign.title;
    _descriptionController.text = campaign.description;
    _selectedEndDate = campaign.endDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!mounted) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedEndDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (!mounted) return;

    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    if (!mounted) return;
    
    // Only allow image picking for new campaigns, not for editing
    if (_isEditMode) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _submitCampaign() async {
    if (!mounted) return;

    if (!_formKey.currentState!.validate()) return;
    if (_selectedEndDate == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an end date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = _isEditMode
          ? Uri.parse('$baseUrl/DonationCampaign/${widget.campaign!.id}')
          : Uri.parse('$baseUrl/DonationCampaign');

      final method = _isEditMode ? 'PUT' : 'POST';

      var request = http.MultipartRequest(method, uri)
        ..headers.addAll(AuthProvider.getHeaders())
        ..fields['title'] = _titleController.text
        ..fields['description'] = _descriptionController.text
        ..fields['endDate'] = _selectedEndDate!.toIso8601String();

      // Only add image for new campaigns, not for editing
      if (_selectedImage != null && !_isEditMode) {
        final file = await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
        );
        request.files.add(file);
      }

      final response = await request.send();

      if (!mounted) return;

      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Campaign updated successfully'
                  : 'Campaign created successfully',
            ),
          ),
        );

        final adminLayoutState = context
            .findAncestorStateOfType<AdminMainLayoutState>();
        if (adminLayoutState != null) {
          adminLayoutState.setSelectedIndex(3); // Go back to donations list
        } else {
          Navigator.of(context).pop(true); // Fallback
        }
      } else {
        throw Exception(
          'Failed to ${_isEditMode ? "update" : "create"} campaign: $responseString',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error ${_isEditMode ? "updating" : "creating"} campaign: $e',
          ),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.pink),
                    tooltip: 'Back',
                    onPressed: () {
                      final adminLayoutState = context
                          .findAncestorStateOfType<AdminMainLayoutState>();
                      if (adminLayoutState != null) {
                        adminLayoutState.setSelectedIndex(3);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isEditMode ? 'Edit Campaign' : 'Create New Campaign',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD81B60), // Pink title
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Campaign Title',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'End Date',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _selectedEndDate != null
                                  ? DateFormat(
                                      'dd.MM.yyyy',
                                    ).format(_selectedEndDate!)
                                  : 'Select end date',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Only show image picker for new campaigns, not for editing
                        if (!_isEditMode)
                          InkWell(
                            onTap: _pickImage,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Campaign Image',
                                border: OutlineInputBorder(),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _selectedImage != null
                                        ? Icons.check_circle
                                        : Icons.add_photo_alternate,
                                    color: _selectedImage != null
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedImage != null
                                        ? 'Image selected: ${_selectedImage!.name}'
                                        : 'Click to select image',
                                    style: TextStyle(
                                      color: _selectedImage != null
                                          ? Colors.black
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),
                        Center(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitCampaign,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 16,
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : Text(
                                    _isEditMode
                                        ? 'Update Campaign'
                                        : 'Create Campaign',
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
