import 'package:flora_desktop_app/models/order_model.dart';
import 'package:flora_desktop_app/models/user_model.dart';
import 'package:flora_desktop_app/providers/order_provider.dart';
import 'package:flora_desktop_app/providers/user_provider.dart';
import 'package:flutter/material.dart';

class OrderListTable extends StatefulWidget {
  final List<OrderModel> orders;
  final Function(OrderModel) onOrderSelected;
  final VoidCallback onRefresh;
  final String orderStatus;

  const OrderListTable({
    super.key,
    required this.orders,
    required this.onOrderSelected,
    required this.onRefresh,
    required this.orderStatus,
  });

  @override
  State<OrderListTable> createState() => _OrderListTableState();
}

class _OrderListTableState extends State<OrderListTable> {
  final Set<int> _processingOrderIds = {}; // Prati koje narudžbe se obrađuju
  final Map<int, UserModel> _userCache =
      {}; // Keširanje korisničkih podataka po ID-u

  Future<void> _processOrder(OrderModel order) async {
    setState(() {
      _processingOrderIds.add(order.id);
    });
    try {
      await OrderApiService.processOrder(order.id);
      widget.onRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order #${order.id} processed successfully!')),
      );
    } catch (e) {
      print('Error processing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process order: $e'),
          backgroundColor: Colors.red,
        ),
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
      widget.onRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order #${order.id} delivered successfully!')),
      );
    } catch (e) {
      print('Error delivering order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to deliver order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _processingOrderIds.remove(order.id);
      });
    }
  }

  Future<void> _completeOrder(OrderModel order) async {
    setState(() {
      _processingOrderIds.add(order.id);
    });
    try {
      await OrderApiService.completeOrder(order.id);
      widget.onRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order #${order.id} completed successfully!')),
      );
    } catch (e) {
      print('Error completing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _processingOrderIds.remove(order.id);
      });
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case "Pending":
        return const Color.fromARGB(255, 255, 102, 204); // Pink
      case "PaymentInitiated":
        return const Color.fromARGB(255, 255, 102, 204); // Pink
      case "Processed":
        return const Color.fromARGB(255, 102, 204, 255); // Plava
      case "Delivered":
        return const Color.fromARGB(255, 255, 165, 0); // Narančasta
      case "Completed":
        return const Color.fromARGB(255, 51, 204, 51); // Zelena
      case "Cancelled":
        return const Color.fromARGB(255, 255, 0, 0); // Crvena
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Metoda za učitavanje podataka o korisnicima
  Future<void> _loadUserData() async {
    for (var order in widget.orders) {
      try {
        if (!_userCache.containsKey(order.userId)) {
          print('Fetching user data for userId: ${order.userId}');
          final user = await UserApiService.getUserById(order.userId);
          print(
            'Successfully fetched user data: ${user.firstName} ${user.lastName}',
          );
          setState(() {
            _userCache[order.userId] = user;
          });
        }
      } catch (e) {
        print('Error loading user data for userId ${order.userId}: $e');
        // Ako ne možemo dohvatiti korisnika, koristimo podatke iz shipping adrese
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.orders.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                "No orders found",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                dataRowHeight: 70,
                headingRowHeight: 50,
                headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                horizontalMargin: 20,
                columnSpacing: 24,
                showCheckboxColumn: false,
                columns: const [
                  DataColumn(
                    label: Text(
                      "User",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color.fromARGB(255, 100, 100, 100),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Date",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color.fromARGB(255, 100, 100, 100),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Amount",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color.fromARGB(255, 100, 100, 100),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Status",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color.fromARGB(255, 100, 100, 100),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Action",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color.fromARGB(255, 100, 100, 100),
                      ),
                    ),
                  ),
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
                            // Ako imamo podatke o korisniku, koristimo ih, inače koristimo podatke iz shipping adrese
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  _userCache.containsKey(order.userId)
                                  ? (_userCache[order.userId]!.firstName[0]
                                                .toUpperCase() ==
                                            'A'
                                        ? const Color.fromARGB(
                                            255,
                                            205,
                                            82,
                                            255,
                                          )
                                        : _userCache[order.userId]!.firstName[0]
                                                  .toUpperCase() ==
                                              'E'
                                        ? const Color.fromARGB(
                                            255,
                                            255,
                                            180,
                                            82,
                                          )
                                        : _userCache[order.userId]!.firstName[0]
                                                  .toUpperCase() ==
                                              'H'
                                        ? const Color.fromARGB(
                                            255,
                                            82,
                                            150,
                                            255,
                                          )
                                        : const Color.fromARGB(
                                            255,
                                            255,
                                            102,
                                            204,
                                          ))
                                  : const Color.fromARGB(255, 170, 46, 92),
                              child: _userCache.containsKey(order.userId)
                                  ? Text(
                                      _userCache[order.userId]!
                                              .firstName
                                              .isNotEmpty
                                          ? _userCache[order.userId]!
                                                .firstName[0]
                                                .toUpperCase()
                                          : "?",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    )
                                  : Text(
                                      order.shippingAddress.firstName.isNotEmpty
                                          ? order.shippingAddress.firstName[0]
                                                .toUpperCase()
                                          : "?",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Ako imamo podatke o korisniku, prikazujemo njegovo ime, inače koristimo shipping adresu
                                Text(
                                  _userCache.containsKey(order.userId)
                                      ? _userCache[order.userId]!.fullName
                                      : "${order.shippingAddress.firstName} ${order.shippingAddress.lastName}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                // Prikaz broja narudžbe
                                Text(
                                  "Order #${order.id}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                // Ako imamo podatke o korisniku, prikazujemo i email
                                if (_userCache.containsKey(order.userId))
                                  Text(
                                    _userCache[order.userId]!.email,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          "${order.orderDate.day}.${order.orderDate.month}.${order.orderDate.year}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 80, 80, 80),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          "${order.totalAmount.toStringAsFixed(2)} KM",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 80, 80, 80),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              order.status,
                            ).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _getStatusColor(order.status),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            order.status ?? 'Unknown',
                            style: TextStyle(
                              color: _getStatusColor(order.status),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
                            : widget.orderStatus == "Completed"
                            ? Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        51,
                                        204,
                                        51,
                                      ).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Color.fromARGB(255, 51, 204, 51),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "Completed",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 51, 204, 51),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  if (order.status == "Pending") {
                                    _processOrder(order);
                                  } else if (order.status == "Processed") {
                                    _deliverOrder(order);
                                  } else if (order.status == "Delivered") {
                                    _completeOrder(order);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: order.status == "Pending"
                                      ? const Color.fromARGB(
                                          255,
                                          255,
                                          102,
                                          204,
                                        ) // Pink za Process
                                      : order.status == "Processed"
                                      ? const Color.fromARGB(
                                          255,
                                          102,
                                          204,
                                          255,
                                        ) // Plava za Deliver
                                      : const Color.fromARGB(
                                          255,
                                          51,
                                          204,
                                          51,
                                        ), // Zelena za Complete
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  order.status == "Pending"
                                      ? "Process"
                                      : order.status == "Processed"
                                      ? "Deliver"
                                      : "Complete",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
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
    );
  }
}
