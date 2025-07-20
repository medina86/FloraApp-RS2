import 'dart:convert';
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/screens/account_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flora_mobile_app/screens/my_orders_screen.dart';

class AccountScreen extends StatefulWidget {
  final int userId;
  const AccountScreen({super.key, required this.userId});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String? profileImageUrl;
  String name = "";
  String email = "";
  String phone = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final response = await http.get(
      Uri.parse('${baseUrl}/Users/${widget.userId}'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        name = "${data['firstName']} ${data['lastName']}";
        email = data['email'];
        phone = data['phoneNumber'] ?? "";
        profileImageUrl = data['profileImageUrl'];
      });
      print('Korisnički podaci: ${response.body}');
    } else {
      print('Greška prilikom dohvaćanja korisničkih podataka.');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      print('Nema odabrane slike.');
      return;
    }
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${baseUrl}/Users/${widget.userId}/upload-image', 
      ),
    );
    request.files.add(await http.MultipartFile.fromPath('file', picked.path));
    final response = await request.send();
    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      final data = jsonDecode(res.body);
      setState(() {
        profileImageUrl = data['imageUrl'];
      });
      print('Slika uspješno postavljena.');
    } else {
      print('Neuspješan upload slike. Kod: ${response.statusCode}');
    }
  }

  void _showFAQPopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("FAQ"),
        content: const Text(
          "Here you can find answers to frequently asked questions.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionButton(
      String label,
      IconData icon, {
        VoidCallback? onTap,
      }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: const Color.fromARGB(255, 170, 46, 92)), // Koristi Flora pink boju
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap ?? () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Account info", style: TextStyle(color: Color.fromARGB(255, 170, 46, 92))), // Koristi Flora pink boju
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 170, 46, 92)), // Koristi Flora pink boju
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                  (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                      ? NetworkImage(profileImageUrl!)
                      : const AssetImage('assets/images/profile-image.png')
                  as ImageProvider,
                  backgroundColor: Colors.grey[200],
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color.fromARGB(255, 170, 46, 92)), // Koristi Flora pink boju
                  onPressed: _pickAndUploadImage,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text("$email | $phone", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            _buildSectionButton(
              "My orders",
              Icons.shopping_bag,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MyOrdersScreen(userId: widget.userId),
                  ),
                );
              },
            ),
            _buildSectionButton("My events", Icons.event),
            _buildSectionButton(
              "Edit profile information",
              Icons.edit,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(userId: widget.userId), 
                  ),
                );
                if (result == true) {
                  await _loadUserData();
                }
              },
            ),
            _buildSectionButton("Donations", Icons.favorite),
            _buildSectionButton(
              "FAQ",
              Icons.question_answer,
              onTap: _showFAQPopup,
            ),
            _buildSectionButton("Contact us (0616813321)", Icons.contact_phone),
            _buildSectionButton("Log out", Icons.logout, onTap: () {
              // Implementiraj log out logiku ovde
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Log out functionality not implemented.')),
              );
            }),
          ],
        ),
      ),
    );
  }
}
