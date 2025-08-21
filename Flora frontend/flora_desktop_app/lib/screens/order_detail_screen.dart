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
                    
                    // Special Instructions and Card Message Section
                    _buildOrderSpecialInfo(order),
                    
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
  
  // Helper method to build special instructions and card message section
  Widget _buildOrderSpecialInfo(OrderModel order) {
    // Check if any order details have special instructions or card messages
    bool hasSpecialInstructions = order.orderDetails.any((detail) => 
        detail.specialInstructions != null && detail.specialInstructions!.isNotEmpty);
    
    bool hasCardMessages = order.orderDetails.any((detail) => 
        detail.cardMessage != null && detail.cardMessage!.isNotEmpty);
    
    if (!hasSpecialInstructions && !hasCardMessages) {
      return const SizedBox.shrink(); // Don't show anything if no special info exists
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Information:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        
        // Display card messages if any
        if (hasCardMessages) ...[
          for (var detail in order.orderDetails)
            if (detail.cardMessage != null && detail.cardMessage!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.pink.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.card_giftcard, 
                          color: Color.fromARGB(255, 170, 46, 92), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Card Message for ${detail.productName}:',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromARGB(255, 170, 46, 92),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      detail.cardMessage!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
        ],
        
        // Display special instructions if any
        if (hasSpecialInstructions) ...[
          for (var detail in order.orderDetails)
            if (detail.specialInstructions != null && 
                detail.specialInstructions!.isNotEmpty &&
                !detail.isCustomBouquet) // Skip custom bouquets as they show instructions in their card
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, 
                          color: Colors.blue, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Special Instructions for ${detail.productName}:',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      detail.specialInstructions!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ],
    );
  }
}
