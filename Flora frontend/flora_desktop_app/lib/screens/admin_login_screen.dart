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

      // Privremeno postavimo kredencijale za potrebe API poziva
      AuthProvider.setCredentials(
        credentials['username']!,
        credentials['password']!,
      );
      final loginResponse = await BaseApiService.post<Map<String, dynamic>>(
        '/Users/login',
        credentials,
        (data) => data ?? <String, dynamic>{},
      );

      // Provjera je li korisnik admin (roleId = 1)
      bool isAdmin = false;

      // Provjera formata odgovora - odgovor može sadržavati roleId direktno ili listu roles
      if (loginResponse.containsKey('roleId')) {
        // Direktni format
        isAdmin = loginResponse['roleId'] == 1;
      } else if (loginResponse.containsKey('roles')) {
        // Format s listom uloga
        final roles = loginResponse['roles'] as List<dynamic>?;
        isAdmin = roles?.any((role) => role['id'] == 1) ?? false;
      }

      if (isAdmin) {
        // Korisnik je admin, postavimo podatke i pristupimo admin sučelju
        int? adminRoleId = 1; // Definitivno znamo da je korisnik admin
        AuthProvider.setUserData(
          credentials['username']!,
          credentials['password']!,
          adminRoleId,
        );

        // Ako postoji lista uloga, pohrani je također
        if (loginResponse.containsKey('roles') &&
            loginResponse['roles'] is List) {
          List<dynamic> serverRoles = loginResponse['roles'] as List<dynamic>;
          List<Map<String, dynamic>> userRoles = serverRoles
              .map(
                (role) => {
                  'id': role['id'],
                  'name': role['name'],
                  'description': role['description'],
                },
              )
              .toList();
          AuthProvider.setRoles(userRoles);
        }
        // Login uspješan i korisnik je admin
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminMainLayout()),
          );
        }
      } else {
        // Korisnik nije admin
        AuthProvider.logout();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Pristup dozvoljen samo administratorima."),
              backgroundColor: Colors.red,
            ),
          );
        }
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
