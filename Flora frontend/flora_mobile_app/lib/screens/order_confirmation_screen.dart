import 'package:flora_mobile_app/models/order.dart';
import 'package:flora_mobile_app/screens/my_orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flora_mobile_app/layouts/main_layout.dart';
import 'dart:math'; // Dodaj import za min funkciju

class OrderConfirmationScreen extends StatelessWidget {
  final OrderModel order;

  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final String orderIdDisplay = order.id
        .toString()
        .substring(0, min(order.id.toString().length, 8))
        .toUpperCase();

    return Scaffold(
      backgroundColor: Colors.white,
      // Removed duplicate AppBar - using GlobalAppHeader from MainLayout
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 30),
              const Text(
                'Thank You for Your Order!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 170, 46, 92),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Your order #$orderIdDisplay has been successfully placed and confirmed.', // Koristi novu varijablu
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Text(
                'Total Amount: ${order.totalAmount.toStringAsFixed(2)} KM',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  MainLayout.of(context)?.goBackToHome();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 170, 46, 92),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  // Navigate to My Orders screen
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MainLayout(userId: order.userId),
                    ),
                  ).then((_) {
                    // Use a slight delay to ensure MainLayout is built
                    Future.delayed(Duration(milliseconds: 100), () {
                      final mainLayout = MainLayout.of(context);
                      if (mainLayout != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MyOrdersScreen(userId: order.userId),
                          ),
                        );
                      }
                    });
                  });
                },
                child: const Text(
                  'View Order History',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 170, 46, 92),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
