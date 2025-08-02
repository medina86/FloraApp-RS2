import 'package:flora_mobile_app/screens/suggested_decoration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/screens/decoration_request_screen.dart';
import 'package:flora_mobile_app/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class MyEventsScreen extends StatefulWidget {
  final int userId;

  const MyEventsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  List<DecorationRequest> _myEvents = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMyEvents();
  }

  Future<void> _fetchMyEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/DecorationRequest?userId=${widget.userId}'),
        headers: AuthProvider.getHeaders(),
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);

        List<dynamic> eventsJsonList = [];

        if (decodedData is Map && decodedData.containsKey('items')) {
          if (decodedData['items'] is List) {
            eventsJsonList = decodedData['items'];
          } else {
            eventsJsonList = [];
          }
        } else if (decodedData is List) {
          eventsJsonList = decodedData;
        } else if (decodedData is Map && decodedData.isNotEmpty) {
          eventsJsonList = [decodedData];
        } else if (decodedData is Map && decodedData.isEmpty) {
          eventsJsonList = [];
        }

        setState(() {
          _myEvents = eventsJsonList.map((item) => DecorationRequest(
            id:0,
            eventType: item['eventType'],
            eventDate: DateTime.parse(item['eventDate']),
            venueType: item['venueType'],
            numberOfGuests: item['numberOfGuests'],
            numberOfTables: item['numberOfTables'],
            themeOrColors: item['themeOrColors'],
            location: item['location'],
            specialRequests: item['specialRequests'],
            budget: item['budget'].toDouble(),
            userId: item['userId'],
          )).toList();
        });
      } else {
        setState(() {
          _error = 'Failed to load events: ${response.statusCode}';
        });
        print('Failed to load events: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
      });
      print('Error fetching events: $e');
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
        backgroundColor: AppColors.floralPink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Flora',
          style: TextStyle(
            fontFamily: 'DancingScript',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color:Colors.white,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.floralPink))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                        ElevatedButton(
                          onPressed: _fetchMyEvents,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _myEvents.isEmpty
                    ? Center(
                        child: Text(
                          'Nema zakazanih događaja.',
                        
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _myEvents.length,
                        itemBuilder: (context, index) {
                          final event = _myEvents[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${event.eventType} - ${DateFormat('dd.MM.yyyy').format(event.eventDate)}',
                                    
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Venue Type: ${event.venueType}'),
                                  Text('Guests: ${event.numberOfGuests}'),
                                  Text('Tables: ${event.numberOfTables}'),
                                  Text('Theme/Colors: ${event.themeOrColors}'),
                                  Text('Location: ${event.location}'),
                                  if (event.specialRequests != null && event.specialRequests!.isNotEmpty)
                                    Text('Special Requests: ${event.specialRequests}'),
                                  Text('Budget: ${event.budget.toStringAsFixed(2)} KM'),
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DecorationSuggestionsScreen(eventRequest: event),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.floralPink,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      ),
                                      child: const Text('View Suggestions'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.floralPink,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Implementirajte navigaciju za donji bar
        },
      ),
    );
  }
}