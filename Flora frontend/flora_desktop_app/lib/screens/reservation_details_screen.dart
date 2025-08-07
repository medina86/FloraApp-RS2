import 'package:flora_desktop_app/layouts/admin_main_layout.dart';
import 'package:flora_desktop_app/layouts/constants.dart';
import 'package:flora_desktop_app/models/decoration_selection_model.dart';
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
  DecorationSelection? _selectedDecoration;
  bool _isLoadingSelection = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
    _fetchSelectedDecoration();
  }

  Future<void> _fetchSelectedDecoration() async {
    setState(() {
      _isLoadingSelection = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/DecorationSelection/byRequest/${widget.reservation.id}',
        ),
        headers: AuthProvider.getHeaders(),
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        setState(() {
          _selectedDecoration = DecorationSelection.fromJson(data);
        });
        print('Found selected decoration: $_selectedDecoration');
      } else if (response.statusCode != 404) {
        // 404 is expected if no selection exists
        print('Error fetching decoration selection: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching decoration selection: $e');
    } finally {
      setState(() {
        _isLoadingSelection = false;
      });
    }
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Decoration Ideas:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_selectedDecoration != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.green.shade300,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'Client has selected a decoration',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
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
                                    // Check if this is the selected suggestion
                                    final bool isSelected =
                                        _selectedDecoration != null &&
                                        _selectedDecoration!
                                                .decorationSuggestionId ==
                                            suggestion.id;

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      color: isSelected
                                          ? Colors.green.shade50
                                          : null,
                                      shape: isSelected
                                          ? RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              side: BorderSide(
                                                color: Colors.green.shade300,
                                                width: 2,
                                              ),
                                            )
                                          : null,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    suggestion.description,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                                // Dodajemo dugme za brisanje
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    color: Color.fromARGB(
                                                      255,
                                                      170,
                                                      46,
                                                      92,
                                                    ),
                                                  ),
                                                  onPressed: () =>
                                                      _confirmDelete(
                                                        suggestion,
                                                      ),
                                                  tooltip: 'Obriši sugestiju',
                                                ),
                                                if (isSelected)
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.check,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          'CLIENT SELECTION',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
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
                                            if (isSelected) ...[
                                              const SizedBox(height: 16),
                                              const Divider(),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.calendar_today,
                                                    size: 16,
                                                    color: Colors.green,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Selected on: ${DateFormat('dd.MM.yyyy - HH:mm').format(_selectedDecoration!.createdAt)}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              if (_selectedDecoration!
                                                          .comments !=
                                                      null &&
                                                  _selectedDecoration!
                                                      .comments!
                                                      .isNotEmpty) ...[
                                                Text(
                                                  'Client Comments:',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          Colors.green.shade200,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    _selectedDecoration!
                                                        .comments!,
                                                    style: TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade800,
                                                    ),
                                                  ),
                                                ),
                                              ],
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Send Ideas'),
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

  // Funkcija za brisanje dekoracione sugestije
  Future<void> _deleteDecorationSuggestion(int suggestionId) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final url = '$baseUrl/DecorationSuggestion/$suggestionId';
      final response = await http.delete(
        Uri.parse(url),
        headers: AuthProvider.getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Uspješno brisanje
        setState(() {
          _suggestions.removeWhere(
            (suggestion) => suggestion.id == suggestionId,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dekoraciona sugestija je uspješno obrisana'),
            backgroundColor: Color.fromARGB(255, 170, 46, 92),
          ),
        );
      } else {
        // Greška pri brisanju
        throw Exception('Greška pri brisanju: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška pri brisanju: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  // Funkcija za potvrdu brisanja
  void _confirmDelete(DecorationSuggestion suggestion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potvrda brisanja'),
          content: const Text(
            'Da li ste sigurni da želite obrisati ovu dekoracionu sugestiju?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Odustani'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteDecorationSuggestion(suggestion.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Obriši'),
            ),
          ],
        );
      },
    );
  }
}
