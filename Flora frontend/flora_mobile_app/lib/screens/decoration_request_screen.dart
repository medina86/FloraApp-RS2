import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flora_mobile_app/providers/auth_provider.dart';
import 'package:flora_mobile_app/layouts/constants.dart';

class DecorationRequest {
  final int id;
  String eventType;
  DateTime eventDate;
  String venueType;
  int numberOfGuests;
  int numberOfTables;
  String themeOrColors;
  String location;
  String? specialRequests;
  double budget;
  int userId;

  DecorationRequest({
    required this.id,
    required this.eventType,
    required this.eventDate,
    required this.venueType,
    required this.numberOfGuests,
    required this.numberOfTables,
    required this.themeOrColors,
    required this.location,
    this.specialRequests,
    required this.budget,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'EventType': eventType,
      'EventDate': eventDate.toIso8601String(),
      'VenueType': venueType,
      'NumberOfGuests': numberOfGuests,
      'NumberOfTables': numberOfTables,
      'ThemeOrColors': themeOrColors,
      'Location': location,
      'SpecialRequests': specialRequests,
      'Budget': budget,
      'UserId': userId,
    };
  }
}

class DecorationRequestScreen extends StatefulWidget {
  final int userId; // Prima userId od HomeScreen-a

  const DecorationRequestScreen({Key? key, required this.userId})
    : super(key: key);

  @override
  State<DecorationRequestScreen> createState() =>
      _DecorationRequestScreenState();
}

class _DecorationRequestScreenState extends State<DecorationRequestScreen> {
  final _formKey = GlobalKey<FormState>(); // Ključ za validaciju forme

  String? _selectedEventType;
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _venueTypeController = TextEditingController();
  final TextEditingController _numberOfGuestsController =
      TextEditingController();
  final TextEditingController _numberOfTablesController =
      TextEditingController();
  final TextEditingController _themeOrColorsController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _specialRequestsController =
      TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  DateTime? _selectedDate; // Čuva odabrani datum

  bool _isSubmitting = false; // Stanje za prikaz loading indikatora

  // Lista dostupnih tipova događaja za Dropdown
  final List<String> _eventTypes = [
    'Wedding',
    'Birthday',
    'Anniversary',
    'Corporate Event',
    'Baby Shower',
    'Other',
  ];

  // Funkcija za odabir datuma pomoću date pickera
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF06292), // Roza boja za date picker
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFF06292), // Roza boja za dugmad
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _eventDateController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(_selectedDate!);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSubmitting = true;
      });

      final request = DecorationRequest(
        id: 0,
        eventType: _selectedEventType!,
        eventDate: _selectedDate!,
        venueType: _venueTypeController.text,
        numberOfGuests: int.parse(_numberOfGuestsController.text),
        numberOfTables: int.parse(_numberOfTablesController.text),
        themeOrColors: _themeOrColorsController.text,
        location: _locationController.text,
        specialRequests: _specialRequestsController.text.isEmpty
            ? null
            : _specialRequestsController.text,
        budget: double.parse(_budgetController.text),
        userId: widget.userId,
      );

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/DecorationRequest'),
          headers: AuthProvider.getHeaders(),
          body: jsonEncode(request.toJson()),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Zahtev uspešno poslat!')),
          );

          _formKey.currentState?.reset();
          _eventDateController.clear();
          setState(() {
            _selectedDate = null;
            _selectedEventType = null;
          });
        } else {
          print(
            'Greška pri slanju zahteva: ${response.statusCode} ${response.body}',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Greška pri slanju zahteva: ${response.statusCode}',
              ),
            ),
          );
        }
      } catch (e) {
        print('Došlo je do greške: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Došlo je do greške: $e')));
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _eventDateController.dispose();
    _venueTypeController.dispose();
    _numberOfGuestsController.dispose();
    _numberOfTablesController.dispose();
    _themeOrColorsController.dispose();
    _locationController.dispose();
    _specialRequestsController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using GlobalAppHeader from MainLayout
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Event Decoration Request',
          style: TextStyle(
            color: Color(0xFFF06292),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFF06292)),
        automaticallyImplyLeading: false, // MainLayout handles the back button
      ),
      body: Container(
        color: const Color(0xFFFCE4EC),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Schedule an event decoration',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF06292),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabel('Event type'),
                DropdownButtonFormField<String>(
                  value: _selectedEventType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  hint: const Text('Odaberite tip događaja'),
                  items: _eventTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedEventType = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Molimo odaberite tip događaja' : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Event date'),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _eventDateController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'YYYY-MM-DD',
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFFF06292),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      validator: (value) => value!.isEmpty
                          ? 'Molimo odaberite datum događaja'
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLabel('Venue type'),
                _buildTextFormField(
                  _venueTypeController,
                  'Unesite tip lokacije',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Number of guests'),
                          _buildTextFormField(
                            _numberOfGuestsController,
                            '',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Obavezno polje';
                              if (int.tryParse(value) == null)
                                return 'Nevažeći broj';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Number of tables'),
                          _buildTextFormField(
                            _numberOfTablesController,
                            '',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Obavezno polje';
                              if (int.tryParse(value) == null)
                                return 'Nevažeći broj';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLabel('Decoration theme/colors'),
                _buildTextFormField(_themeOrColorsController, ''),
                const SizedBox(height: 16),
                _buildLabel('Event location'),
                _buildTextFormField(_locationController, ''),
                const SizedBox(height: 16),
                _buildLabel('Special requests'),
                _buildTextFormField(
                  _specialRequestsController,
                  '',
                  maxLines: 3,
                  isOptional: true,
                ),
                const SizedBox(height: 16),
                _buildLabel('Amount (KM)'),
                _buildTextFormField(
                  _budgetController,
                  '',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Obavezno polje';
                    if (double.tryParse(value) == null) return 'Nevažeći iznos';
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF06292),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
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
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF06292),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String hintText, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      validator: isOptional
          ? null
          : validator ??
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ovo polje je obavezno';
                  }
                  return null;
                },
    );
  }
}
