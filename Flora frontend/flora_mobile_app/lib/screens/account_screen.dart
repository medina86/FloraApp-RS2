import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/providers/user_provider.dart';
import 'package:flora_mobile_app/screens/account_edit_screen.dart';
import 'package:flora_mobile_app/screens/my_events_screen.dart';
import 'package:flora_mobile_app/screens/my_orders_screen.dart';
import 'package:flora_mobile_app/screens/donation_campaigns_screen.dart';
import 'package:flora_mobile_app/widgets/account_menu.dart';
import 'package:flora_mobile_app/widgets/faq_dialog.dart';
import 'package:flora_mobile_app/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class AccountScreenWrapper extends StatelessWidget {
  final int userId;
  const AccountScreenWrapper({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: AccountScreen(userId: userId),
    );
  }
}

class AccountScreen extends StatefulWidget {
  final int userId;
  const AccountScreen({super.key, required this.userId});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUser(widget.userId);
    });
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null && mounted) {
      await context.read<UserProvider>().uploadProfileImage(
        widget.userId,
        picked.path,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text("Account info", style: AppTextStyles.appBarStyle),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.floralPink),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${userProvider.error}'),
                  ElevatedButton(
                    onPressed: () => userProvider.loadUser(widget.userId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ProfileHeader(
                  user: userProvider.getUserById(widget.userId),
                  isLoading: userProvider.isLoading,
                  onImageTap: _pickAndUploadImage,
                ),
                const SizedBox(height: 20),
                _buildMenuItems(),
              ],
            ),
          );
        },
      ),
    );
  }

  static Future<void> navigateToMyOrders(
    BuildContext context,
    int userId,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => MyOrdersScreen(userId: userId)),
    );
  }

  static Future<bool?> navigateToEditProfile(
    BuildContext context,
    int userId,
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userId: userId),
      ),
    );
  }

  static void showLogoutSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Log out functionality not implemented.')),
    );
  }

  static Future<void> navigateToMyEvents(
    BuildContext context,
    int userId,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => MyEventsScreen(userId: userId)),
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        AccountMenuItem(
          label: "My orders",
          icon: Icons.shopping_bag,
          onTap: () => navigateToMyOrders(context, widget.userId),
        ),
        AccountMenuItem(
          label: "My events",
          icon: Icons.event,
          onTap: () => navigateToMyEvents(context, widget.userId),
        ),
        AccountMenuItem(
          label: "Edit profile information",
          icon: Icons.edit,
          onTap: () async {
            final result = await navigateToEditProfile(context, widget.userId);
            if (result == true && mounted) {
              context.read<UserProvider>().loadUser(widget.userId);
            }
          },
        ),
        AccountMenuItem(
          label: "Donations",
          icon: Icons.favorite,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DonationCampaignsScreen(
                userId: widget.userId,
                fromHomeScreen: false,
                onBack: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        AccountMenuItem(
          label: "FAQ",
          icon: Icons.question_answer,
          onTap: () => FAQDialog.show(context),
        ),
        AccountMenuItem(
          label: "Contact us (0616813321)",
          icon: Icons.contact_phone,
        ),
        AccountMenuItem(
          label: "Log out",
          icon: Icons.logout,
          onTap: () => showLogoutSnackBar(context),
        ),
      ],
    );
  }
}
