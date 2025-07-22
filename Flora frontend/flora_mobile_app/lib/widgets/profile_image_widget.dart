import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/models/user_model.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel? user;
  final bool isLoading;
  final VoidCallback onImageTap;

  const ProfileHeader({
    Key? key,
    required this.user,
    required this.isLoading,
    required this.onImageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: _getProfileImage(),
              backgroundColor: Colors.grey[200],
              child: isLoading 
                ? const CircularProgressIndicator()
                : null,
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.floralPink),
              onPressed: onImageTap,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          user?.fullName ?? 'Loading...',
          style: AppTextStyles.nameStyle,
        ),
        const SizedBox(height: 4),
        Text(
          user?.contactInfo ?? '',
          style: AppTextStyles.contactStyle,
        ),
      ],
    );
  }

  ImageProvider? _getProfileImage() {
    if (user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty) {
      return NetworkImage(user!.profileImageUrl!);
    }
    return const AssetImage('assets/images/profile-image.png') as ImageProvider;
  }
}
