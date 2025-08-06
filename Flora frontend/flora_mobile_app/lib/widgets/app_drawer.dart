import 'package:flutter/material.dart';
import 'package:flora_mobile_app/layouts/main_layout.dart';

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
              color: Color(0xFFF06292), 
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
                  'The flower shop that delights',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home,
            title: 'Home',
            onTap: () => _navigateToScreen(context, 0),
          ),
          _buildDrawerItem(
            icon: Icons.store,
            title: 'Shop',
            onTap: () => _navigateToScreen(context, 1),
          ),
          _buildDrawerItem(
            icon: Icons.favorite,
            title: 'Favorites',
            onTap: () => _navigateToScreen(context, 2),
          ),
          _buildDrawerItem(
            icon: Icons.shopping_cart,
            title: 'Cart',
            onTap: () => _navigateToScreen(context, 3),
          ),
          _buildDrawerItem(
            icon: Icons.person,
            title: 'Profile',
            onTap: () => _navigateToScreen(context, 4),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.article,
            title: 'Blog',
            onTap: () => _navigateToBlog(context),
          ),
          _buildDrawerItem(
            icon: Icons.event,
            title: 'Decorations',
            onTap: () => _navigateToDecorations(context),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.info_outline,
            title: 'About Us',
            onTap: () => _navigateToAbout(context),
          ),
          _buildDrawerItem(
            icon: Icons.contact_phone,
            title: 'Contact',
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
    Navigator.of(context).pop(); 
    onNavigate(index);
  }

  void _navigateToBlog(BuildContext context) {
    Navigator.of(context).pop();
    MainLayout.openBlog(context);
  }

  void _navigateToDecorations(BuildContext context) {
    Navigator.of(context).pop();
    MainLayout.openDecorationRequest(context);
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
            'Flora is a flower shop that offers a wide range of flowers and decorations for all occasions.',
          ),
          SizedBox(height: 8),
          Text('We are located in Sarajevo at Zmaja od Bosne bb.'),
          SizedBox(height: 8),
          Text('© 2025 Flora. All rights reserved.'),
        ],
      ),
    );
  }

  void _navigateToContact(BuildContext context) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Phone: +387 33 123 456'),
            SizedBox(height: 8),
            Text('Email: info@flora.ba'),
            SizedBox(height: 8),
            Text('Address: Zmaja od Bosne bb, Sarajevo'),
            SizedBox(height: 16),
            Text('Working Hours:'),
            Text('Monday - Friday: 08:00 - 20:00'),
            Text('Saturday: 08:00 - 17:00'),
            Text('Sunday: 09:00 - 15:00'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
