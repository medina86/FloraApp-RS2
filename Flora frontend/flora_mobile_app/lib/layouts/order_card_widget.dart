import 'package:flora_mobile_app/models/order.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class OrderCardWidget extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCardWidget({
    super.key,
    required this.order,
    required this.onTap,
  });
  
  Color _getStatusColor(String? status) {
    switch (status) {
      case "Pending":
      case "PaymentInitiated":
        return const Color.fromARGB(255, 255, 102, 204); // Pink
      case "Processed":
        return const Color.fromARGB(255, 102, 204, 255); // Blue
      case "Delivered":
        return const Color.fromARGB(255, 255, 165, 0); // Orange
      case "Completed":
        return const Color.fromARGB(255, 51, 204, 51); // Green
      case "Cancelled":
        return const Color.fromARGB(255, 255, 0, 0); // Red
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String orderIdDisplay = order.id.toString().substring(
      0,
      min(order.id.toString().length, 8),
    ).toUpperCase();

    final String formattedDate =
        '${order.orderDate.day}.${order.orderDate.month}.${order.orderDate.year}';

    final List<String> imageUrls = order.orderDetails
        .where((item) => item.productImageUrl != null && item.productImageUrl!.isNotEmpty)
        .map((item) => item.productImageUrl!)
        .take(2)
        .toList();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order number: $orderIdDisplay',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 170, 46, 92),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: ${order.status ?? "Processing"}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${order.totalAmount.toStringAsFixed(2)} KM',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: imageUrls.map((url) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              url,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image, size: 30, color: Colors.grey),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color.fromARGB(255, 170, 46, 92),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.orderDetails.length} items',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
