import 'package:flutter/material.dart';

class GlobalAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showDrawerMenu;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const GlobalAppHeader({
    Key? key,
    this.title = 'Flora',
    this.showBackButton = false,
    this.onBackPressed,
    this.showDrawerMenu = true,
    this.scaffoldKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      centerTitle: true,
      automaticallyImplyLeading: false, 
      leading: showBackButton
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color.fromARGB(255, 170, 46, 92),
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : showDrawerMenu
          ? IconButton(
              icon: const Icon(
                Icons.menu,
                color: Color.fromARGB(255, 170, 46, 92),
              ),
              onPressed: () {
                if (scaffoldKey?.currentState != null) {
                  scaffoldKey!.currentState!.openDrawer();
                }
              },
            )
          : null,

      title: Text(
        "Flora",
        style: const TextStyle(
          color: Color.fromARGB(255, 232, 30, 123),
          fontSize: 26,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
      actions: [
        // Notification icon removed
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
