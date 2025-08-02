import 'dart:convert';
import 'package:flora_mobile_app/layouts/main_layout.dart';
import 'package:flora_mobile_app/models/user_model.dart';
import 'package:flora_mobile_app/screens/register_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flora_mobile_app/providers/auth_provider.dart';
import 'package:flora_mobile_app/layouts/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flora App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 172, 36, 84),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Add loading state

  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog("Molimo unesite korisničko ime i lozinku.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('$baseUrl/Users/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Successful login: $data');

        AuthProvider.username = username;
        AuthProvider.password = password;

        // Create and set user model from response data
        final user = UserModel(
          id: data['id'],
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          email: data['email'] ?? '',
          phoneNumber: data['phoneNumber'],
          profileImageUrl: data['profileImageUrl'],
        );
        AuthProvider.setUser(user);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainLayout(userId: data['id'])),
        );
      } else {
        AuthProvider.username = null;
        AuthProvider.password = null;

        String errorMessage = 'Login nije uspio';
        if (response.statusCode == 401) {
          errorMessage = 'Pogrešno korisničko ime ili lozinka';
        } else if (response.statusCode == 500) {
          errorMessage = 'Greška na serveru. Pokušajte ponovo.';
        }

        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      AuthProvider.username = null;
      AuthProvider.password = null;

      _showErrorDialog(
        'Greška prilikom spajanja na server. Provjerite internetsku konekciju.',
      );
      print('Login error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Greška"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _handleRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 350,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/Logo.png', width: 140, height: 140),
                const SizedBox(height: 30),
                TextField(
                  controller: _usernameController,
                  enabled: !_isLoading, // Disable during loading
                  decoration: InputDecoration(
                    labelText: "Username",
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 218, 104, 146),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 253, 253),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 56, 3, 36),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 218, 104, 146),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  enabled: !_isLoading, // Disable during loading
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 218, 104, 146),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 253, 253),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 56, 3, 36),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 218, 104, 146),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _handleLogin, // Disable when loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(165, 53, 131, 1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text("Login"),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : _handleRegister, // Disable when loading
                  child: const Text("Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
