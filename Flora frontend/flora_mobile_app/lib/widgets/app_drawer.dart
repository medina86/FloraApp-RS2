import 'package:flutter/material.dart';
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/layouts/main_layout.dart';
import 'package:flora_mobile_app/screens/custom_bouquet_screen.dart';
import 'package:flora_mobile_app/screens/my_orders_screen.dart';
import 'package:flora_mobile_app/screens/my_events_screen.dart';

class AppDrawer extends StatelessWidget {
  final int userId;
  final Function(int) onNavigate;

  const AppDrawer({Key? key, required this.userId, required this.onNavigate})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF06292), // Consistent pink color
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Flora',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'DancingScript',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Cvjećara koja oduševljava',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home,
            title: 'Početna',
            onTap: () => _navigateToScreen(context, 0),
          ),
          _buildDrawerItem(
            icon: Icons.store,
            title: 'Prodavnica',
            onTap: () => _navigateToScreen(context, 1),
          ),
          _buildDrawerItem(
            icon: Icons.favorite,
            title: 'Omiljeno',
            onTap: () => _navigateToScreen(context, 2),
          ),
          _buildDrawerItem(
            icon: Icons.shopping_cart,
            title: 'Korpa',
            onTap: () => _navigateToScreen(context, 3),
          ),
          _buildDrawerItem(
            icon: Icons.person,
            title: 'Profil',
            onTap: () => _navigateToScreen(context, 4),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.shopping_bag,
            title: 'Moje narudžbe',
            onTap: () => _navigateToMyOrders(context),
          ),
          _buildDrawerItem(
            icon: Icons.event_note,
            title: 'Moji događaji',
            onTap: () => _navigateToMyEvents(context),
          ),
          _buildDrawerItem(
            icon: Icons.article,
            title: 'Blog',
            onTap: () => _navigateToBlog(context),
          ),
          _buildDrawerItem(
            icon: Icons.volunteer_activism,
            title: 'Donacije',
            onTap: () => _navigateToDonations(context),
          ),
          _buildDrawerItem(
            icon: Icons.card_giftcard,
            title: 'Prilagođeni buketi',
            onTap: () => _navigateToCustomBouquets(context),
          ),
          _buildDrawerItem(
            icon: Icons.event,
            title: 'Dekoracije',
            onTap: () => _navigateToDecorations(context),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.info_outline,
            title: 'O nama',
            onTap: () => _navigateToAbout(context),
          ),
          _buildDrawerItem(
            icon: Icons.contact_phone,
            title: 'Kontakt',
            onTap: () => _navigateToContact(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: const Color(0xFFF06292), size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    Navigator.of(context).pop(); // Close the drawer
    onNavigate(index);
  }

  void _navigateToBlog(BuildContext context) {
    Navigator.of(context).pop();
    // Use the existing navigation method from MainLayout
    MainLayout.openBlog(context);
  }

  void _navigateToDonations(BuildContext context) {
    Navigator.of(context).pop();
    MainLayout.openDonations(context);
  }

  void _navigateToCustomBouquets(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              color: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Color.fromARGB(255, 170, 46, 92)),
            ),
          ),
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Custom Bouquet',
                style: TextStyle(
                  color: Color.fromARGB(255, 170, 46, 92),
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: CreateCustomBouquetScreen(userId: userId),
            bottomNavigationBar: Theme(
              data: Theme.of(
                context,
              ).copyWith(canvasColor: Color.fromARGB(255, 170, 46, 92)),
              child: BottomNavigationBar(
                selectedItemColor: const Color.fromARGB(255, 255, 210, 233),
                unselectedItemColor: Colors.white,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                type: BottomNavigationBarType.fixed,
                currentIndex: 0,
                onTap: (index) {
                  Navigator.pop(context);
                  onNavigate(index);
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.store),
                    label: "Shop",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    label: "Favorites",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart),
                    label: "Cart",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: "Account",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDecorations(BuildContext context) {
    Navigator.of(context).pop();
    MainLayout.openDecorationRequest(context);
  }

  void _navigateToMyOrders(BuildContext context) {
    Navigator.of(context).pop();
    // Navigate directly with a complete Scaffold to ensure proper layout
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              color: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Color.fromARGB(255, 170, 46, 92)),
            ),
          ),
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'My Orders',
                style: TextStyle(
                  color: Color.fromARGB(255, 170, 46, 92),
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: MyOrdersScreen(userId: userId),
            bottomNavigationBar: Theme(
              data: Theme.of(
                context,
              ).copyWith(canvasColor: Color.fromARGB(255, 170, 46, 92)),
              child: BottomNavigationBar(
                selectedItemColor: const Color.fromARGB(255, 255, 210, 233),
                unselectedItemColor: Colors.white,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                type: BottomNavigationBarType.fixed,
                currentIndex: 0,
                onTap: (index) {
                  Navigator.pop(context);
                  onNavigate(index);
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.store),
                    label: "Shop",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    label: "Favorites",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart),
                    label: "Cart",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: "Account",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToMyEvents(BuildContext context) {
    Navigator.of(context).pop();
    // Navigate directly with a complete Scaffold to ensure proper layout
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              color: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Color.fromARGB(255, 170, 46, 92)),
            ),
          ),
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'My Events',
                style: TextStyle(
                  color: Color.fromARGB(255, 170, 46, 92),
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: MyEventsScreen(userId: userId),
            bottomNavigationBar: Theme(
              data: Theme.of(
                context,
              ).copyWith(canvasColor: Color.fromARGB(255, 170, 46, 92)),
              child: BottomNavigationBar(
                selectedItemColor: const Color.fromARGB(255, 255, 210, 233),
                unselectedItemColor: Colors.white,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                type: BottomNavigationBarType.fixed,
                currentIndex: 0,
                onTap: (index) {
                  Navigator.pop(context);
                  onNavigate(index);
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.store),
                    label: "Shop",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    label: "Favorites",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart),
                    label: "Cart",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: "Account",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAbout(BuildContext context) {
    Navigator.of(context).pop();

    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'Flora',
        applicationVersion: '1.0.0',
        applicationIcon: Image.asset(
          'assets/images/Logo.png',
          width: 48,
          height: 48,
        ),
        children: const [
          SizedBox(height: 16),
          Text(
            'Flora je cvjećara koja nudi širok asortiman cvijeća i dekoracija za sve prilike.',
          ),
          SizedBox(height: 8),
          Text('Nalazimo se u Sarajevu na adresi Zmaja od Bosne bb.'),
          SizedBox(height: 8),
          Text('© 2025 Flora. Sva prava pridržana.'),
        ],
      ),
    );
  }

  void _navigateToContact(BuildContext context) {
    Navigator.of(context).pop();
    // Show contact information in dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kontakt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Telefon: +387 33 123 456'),
            SizedBox(height: 8),
            Text('Email: info@flora.ba'),
            SizedBox(height: 8),
            Text('Adresa: Zmaja od Bosne bb, Sarajevo'),
            SizedBox(height: 16),
            Text('Radno vrijeme:'),
            Text('Ponedjeljak - Petak: 08:00 - 20:00'),
            Text('Subota: 08:00 - 17:00'),
            Text('Nedjelja: 09:00 - 15:00'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Zatvori'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
