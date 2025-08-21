import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/providers/auth_provider.dart';

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
  final _password = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('Loading user data for userId: ${widget.userId}');
      final url = Uri.parse('$baseUrl/Users/${widget.userId}');
      print('API URL: $url');

      final response = await http.get(url, headers: AuthProvider.getHeaders());

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Decoded data: $data');

        setState(() {
          _firstName.text = data['firstName'] ?? '';
          _lastName.text = data['lastName'] ?? '';
          _email.text = data['email'] ?? '';
          _phone.text = data['phoneNumber'] ?? '';
          _username.text = data['username'] ?? '';
          _isLoading = false;
        });

        print('Controllers updated:');
        print('FirstName: ${_firstName.text}');
        print('LastName: ${_lastName.text}');
        print('Email: ${_email.text}');
        print('Phone: ${_phone.text}');
        print('Username: ${_username.text}');
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Failed to load user data: ${response.statusCode}');
        print('Error response: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading user data: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final url = Uri.parse('$baseUrl/Users/${widget.userId}');

      final headers = AuthProvider.getHeaders();
      headers['Content-Type'] = 'application/json';

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

      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Profile Updated"),
              content: const Text(
                "Your profile has been successfully updated with the new information.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Continue"),
                ),
              ],
            ),
          );
        }
      } else {
        print('Failed to update profile: ${response.statusCode}');
        String errorMessage = "Failed to update profile. Please try again.";

        if (response.statusCode == 400) {
          errorMessage =
              "Invalid data provided. Please check all fields and try again.";
        } else if (response.statusCode == 409) {
          errorMessage =
              "Email or username already exists. Please choose different values.";
        } else if (response.statusCode == 500) {
          errorMessage = "Server error occurred. Please try again later.";
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Network error occurred. Please check your connection and try again.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 154, 39, 120),
              ),
            )
          : Padding(
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
                        backgroundColor: const Color.fromARGB(
                          255,
                          154,
                          39,
                          120,
                        ),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
    final bool isUsername = label.toLowerCase() == "username";
    final bool isName = label.toLowerCase().contains("name");

    return TextFormField(
      controller: controller,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone
          ? TextInputType.phone
          : TextInputType.text,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        // Validacija za imena
        if (isName) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          if (value.trim().length < 2) {
            return '$label must be at least 2 characters long';
          }
          if (value.trim().length > 50) {
            return '$label cannot exceed 50 characters';
          }
          final nameRegex = RegExp(r'^[a-zA-ZšđčćžŠĐČĆŽ\s]+$');
          if (!nameRegex.hasMatch(value.trim())) {
            return '$label can only contain letters and spaces';
          }
          return null;
        }

        // Validacija za email
        if (isEmail) {
          if (value == null || value.trim().isEmpty) {
            return 'Email is required';
          }
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

        if (isPhone) {
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

        if (isUsername) {
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

        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }

        return null;
      },
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

        helperText: isEmail
            ? 'Enter a valid email address'
            : isPhone
            ? 'Enter phone number (e.g., +387 33 123 456)'
            : isUsername
            ? 'Letters, numbers, and underscores only'
            : isName
            ? 'Letters and spaces only'
            : null,
        helperStyle: const TextStyle(
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
