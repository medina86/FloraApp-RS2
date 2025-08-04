import 'package:flutter/material.dart';
import 'package:flora_mobile_app/widgets/global_app_header.dart';
import 'package:flora_mobile_app/widgets/app_drawer.dart';

// Example of a standalone screen using global header and drawer
class ExampleScreen extends StatelessWidget {
  final int userId;

  const ExampleScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: GlobalAppHeader(
        title: 'Example Screen',
        scaffoldKey: scaffoldKey,
        showBackButton: true,
        notificationCount: 3,
      ),
      drawer: AppDrawer(
        userId: userId,
        onNavigate: (index) {
          // Handle navigation
          Navigator.pop(context);
          // Navigate to the selected tab
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This is a standalone screen with global header',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 170, 46, 92),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
