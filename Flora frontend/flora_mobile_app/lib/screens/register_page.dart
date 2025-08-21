import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/providers/cart_api.dart';

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

    final url = Uri.parse('$baseUrl/Users');

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
      final userResponse = jsonDecode(response.body);
      final userId = userResponse['id'];

      try {
        await CartApiService.createCartForUser(userId);
        print('Cart successfully created for user $userId');
      } catch (e) {
        print('Warning: Failed to create cart for user $userId: $e');
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Registration Successful"),
          content: const Text(
            "Your account has been created successfully! You can now log in with your credentials.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: const Text("Continue to Login"),
            ),
          ],
        ),
      );
    } else {
      // Detaljnije error handling
      String errorMessage =
          "Registration failed. Please check your information and try again.";

      if (response.statusCode == 400) {
        errorMessage =
            "Invalid data provided. Please check all fields and try again.";
      } else if (response.statusCode == 409) {
        errorMessage = "An account with this email or username already exists.";
      } else if (response.statusCode == 500) {
        errorMessage = "Server error occurred. Please try again later.";
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Registration Failed"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Try Again"),
            ),
          ],
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

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    // Detaljnija email validacija
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address (e.g., user@example.com)';
    }

    if (value.trim().length > 254) {
      return 'Email address cannot exceed 254 characters';
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 8) {
      return 'Phone number must be at least 8 digits long';
    }

    if (digitsOnly.length > 15) {
      return 'Phone number cannot exceed 15 digits';
    }

    final phoneRegex = RegExp(r'^[\+]?[\d\s\-\(\)\/]{8,20}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number\n(e.g., +387 33 123 456, 033/123-456)';
    }

    return null;
  }

  String? _usernameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }

    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters long';
    }

    if (value.trim().length > 20) {
      return 'Username cannot exceed 20 characters';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value.trim())) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  String? _nameValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters long';
    }

    if (value.trim().length > 50) {
      return '$fieldName cannot exceed 50 characters';
    }

    final nameRegex = RegExp(r'^[a-zA-ZšđčćžŠĐČĆŽ\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return '$fieldName can only contain letters and spaces';
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
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
                    validator: (value) => _nameValidator(value, "First Name"),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _lastName,
                    decoration: _inputDecoration("Last Name"),
                    validator: (value) => _nameValidator(value, "Last Name"),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _email,
                    decoration: _inputDecoration("Email"),
                    validator: _emailValidator,
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _phone,
                    decoration: _inputDecoration("Phone"),
                    validator: _phoneValidator,
                    keyboardType: TextInputType.phone,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _username,
                    decoration: _inputDecoration("Username"),
                    validator: _usernameValidator,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: _inputDecoration("Password"),
                    validator: _passwordValidator,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
