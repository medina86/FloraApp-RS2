import 'package:flutter/material.dart';
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/screens/decoration_request_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flora_mobile_app/providers/auth_provider.dart';
import 'package:flora_mobile_app/providers/decoration_selection_service.dart';
import 'package:flora_mobile_app/screens/decoration_confirmation_screen.dart';

class DecorationSuggestion {
  final int id;
  final int decorationRequestId;
  final String description;
  final String imageUrl;

  DecorationSuggestion({
    required this.id,
    required this.decorationRequestId,
    required this.description,
    required this.imageUrl,
  });

  factory DecorationSuggestion.fromJson(Map<String, dynamic> json) {
    return DecorationSuggestion(
      id: json['id'],
      decorationRequestId: json['decorationRequestId'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }
}

class DecorationSuggestionsScreen extends StatefulWidget {
  final DecorationRequest eventRequest;

  const DecorationSuggestionsScreen({Key? key, required this.eventRequest})
    : super(key: key);

  @override
  State<DecorationSuggestionsScreen> createState() =>
      _DecorationSuggestionsScreenState();
}

class _DecorationSuggestionsScreenState
    extends State<DecorationSuggestionsScreen> {
  List<DecorationSuggestion> _suggestions = [];
  bool _isLoading = true;
  String? _error;
  int? _selectedSuggestionId;
  bool _isSaving = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
    _checkExistingSelection();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingSelection() async {
    try {
      final selection =
          await DecorationSelectionService.getSelectionByRequestId(
            widget.eventRequest.id,
          );

      if (selection != null) {
        setState(() {
          _selectedSuggestionId = selection.decorationSuggestionId;
          _commentController.text = selection.comments ?? '';
        });
      }
    } catch (e) {
      print('Error checking existing selection: $e');
    }
  }

  Future<void> _fetchSuggestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/DecorationSuggestion?DecorationRequestId=${widget.eventRequest.id}',
        ),
        headers: AuthProvider.getHeaders(),
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        List<dynamic> suggestionsJsonList = [];

        if (decodedData is Map && decodedData.containsKey('items')) {
          if (decodedData['items'] is List) {
            suggestionsJsonList = decodedData['items'];
          } else {
            suggestionsJsonList = [];
          }
        } else if (decodedData is List) {
          suggestionsJsonList = decodedData;
        } else {
          suggestionsJsonList = [];
        }

        setState(() {
          _suggestions = suggestionsJsonList
              .map((item) => DecorationSuggestion.fromJson(item))
              .toList();
        });
      } else {
        setState(() {
          _error = 'Failed to load suggestions: ${response.statusCode}';
        });
        print(
          'Failed to load suggestions: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
      });
      print('Error fetching suggestions: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSelection() async {
    if (_selectedSuggestionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a decoration suggestion first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await DecorationSelectionService.selectDecoration(
        decorationRequestId: widget.eventRequest.id,
        decorationSuggestionId: _selectedSuggestionId!,
        userId: widget.eventRequest.userId,
        comments: _commentController.text.isEmpty
            ? null
            : _commentController.text,
      );

      // Find the selected suggestion
      final selectedSuggestion = _suggestions.firstWhere(
        (s) => s.id == _selectedSuggestionId,
        orElse: () => throw Exception('Selected suggestion not found'),
      );

      if (mounted) {
        // Navigate to confirmation screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DecorationConfirmationScreen(
              request: widget.eventRequest,
              selectedSuggestion: selectedSuggestion,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save selection: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Decoration Suggestions',
          style: TextStyle(
            color: AppColors.floralPink,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.white,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.floralPink),
              )
            : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    ElevatedButton(
                      onPressed: _fetchSuggestions,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _suggestions.isEmpty
            ? Center(child: Text('Nema predloga za ovaj događaj.'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Decoration Request',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.floralPink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Event Type: ${widget.eventRequest.eventType}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Event Date: ${widget.eventRequest.eventDate.toString().split(' ')[0]}',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    _suggestions.isEmpty
                        ? const SizedBox()
                        : const Text(
                            'Please select your preferred decoration option:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.floralPink,
                            ),
                          ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        final isSelected =
                            _selectedSuggestionId == suggestion.id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedSuggestionId = suggestion.id;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(
                                          color: AppColors.floralPink,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                            child: Image.network(
                                              suggestion.imageUrl,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(suggestion.description),
                                          ),
                                          if (isSelected)
                                            const Icon(
                                              Icons.check_circle,
                                              color: AppColors.floralPink,
                                              size: 24,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_suggestions.isNotEmpty) ...[
                      const Text(
                        'Additional Comments (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.floralPink,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _commentController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'Any special requests or comments for your selected decoration...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.floralPink,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: _suggestions.isEmpty || _isSaving
                            ? null
                            : _saveSelection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.floralPink,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                _selectedSuggestionId != null
                                    ? 'SAVE SELECTION'
                                    : 'SELECT A DECORATION',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
      // Removed custom BottomNavigationBar - using the one from MainLayout
    );
  }
}
