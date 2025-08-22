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
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Jednostavan header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reservation Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.pinkAccent,
                    size: 24,
                  ),
                  onPressed: () {
                    final adminLayoutState = AdminMainLayout.of(context);
                    adminLayoutState.showCustomChild(
                      const ReservationsScreen(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Info section
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.pink.shade50,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.pink.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.pink.shade600,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Event Information',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.pink.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    _buildDetailRow(
                                      'Reservation date:',
                                      DateFormat(
                                        'dd.MM.yyyy',
                                      ).format(widget.reservation.eventDate),
                                      Icons.calendar_today,
                                    ),
                                    _buildDetailRow(
                                      'Event type:',
                                      widget.reservation.eventType,
                                      Icons.celebration,
                                    ),
                                    _buildDetailRow(
                                      'Venue type:',
                                      widget.reservation.venueType,
                                      Icons.location_city,
                                    ),
                                    _buildDetailRow(
                                      'Number of guests:',
                                      widget.reservation.numberOfGuests
                                          .toString(),
                                      Icons.people,
                                    ),
                                    _buildDetailRow(
                                      'Number of tables:',
                                      widget.reservation.numberOfTables
                                          .toString(),
                                      Icons.table_restaurant,
                                    ),
                                    _buildDetailRow(
                                      'Decoration theme:',
                                      widget.reservation.themeOrColors,
                                      Icons.palette,
                                    ),
                                    _buildDetailRow(
                                      'Amount:',
                                      '${widget.reservation.budget.toStringAsFixed(2)} KM',
                                      Icons.attach_money,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Decoration ideas section
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.pink.shade50,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.pink.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.lightbulb_outline,
                                              color: Colors.pink.shade600,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Decoration Ideas',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.pink.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (_selectedDecoration != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.pink.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.pink.shade300,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.pink,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 6),
                                                const Text(
                                                  'Client Selected',
                                                  style: TextStyle(
                                                    color: Colors.pink,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    if (_isLoading)
                                      const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.pink,
                                        ),
                                      )
                                    else if (_suggestions.isEmpty)
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Colors.grey.shade600,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'No decoration ideas yet',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: _suggestions.map((
                                          suggestion,
                                        ) {
                                          // Check if this is the selected suggestion
                                          final bool isSelected =
                                              _selectedDecoration != null &&
                                              _selectedDecoration!
                                                      .decorationSuggestionId ==
                                                  suggestion.id;

                                          return Card(
                                            margin: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            color: isSelected
                                                ? Colors.pink.shade50
                                                : null,
                                            shape: isSelected
                                                ? RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    side: BorderSide(
                                                      color:
                                                          Colors.pink.shade300,
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
                                                          suggestion
                                                              .description,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                isSelected
                                                                ? FontWeight
                                                                      .bold
                                                                : FontWeight
                                                                      .normal,
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
                                                        tooltip:
                                                            'Obriši sugestiju',
                                                      ),
                                                      if (isSelected)
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 12,
                                                                vertical: 6,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.pink,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  20,
                                                                ),
                                                          ),
                                                          child: const Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                Icons.check,
                                                                color: Colors
                                                                    .white,
                                                                size: 16,
                                                              ),
                                                              SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text(
                                                                'CLIENT SELECTION',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
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
                                                            color: Colors
                                                                .grey[200],
                                                            child: const Icon(
                                                              Icons
                                                                  .broken_image,
                                                              color:
                                                                  Colors.grey,
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
                                                          color: Colors.pink,
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Text(
                                                          'Selected on: ${DateFormat('dd.MM.yyyy - HH:mm').format(_selectedDecoration!.createdAt)}',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey
                                                                .shade700,
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
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                          color: Colors
                                                              .grey
                                                              .shade700,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              12,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors
                                                              .pink
                                                              .shade50,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          border: Border.all(
                                                            color: Colors
                                                                .pink
                                                                .shade200,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          _selectedDecoration!
                                                              .comments!,
                                                          style: TextStyle(
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey
                                                                .shade800,
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Location section
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.pink.shade50,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.pink.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.pink.shade600,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Location Details',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.pink.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.place,
                                            color: Colors.grey.shade600,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              widget.reservation.location,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey.shade800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Special requests section
                              if (widget.reservation.specialRequests != null &&
                                  widget
                                      .reservation
                                      .specialRequests!
                                      .isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.pink.shade50,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.pink.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.note_alt,
                                            color: Colors.pink.shade600,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Special Instructions',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.pink.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        child: Text(
                                          widget.reservation.specialRequests!,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade800,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.pink.shade100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: Colors.pink.shade400,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Want to send decoration ideas?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.send, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Send Ideas',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.pink.shade400, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                  children: [
                    TextSpan(
                      text: label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: ' $value',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ),
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
