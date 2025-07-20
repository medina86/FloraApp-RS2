import 'package:flora_desktop_app/models/order_model.dart';
import 'package:flora_desktop_app/providers/order_provider.dart';
import 'package:flutter/material.dart';

class OrderListTable extends StatefulWidget {
  final List<OrderModel> orders;
  final Function(OrderModel) onOrderSelected;
  final VoidCallback onRefresh; // Callback za osvežavanje liste

  const OrderListTable({
    super.key,
    required this.orders,
    required this.onOrderSelected,
    required this.onRefresh,
  });

  @override
  State<OrderListTable> createState() => _OrderListTableState();
}

class _OrderListTableState extends State<OrderListTable> {
  final Set<int> _processingOrderIds = {}; // Prati koje narudžbine se obrađuju

  Future<void> _processOrder(OrderModel order) async {
    setState(() {
      _processingOrderIds.add(order.id);
    });
    try {
      await OrderApiService.processOrder(order.id);
      widget.onRefresh(); // Osveži listu nakon uspešne obrade
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order #${order.id} processed successfully!')),
      );
    } catch (e) {
      print('Error processing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process order: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _processingOrderIds.remove(order.id);
      });
    }
  }

  Future<void> _deliverOrder(OrderModel order) async {
    setState(() {
      _processingOrderIds.add(order.id);
    });
    try {
      await OrderApiService.deliverOrder(order.id);
      widget.onRefresh(); // Osveži listu nakon uspešne isporuke
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order #${order.id} delivered successfully!')),
      );
    } catch (e) {
      print('Error delivering order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to deliver order: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _processingOrderIds.remove(order.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Table',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 20,
                dataRowHeight: 70,
                columns: const [
                  DataColumn(label: Text('Users', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('E-mail', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('')), // Za dugme
                ],
                rows: widget.orders.map((order) {
                  final isProcessing = _processingOrderIds.contains(order.id);
                  return DataRow(
                    onSelectChanged: (selected) {
                      if (selected == true) {
                        widget.onOrderSelected(order);
                      }
                    },
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Color.fromARGB(255, 170, 46, 92).withOpacity(0.2),
                              child: Text(
                                order.shippingAddress.firstName.isNotEmpty
                                    ? order.shippingAddress.firstName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Color.fromARGB(255, 170, 46, 92)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${order.shippingAddress.firstName} ${order.shippingAddress.lastName}',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '@user${order.userId}', // Pretpostavljeni username
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(order.shippingAddress.firstName ?? 'N/A')), // Koristi email iz shipping adrese
                      DataCell(Text('${order.orderDate.month}/${order.orderDate.day}/${order.orderDate.year.toString().substring(2)}')),
                      DataCell(
                        isProcessing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color.fromARGB(255, 170, 46, 92),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  if (order.status == 'Pending') {
                                    _processOrder(order);
                                  } else if (order.status == 'Processed') {
                                    _deliverOrder(order);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: order.status == 'Pending'
                                      ? const Color.fromARGB(255, 255, 102, 204) // Pink za Process
                                      : const Color.fromARGB(255, 0, 112, 186), // Plava za Deliver
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  order.status == 'Pending' ? 'Process' : 'Deliver',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
