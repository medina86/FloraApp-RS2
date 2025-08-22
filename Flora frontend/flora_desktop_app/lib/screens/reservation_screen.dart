import 'package:flora_desktop_app/layouts/constants.dart';
import 'package:flora_desktop_app/models/reservation_model.dart';
import 'package:flora_desktop_app/models/user_model.dart';
import 'package:flora_desktop_app/providers/auth_provider.dart';
import 'package:flora_desktop_app/providers/user_provider.dart';
import 'package:flora_desktop_app/screens/reservation_details_screen.dart';
import 'package:flora_desktop_app/layouts/admin_main_layout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({Key? key}) : super(key: key);

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<Reservation> _allReservations = [];
  List<Reservation> _filteredReservations = [];
  Map<int, String> _userNames = {}; // Cache za korisničke imena
  bool _isLoading = true;
  bool _isDeleting = false;
  String? _error;
  String? _selectedDateFilter;

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(

        Uri.parse('$baseUrl/DecorationRequest?RetrieveAll=true'),
        headers: AuthProvider.getHeaders(),
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        List<dynamic> reservationsJsonList = [];

        if (decodedData is List) {
          reservationsJsonList = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('items')) {
          if (decodedData['items'] is List) {
            reservationsJsonList = decodedData['items'];
          } else {
            reservationsJsonList = [];
          }
        } else {
          // Ako je format neočekivan, tretirajte kao praznu listu
          reservationsJsonList = [];
        }

        setState(() {
          _allReservations = reservationsJsonList.map((item) {
            return Reservation.fromJson(item);
          }).toList();
          _allReservations.sort(
            (a, b) => a.eventDate.compareTo(b.eventDate),
          ); // Sort by date
          _filteredReservations = List.from(
            _allReservations,
          ); // Inicijalno svi su filtrirani
        });

        // Dohvati korisničke ime
        await _fetchUserNames();
      } else {
        setState(() {
          _error = 'Failed to load reservations: ${response.statusCode}';
        });
        print(
          'Failed to load reservations: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
      });
      print('Error fetching reservations: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserNames() async {
    // Dohvati unique user ID-jeve
    Set<int> userIds = _allReservations.map((r) => r.userId).toSet();

    for (int userId in userIds) {
      try {
        final user = await UserApiService.getUserById(userId);
        setState(() {
          _userNames[userId] = user.fullName;
        });
      } catch (e) {
        print('Error fetching user $userId: $e');
        setState(() {
          _userNames[userId] = 'Unknown User';
        });
      }
    }
  }

  void _applyDateFilter(String? date) {
    setState(() {
      _selectedDateFilter = date;
      if (date == null) {
        _filteredReservations = List.from(_allReservations);
      } else {
        _filteredReservations = _allReservations
            .where(
              (res) => DateFormat('dd.MM.yyyy').format(res.eventDate) == date,
            )
            .toList();
      }
    });
  }

  void _confirmDeleteReservation(Reservation reservation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete reservation for "${reservation.eventType}"?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteReservation(reservation);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteReservation(Reservation reservation) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/DecorationRequest/${reservation.id}'),
        headers: AuthProvider.getHeaders(),
      );

      if (response.statusCode == 200) {
        setState(() {
          _allReservations.removeWhere((r) => r.id == reservation.id);
          _filteredReservations.removeWhere((r) => r.id == reservation.id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reservation deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to delete reservation: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting reservation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> uniqueDates =
        _allReservations
            .map((res) => DateFormat('dd.MM.yyyy').format(res.eventDate))
            .toSet()
            .toList()
          ..sort((a, b) {
            final dateA = DateFormat('dd.MM.yyyy').parse(a);
            final dateB = DateFormat('dd.MM.yyyy').parse(b);
            return dateA.compareTo(dateB);
          });

    return Stack(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reservations',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 170, 46, 92),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage decoration requests and reservations',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: DropdownButton<String>(
                  value: _selectedDateFilter,
                  hint: Text('Choose date'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Dates'),
                    ),
                    ...uniqueDates.map((date) {
                      return DropdownMenuItem<String>(
                        value: date,
                        child: Text(date),
                      );
                    }).toList(),
                  ],
                  onChanged: _applyDateFilter,
                  dropdownColor: Colors.white,
                  underline: Container(height: 1, color: Colors.pink),
                  iconEnabledColor: Colors.pink,
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.pink),
                    )
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          ElevatedButton(
                            onPressed: _fetchReservations,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _filteredReservations.isEmpty
                  ? Center(child: Text('No reservations found.'))
                  : Expanded(
                      child: Column(
                        children: [
                          // Header tabele
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.pink.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.pink.shade100),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.pink.shade400,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Client',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.event,
                                  color: Colors.pink.shade400,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Event Date',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.location_on,
                                  color: Colors.pink.shade400,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Location',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.celebration,
                                  color: Colors.pink.shade400,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Event Type',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 100), // Prostor za dugmad
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Lista rezervacija
                          Expanded(
                            child: ListView.builder(
                              itemCount: _filteredReservations.length,
                              itemBuilder: (context, index) {
                                final reservation =
                                    _filteredReservations[index];
                                final userName =
                                    _userNames[reservation.userId] ??
                                    'Loading...';

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        // Avatar i ime korisnika
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor:
                                                    Colors.pink.shade100,
                                                child: Text(
                                                  userName.isNotEmpty &&
                                                          userName !=
                                                              'Loading...'
                                                      ? userName
                                                            .split(' ')
                                                            .map((e) => e[0])
                                                            .join()
                                                            .toUpperCase()
                                                      : '?',
                                                  style: TextStyle(
                                                    color: Colors.pink.shade700,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      userName,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      'ID: ${reservation.userId}',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey
                                                            .shade600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Datum
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                DateFormat(
                                                  'dd.MM.yyyy',
                                                ).format(reservation.eventDate),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                DateFormat(
                                                  'EEEE',
                                                ).format(reservation.eventDate),
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Lokacija
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            reservation.location,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // Tip događaja
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: Colors.blue.shade200,
                                              ),
                                            ),
                                            child: Text(
                                              reservation.eventType,
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Dugmad
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.info_outline,
                                                color: Colors.pink.shade400,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                final adminLayoutState = context
                                                    .findAncestorStateOfType<
                                                      AdminMainLayoutState
                                                    >();
                                                if (adminLayoutState != null) {
                                                  adminLayoutState
                                                      .showCustomChild(
                                                        ReservationDetailsScreen(
                                                          reservation:
                                                              reservation,
                                                        ),
                                                      );
                                                }
                                              },
                                              tooltip: 'View details',
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete_outline,
                                                color: Colors.red.shade400,
                                                size: 20,
                                              ),
                                              onPressed: () =>
                                                  _confirmDeleteReservation(
                                                    reservation,
                                                  ),
                                              tooltip: 'Delete reservation',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
        if (_isDeleting)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.pink),
            ),
          ),
      ],
    );
  }
}
