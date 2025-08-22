import 'package:flora_mobile_app/models/order.dart';
import 'package:flutter/material.dart';
import 'package:flora_mobile_app/layouts/main_layout.dart';
import 'package:flora_mobile_app/providers/cart_api.dart';
import 'dart:math';

class OrderConfirmationScreen extends StatefulWidget {
  final OrderModel order;

  const OrderConfirmationScreen({super.key, required this.order});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    // Očisti stavke iz korpe nakon uspešne narudžbe
    _clearCartItems();
  }

  Future<void> _clearCartItems() async {
    try {
      // Prvo dobavi cart ID za korisnika
      final cartId = await CartApiService.getCartIdByUser(widget.order.userId);
      if (cartId != null) {
        // Očisti stavke iz korpe ali zadrži samu korpu
        await CartApiService.clearCartItems(cartId);
      }
    } catch (e) {
      print('Error clearing cart items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String orderIdDisplay = widget.order.id
        .toString()
        .substring(0, min(widget.order.id.toString().length, 8))
        .toUpperCase();

    return Scaffold(
      backgroundColor: Colors.white,
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
                'Your order #$orderIdDisplay has been successfully placed and confirmed.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Text(
                'Total Amount: ${widget.order.totalAmount.toStringAsFixed(2)} KM',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Direktno navigiraj na MainLayout sa userId
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => MainLayout(userId: widget.order.userId),
                    ),
                    (route) => false, // Ukloni sve prethodne ekrane iz steka
                  );
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

            ],
          ),
        ),
      ),
    );
  }
}
