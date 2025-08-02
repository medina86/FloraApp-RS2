import 'package:flora_desktop_app/layouts/admin_main_layout.dart';
import 'package:flora_desktop_app/providers/auth_provider.dart';
import 'package:flora_desktop_app/providers/base_provider.dart';
import 'package:flora_desktop_app/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credentials = {
        'username': _username.text.trim(),
        'password': _password.text.trim(),
      };

      AuthProvider.setCredentials(
        credentials['username']!,
        credentials['password']!,
      );
      final loginResponse = await BaseApiService.post<Map<String, dynamic>>(
        '/Users/login',
        credentials,
        (data) => data ?? <String, dynamic>{},
      );

      // If we got here, login was successful
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminMainLayout()),
        );
      }
    } on UnauthorizedException catch (e) {
      AuthProvider.logout();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Neispravni podaci za prijavu: ${e.message}")),
        );
      }
    } on ApiException catch (e) {
      AuthProvider.logout();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login greška: ${e.message}")));
      }
    } catch (e) {
      AuthProvider.logout();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Greška pri konekciji: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Admin Login", style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _username,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Unesite korisničko ime'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Unesite lozinku'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text("Login"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
