import 'package:flora_desktop_app/models/order_model.dart';
import 'package:flora_desktop_app/providers/order_provider.dart';
import 'package:flora_desktop_app/screens/order_detail_screen.dart';
import 'package:flora_desktop_app/widgets/order_list_table_widget.dart';
import 'package:flutter/material.dart';


class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  OrderModel? _selectedOrder;
  bool _isLoadingPending = false;
  bool _isLoadingCompleted = false;
  List<OrderModel> _pendingOrders = [];
  List<OrderModel> _completedOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoadingPending = true;
      _isLoadingCompleted = true;
    });
    try {
     
      final pending = await OrderApiService.getActiveOrders();
      final completed = await OrderApiService.getCompletedOrders();
      
      setState(() {
        _pendingOrders = pending;
        _completedOrders = completed;
      });
    } catch (e) {
      print('Error fetching orders: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading orders: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoadingPending = false;
        _isLoadingCompleted = false;
      });
    }
  }

  void _onOrderSelected(OrderModel order) {
    setState(() {
      _selectedOrder = order;
    });
  }

  void _onBackFromDetails() {
    setState(() {
      _selectedOrder = null;
    });
    _fetchOrders(); 
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedOrder != null) {
      return OrderDetailsScreen(
        order: _selectedOrder!,
        onBack: _onBackFromDetails,
      );
    }

    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Orders',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 170, 46, 92),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Manage your customer orders',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerHeight: 0,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color.fromARGB(255, 170, 46, 92),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: const Color.fromARGB(255, 255, 102, 204),
                  ),
                  tabs: const [
                    Tab(
                      text: 'Active Orders',
                      height: 40,
                    ),
                    Tab(
                      text: 'Completed Orders',
                      height: 40,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab za aktivne narudžbe (Pending/Processed/Delivered)
                  _isLoadingPending
                    ? const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 170, 46, 92)))
                    : OrderListTable(
                        orders: _pendingOrders,
                        onOrderSelected: _onOrderSelected,
                        onRefresh: _fetchOrders,
                        orderStatus: 'Active',
                      ),
                  
                  // Tab za završene narudžbe (Completed)
                  _isLoadingCompleted
                    ? const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 170, 46, 92)))
                    : OrderListTable(
                        orders: _completedOrders,
                        onOrderSelected: _onOrderSelected,
                        onRefresh: _fetchOrders,
                        orderStatus: 'Completed',
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
