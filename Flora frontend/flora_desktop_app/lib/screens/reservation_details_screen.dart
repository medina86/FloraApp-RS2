import 'package:flora_desktop_app/layouts/admin_main_layout.dart';
import 'package:flora_desktop_app/layouts/constants.dart';
import 'package:flora_desktop_app/models/reservation_model.dart';
import 'package:flora_desktop_app/providers/auth_provider.dart';
import 'package:flora_desktop_app/screens/reservation_screen.dart';
import 'package:flora_desktop_app/screens/send_reservation_idea_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      id: json['id'] ?? 0,
      decorationRequestId: json['decorationRequestId'] ?? 0,
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'DecorationSuggestion(id: $id, decorationRequestId: $decorationRequestId, description: $description, imageUrl: $imageUrl)';
  }
}

class ReservationDetailsScreen extends StatefulWidget {
  final Reservation reservation;

  const ReservationDetailsScreen({Key? key, required this.reservation})
    : super(key: key);

  @override
  State<ReservationDetailsScreen> createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  bool _isLoading = true;
  List<DecorationSuggestion> _suggestions = [];

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
      final url = '$baseUrl/DecorationSuggestion';
      print(
        'Fetching suggestions for reservation ID: ${widget.reservation.id}',
      );

      final response = await http.get(
        Uri.parse(url).replace(
          queryParameters: {
            'filter': 'decorationRequestId=${widget.reservation.id}',
            'decorationRequestId': widget.reservation.id.toString(),
          },
        ),
        headers: AuthProvider.getHeaders(),
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        print('API Response structure: $decodedData');

        List<DecorationSuggestion> suggestions = [];
        if (decodedData is Map<String, dynamic>) {
          if (decodedData.containsKey('items')) {
            final items = decodedData['items'] as List;
            suggestions = items
                .map(
                  (item) => DecorationSuggestion.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .where(
                  (suggestion) =>
                      suggestion.decorationRequestId == widget.reservation.id,
                )
                .toList();
            print(
              'Filtered suggestions for request ID ${widget.reservation.id}: ${suggestions.length} items',
            );
          }
        } else if (decodedData is List) {
          suggestions = decodedData
              .map(
                (item) =>
                    DecorationSuggestion.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }

        print('Parsed suggestions: $suggestions');
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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reservation details'),
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.pinkAccent),
                  onPressed: () {
                    final adminLayoutState = AdminMainLayout.of(context);
                    adminLayoutState.showCustomChild(
                      const ReservationsScreen(),
                    );
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                'Reservation date:',
                                DateFormat(
                                  'dd.MM.yyyy',
                                ).format(widget.reservation.eventDate),
                              ),
                              _buildDetailRow(
                                'Event type:',
                                widget.reservation.eventType,
                              ),
                              _buildDetailRow(
                                'Venue type:',
                                widget.reservation.venueType,
                              ),
                              _buildDetailRow(
                                'Number of guests:',
                                widget.reservation.numberOfGuests.toString(),
                              ),
                              _buildDetailRow(
                                'Number of tables:',
                                widget.reservation.numberOfTables.toString(),
                              ),
                              _buildDetailRow(
                                'Decoration theme:',
                                widget.reservation.themeOrColors,
                              ),
                              _buildDetailRow(
                                'Amount:',
                                '${widget.reservation.budget.toStringAsFixed(2)} KM',
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Decoration Ideas:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_isLoading)
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.pink,
                                  ),
                                )
                              else if (_suggestions.isEmpty)
                                const Text('No decoration ideas yet')
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _suggestions.map((suggestion) {
                                    // Debug log for suggestion data
                                    print('Processing suggestion: $suggestion');
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              suggestion.description,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            if (suggestion
                                                .imageUrl
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 12),
                                              Image.network(
                                                suggestion.imageUrl,
                                                width: 200,
                                                height: 200,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Container(
                                                      width: 200,
                                                      height: 200,
                                                      color: Colors.grey[200],
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                              ),
                                            ],
                                            const SizedBox(height: 8),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Reservation address',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(widget.reservation.location),
                              const SizedBox(height: 20),
                              if (widget.reservation.specialRequests != null &&
                                  widget
                                      .reservation
                                      .specialRequests!
                                      .isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Special instructions:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(widget.reservation.specialRequests!),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final adminLayoutState = context
                          .findAncestorStateOfType<AdminMainLayoutState>();
                      if (adminLayoutState != null) {
                        adminLayoutState.showCustomChild(
                          SendIdeasScreen(reservation: widget.reservation),
                        );
                      }
                    },
                    child: const Text('Send Ideas'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Processing reservation... (Placeholder)',
                          ),
                        ),
                      );
                    },
                    child: const Text('Process'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: label),
            TextSpan(text: ' $value'),
          ],
        ),
      ),
    );
  }
}
