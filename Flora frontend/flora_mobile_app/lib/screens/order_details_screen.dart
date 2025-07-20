import 'package:flora_mobile_app/models/order.dart';
import 'package:flutter/material.dart';
import 'dart:math'; // Za min funkciju

class MobileOrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const MobileOrderDetailsScreen({super.key, required this.order});

  Widget _buildStatusStep(String title, bool isActive, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? Colors.green
                : (isActive ? const Color.fromARGB(255, 170, 46, 92) : Colors.grey[300]),
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color.fromARGB(255, 170, 46, 92) : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String orderIdDisplay = order.id.toString().substring(
      0,
      min(order.id.toString().length, 8),
    ).toUpperCase();

    final String formattedDate =
        '${order.orderDate.day}.${order.orderDate.month}.${order.orderDate.year}';

    // Logika za status bar
    bool isOrderPlaced = false;
    bool isInDelivery = false;
    bool isDelivered = false;

    if (order.status == 'Pending') {
      isOrderPlaced = true;
    } else if (order.status == 'Processed') { // Pretpostavljamo da "Processed" znači "In delivery"
      isOrderPlaced = true;
      isInDelivery = true;
    } else if (order.status == 'Completed') { // Pretpostavljamo da "Completed" znači "Delivered"
      isOrderPlaced = true;
      isInDelivery = true;
      isDelivered = true;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 170, 46, 92)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Flora',
          style: TextStyle(
            color: Color.fromARGB(255, 170, 46, 92),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My orders >> Order details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 170, 46, 92),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Order details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.orderDetails.length,
              itemBuilder: (context, index) {
                final item = order.orderDetails[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.productImageUrl?.isNotEmpty == true
                                ? item.productImageUrl!
                                : 'https://via.placeholder.com/80x80/FFB6C1/FFFFFF?text=No+Image',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName ?? 'Unknown Product',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Quantity: ${item.quantity}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${(item.priceAtPurchase * item.quantity).toStringAsFixed(2)} KM',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 170, 46, 92),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Cost: ${order.totalAmount.toStringAsFixed(2)} KM',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 170, 46, 92),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Order number: ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              orderIdDisplay,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              'Order date: ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            const Text(
              'Delivery address:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '${order.shippingAddress.firstName} ${order.shippingAddress.lastName}',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            Text(
              '${order.shippingAddress.street} ${order.shippingAddress.houseNumber}',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            Text(
              '${order.shippingAddress.city}, ${order.shippingAddress.postalCode}',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 30),
            const Text(
              'Order status:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusStep('Order placed', isOrderPlaced, isOrderPlaced),
                Expanded(
                  child: Container(
                    height: 2,
                    color: isOrderPlaced && isInDelivery ? const Color.fromARGB(255, 170, 46, 92) : Colors.grey[300],
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
                _buildStatusStep('In delivery', isInDelivery, isInDelivery),
                Expanded(
                  child: Container(
                    height: 2,
                    color: isInDelivery && isDelivered ? const Color.fromARGB(255, 170, 46, 92) : Colors.grey[300],
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
                _buildStatusStep('Delivered', isDelivered, isDelivered),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 170, 46, 92),
        selectedItemColor: const Color.fromARGB(255, 255, 210, 233),
        unselectedItemColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        currentIndex: 4, // Pretpostavljamo da je ovo tab za Account
        onTap: (index) {
          // Implementiraj navigaciju za donji bar ako je potrebno
          // Trenutno, samo se vraća na prethodni ekran ako se klikne na Account tab
          if (index == 4) { // Ako je Account tab
            Navigator.of(context).pop(); // Vrati se sa Order Details ekrana
          } else {
            // Implementiraj navigaciju za ostale tabove
            // MainLayout.of(context)?.openTab(index); // Ako imaš takvu metodu
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigation to tab $index not implemented.')),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Shop"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }
}
