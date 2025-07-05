import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse('http://192.168.1.102:5014/api/Users');

    final body = jsonEncode({
      'firstName': _firstName.text,
      'lastName': _lastName.text,
      'email': _email.text,
      'username': _username.text,
      'phoneNumber': _phone.text,
      'password': _password.text,
      'isActive': true,
      'roleIds': [2],
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Successfully registered"),
          actions: [
            TextButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Warning"),
          content: Text(
            "Register was not successful: ${response.reasonPhrase}",
          ),
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color.fromARGB(255, 218, 104, 146)),
      filled: true,
      fillColor: const Color.fromARGB(255, 255, 253, 253),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color.fromARGB(255, 56, 3, 36)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color.fromARGB(255, 218, 104, 146)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 165, 53, 131),
          width: 2,
        ),
      ),
    );
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final pattern = r'^[^@]+@[^@]+\.[^@]+';
    if (value == null || value.isEmpty) {
      return 'Email is required';
    } else if (!RegExp(pattern).hasMatch(value)) {
      return 'Insert email again.';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    } else if (value.length < 6) {
      return 'Minimum 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: const Color.fromARGB(255, 154, 39, 120),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/Logo.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _firstName,
                    decoration: _inputDecoration("First Name"),
                    validator: (value) => _requiredValidator(value, "Ime"),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _lastName,
                    decoration: _inputDecoration("Last Name"),
                    validator: (value) => _requiredValidator(value, "Prezime"),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _email,
                    decoration: _inputDecoration("Email"),
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _phone,
                    decoration: _inputDecoration("Phone"),
                    validator: (value) => _requiredValidator(value, "Telefon"),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _username,
                    decoration: _inputDecoration("Username"),
                    validator: (value) =>
                        _requiredValidator(value, "Korisničko ime"),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: _inputDecoration("Password"),
                    validator: _passwordValidator,
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(165, 53, 131, 1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text("Register"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
