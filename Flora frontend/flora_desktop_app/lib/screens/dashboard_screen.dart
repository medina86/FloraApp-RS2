import 'package:flora_desktop_app/screens/user_screen.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  final VoidCallback? onNavigateToUsers;
final VoidCallback? onNavigateToProducts;

  const AdminDashboard({Key? key, this.onNavigateToUsers, this.onNavigateToProducts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 30,
        mainAxisSpacing: 30,
        childAspectRatio: 1.5,
        children: [
          _buildCard(
            "Orders management",
            "Check new orders",
            Color.fromARGB(255, 137, 20, 82),
          ),
           _buildCard(
            "Products",
            "Add, edit and delete products",
            Color.fromARGB(255, 137, 20, 82),
            onTap: () {
              if (onNavigateToProducts != null) {
                onNavigateToProducts!();
              }
            },
          ),
          _buildCard(
            "Donations",
            "Donations management, add new campaign, view results",
            Color.fromARGB(255, 137, 20, 82),
          ),
          _buildCard(
            "Users",
            "Users management",
            Color.fromARGB(255, 137, 20, 82),
            onTap: () {
              if (onNavigateToUsers != null) {
                onNavigateToUsers!();
              }
            },
          ),
          _buildCard(
            "Reservations",
            "Check out Flora reservations",
            Color.fromARGB(255, 137, 20, 82),
          ),
          _buildCard(
            "Blog",
            "Manage your posts",
            Color.fromARGB(255, 137, 20, 82),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    String title,
    String subtitle,
    Color titleColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
