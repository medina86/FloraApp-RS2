import 'dart:math';

import 'package:flora_desktop_app/models/order_model.dart';
import 'package:flora_desktop_app/widgets/order_detail_widget.dart';
import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onBack;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order details',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 170, 46, 92),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color.fromARGB(255, 170, 46, 92),
                    size: 30,
                  ),
                  onPressed: onBack,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order number: ${order.id.toString().substring(0, min(order.id.toString().length, 8)).toUpperCase()}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Order date: ${order.orderDate.day}.${order.orderDate.month}.${order.orderDate.year}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Delivery address',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${order.shippingAddress.firstName} ${order.shippingAddress.lastName}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '${order.shippingAddress.street} ${order.shippingAddress.houseNumber}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '${order.shippingAddress.city}, ${order.shippingAddress.postalCode}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              // Dodaj ostale detalje adrese ako su dostupni i potrebni
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 20),
                    const Text(
                      'Ordered Products:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Horizontalna lista proizvoda
                    SizedBox(
                      height: 280, // Povećana visina za custom bouquet kartice
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: order.orderDetails.length,
                        itemBuilder: (context, index) {
                          return OrderDetailProductCard(
                            item: order.orderDetails[index],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Cost: ${order.totalAmount.toStringAsFixed(2)} KM',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 170, 46, 92),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
