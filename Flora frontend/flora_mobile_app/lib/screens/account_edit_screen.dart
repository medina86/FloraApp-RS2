import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    final url = Uri.parse(
      'http://192.168.1.102:5014/api/Users/${widget.userId}',
    );
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
    final url = Uri.parse(
      'http://192.168.1.102:5014/api/Users/${widget.userId}',
    );

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

    final response = await http.put(url, body: body);

    if (response.statusCode == 200) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Uspješno"),
            content: const Text("Podaci su uspješno izmijenjeni."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } else {
      print(response.body);
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
    return TextFormField(
      controller: controller,
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
