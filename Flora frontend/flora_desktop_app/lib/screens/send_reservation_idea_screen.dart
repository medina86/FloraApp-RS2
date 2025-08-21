import 'package:flora_desktop_app/layouts/constants.dart';
import 'package:flora_desktop_app/layouts/admin_main_layout.dart';
import 'package:flora_desktop_app/models/reservation_model.dart';
import 'package:flora_desktop_app/providers/auth_provider.dart';
import 'package:flora_desktop_app/screens/reservation_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class SendIdeasScreen extends StatefulWidget {
  final Reservation reservation;

  const SendIdeasScreen({Key? key, required this.reservation})
    : super(key: key);

  @override
  State<SendIdeasScreen> createState() => _SendIdeasScreenState();
}

class _SendIdeasScreenState extends State<SendIdeasScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;
  bool _isLoading = true;
  List<dynamic> _suggestions = [];
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
  }

  Future<void> _fetchSuggestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/DecorationSuggestion/ByRequestId/${widget.reservation.id}',
        ),
        headers: AuthProvider.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> suggestions = json.decode(response.body);
        setState(() {
          _suggestions = suggestions;
        });
      } else {
        print('Failed to load suggestions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading suggestions: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_messageController.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message or select an image.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final String messageText = _messageController.text;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/DecorationSuggestion'),
      );
      final headers = AuthProvider.getHeaders();
      request.headers.addAll(headers);
      request.fields['DecorationRequestId'] = widget.reservation.id.toString();
      request.fields['Description'] = messageText;
      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'Image',
            _selectedImage!.path,
            filename: _selectedImage!.path.split('/').last,
          ),
        );
      }

      var response = await request.send();

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ideas sent successfully!')),
        );
        _messageController.clear();
        setState(() {
          _selectedImage = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send ideas: ${response.statusCode} ${responseBody}',
            ),
          ),
        );
        print('Failed to send ideas: ${response.statusCode} ${responseBody}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send ideas: $e')));
      print('Error sending ideas: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Send Ideas',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.pink),
                onPressed: () {
                  final adminLayoutState = context
                      .findAncestorStateOfType<AdminMainLayoutState>();
                  if (adminLayoutState != null) {
                    adminLayoutState.showCustomChild(
                      ReservationDetailsScreen(reservation: widget.reservation),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Message:'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _messageController,
                          maxLines: 5,
                          validator: (value) {
                            if (value != null &&
                                value.trim().isNotEmpty &&
                                value.trim().length < 5) {
                              return 'Message must be at least 5 characters if provided';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Send message',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                color: Colors.pink,
                                width: 2.0,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                color: Colors.red.shade400,
                                width: 1.0,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                color: Colors.red.shade400,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('Upload Suggestion Image:'),
                        const SizedBox(height: 16),
                        Center(
                          child: Column(
                            children: [
                              _selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.file(
                                        _selectedImage!,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.image,
                                        size: 50,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.upload_file),
                                label: const Text('Select Image'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _isSending ? null : _sendMessage,
                            child: _isSending
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text('Send'),
                          ),
                        ),
                      ],
                    ), 
                  ), 
                ), 
              ), 
            ), 
          ), 
        ], 
      ), 
    );
  }
}
