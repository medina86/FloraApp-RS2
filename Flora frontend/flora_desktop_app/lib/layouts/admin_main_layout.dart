import 'package:flora_desktop_app/screens/dashboard_screen.dart';
import 'package:flora_desktop_app/screens/orders_screen.dart';
import 'package:flora_desktop_app/screens/product_screen.dart';
import 'package:flora_desktop_app/screens/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

// Privremene definicije ako nisu u zasebnim fajlovima
// U suprotnom, obriši ove klase i dodaj import-e
/*
class OrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Orders Page", style: TextStyle(fontSize: 24)));
  }
}

class DonationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Donations Page", style: TextStyle(fontSize: 24)),
    );
  }

class ProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Products Page", style: TextStyle(fontSize: 24)));
  }
}

class UsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Users Page", style: TextStyle(fontSize: 24)));
  }
}
*/

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({Key? key}) : super(key: key);

  @override
  State<AdminMainLayout> createState() => AdminMainLayoutState();
}

class AdminMainLayoutState extends State<AdminMainLayout> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  final List<Map<String, dynamic>> _menuItems = [
    {"title": "Dashboard", "icon": Icons.dashboard},
    {"title": "Orders", "icon": Icons.shopping_bag},
    {"title": "Products", "icon": Icons.inventory},
    {"title": "Donations", "icon": Icons.favorite},
    {"title": "Statistics", "icon": Icons.bar_chart},
    {"title": "Reservations", "icon": Icons.event_seat},
    {"title": "Blog", "icon": Icons.article},
    {"title": "Users", "icon": Icons.people}, 
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      AdminDashboard(
        onNavigateToUsers: () {
          setState(() {
            _selectedIndex = 7; 
          });
        },
        onNavigateToProducts: () {
          setState(() {
            _selectedIndex = 2; 
          });
        },
      ),
      const OrdersPage(),
      ProductsPage(),
      //DonationsPage(),
      const Center(child: Text("Statistics Page", style: TextStyle(fontSize: 24))),
      const Center(child: Text("Reservations Page", style: TextStyle(fontSize: 24))),
      const Center(child: Text("Blog Page", style: TextStyle(fontSize: 24))),
      UsersPage(), // Dodaj UsersPage ovde da bi lista imala 8 elemenata
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/admin-login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 137, 20, 82), // Pink
                  Color.fromARGB(255, 97, 11, 49), // Darker pink
                ],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  child: const Text(
                    'Flora',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      final isSelected = _selectedIndex == index;
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        child: ListTile(
                          leading: Icon(
                            item["icon"],
                            color: isSelected ? Colors.white : Colors.white70,
                            size: 20,
                          ),
                          title: Text(
                            item["title"],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedTileColor: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onTap: () => _onItemTapped(index),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.white70,
                      size: 20,
                    ),
                    title: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: _logout,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
