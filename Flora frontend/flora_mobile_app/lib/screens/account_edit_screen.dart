import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flora_mobile_app/layouts/constants.dart';

class EditProfileScreen extends StatefulWidget {
  final int userId;
  const EditProfileScreen({super.key, required this.userId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController(); // Optional new password

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final url = Uri.parse('$baseUrl/api/Users/${widget.userId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _firstName.text = data['firstName'] ?? '';
        _lastName.text = data['lastName'] ?? '';
        _email.text = data['email'] ?? '';
        _phone.text = data['phoneNumber'] ?? '';
        _username.text = data['username'] ?? '';
      });
    }
  }

  Future<void> _updateProfile() async {
    final url = Uri.parse('$baseUrl/Users/${widget.userId}');

    final body = jsonEncode({
      'firstName': _firstName.text,
      'lastName': _lastName.text,
      'email': _email.text,
      'username': _username.text,
      'phoneNumber': _phone.text,
      'isActive': true,
      'password': _password.text.isNotEmpty ? _password.text : null,
      'roleIds': [2],
    });

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Uspješno"),
            content: const Text("Podaci su uspješno izmijenjeni."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Uredi profil")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextInput(_firstName, "First Name"),
              const SizedBox(height: 15),
              _buildTextInput(_lastName, "Last Name"),
              const SizedBox(height: 15),
              _buildTextInput(_email, "Email"),
              const SizedBox(height: 15),
              _buildTextInput(_phone, "Phone"),
              const SizedBox(height: 15),
              _buildTextInput(_username, "Username"),
              const SizedBox(height: 15),
              _buildPasswordInput(_password, "New Password (optional)"),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 154, 39, 120),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput(TextEditingController controller, String label) {
    final bool isEmail = label.toLowerCase() == "email";
    final bool isPhone = label.toLowerCase() == "phone";

    return TextFormField(
      controller: controller,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone
          ? TextInputType.phone
          : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label je obavezno polje';
        }

        if (isEmail) {
          // Email regex validation
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) {
            return 'Email nije u ispravnom formatu';
          }
        }

        if (isPhone) {
          // Phone number regex validation
          final phoneRegex = RegExp(
            r'^[+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{3,6}$',
          );
          if (!phoneRegex.hasMatch(value)) {
            return 'Broj telefona nije u ispravnom formatu\nPrimjeri: +387 33 123 456, 033/123-456';
          }
        }

        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 253, 253),
        labelStyle: const TextStyle(color: Color.fromARGB(255, 218, 104, 146)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 218, 104, 146),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        // Show helper text for email and phone fields
        helperText: isEmail
            ? 'Unesite važeću email adresu'
            : isPhone
            ? 'Unesite broj u formatu: +387 33 123 456'
            : null,
        helperStyle: TextStyle(
          color: Color.fromARGB(255, 117, 117, 117),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPasswordInput(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 253, 253),
        labelStyle: const TextStyle(color: Color.fromARGB(255, 218, 104, 146)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 218, 104, 146),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
