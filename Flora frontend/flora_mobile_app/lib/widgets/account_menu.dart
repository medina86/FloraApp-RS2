import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flutter/material.dart';

class AccountMenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color iconColor;

  const AccountMenuItem({
    Key? key,
    required this.label,
    required this.icon,
    this.onTap,
    this.iconColor = AppColors.floralPink,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap ?? () {},
      ),
    );
  }
}
