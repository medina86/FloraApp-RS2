import 'package:flutter/material.dart';
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/screens/decoration_request_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flora_mobile_app/providers/auth_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
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
        automaticallyImplyLeading: false, // MainLayout handles the back button
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
                    Text('My events'),
                    const SizedBox(height: 8),
                    Text(widget.eventRequest.eventType),
                    const SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      suggestion.imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
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
                                  Expanded(child: Text(suggestion.description)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.floralPink,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text(
                          'DONE',
                          style: TextStyle(
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
