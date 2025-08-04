import 'package:flora_mobile_app/layouts/main_layout.dart';
import 'package:flora_mobile_app/layouts/order_card_widget.dart';
import 'package:flora_mobile_app/models/order.dart';
import 'package:flora_mobile_app/screens/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flora_mobile_app/providers/order_api.dart';

class MyOrdersScreen extends StatefulWidget {
  final int userId;

  const MyOrdersScreen({super.key, required this.userId});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<OrderModel> _currentOrders = [];
  List<OrderModel> _previousOrders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

Future<void> _loadOrders() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });
  try {
    final allOrders = await OrderApiService.getOrdersByUserId(
      widget.userId,
      retrieveAll: true,
      includeTotalCount: true,
    );

    allOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

    _currentOrders = allOrders
        .where(
          (order) => order.status == 'Pending' || order.status == 'Processed',
        )
        .toList();
    _previousOrders = allOrders
        .where((order) => order.status == 'Completed')
        .toList();
  } catch (e) {
    _errorMessage = 'Failed to load orders: $e';
    print('Error loading orders: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        centerTitle: true,
        title: Text(
          "Flora",
          style: const TextStyle(
            color: Color.fromARGB(255, 232, 30, 123),
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 170, 46, 92),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(
          context,
        ).copyWith(canvasColor: Color.fromARGB(255, 170, 46, 92)),
        child: BottomNavigationBar(
          selectedItemColor: const Color.fromARGB(255, 255, 210, 233),
          unselectedItemColor: Colors.white,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          onTap: (index) {
            Navigator.pop(context);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: "Shop"),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Favorites",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: "Cart",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 170, 46, 92),
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadOrders,
              color: const Color.fromARGB(255, 170, 46, 92),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: Text(
                        'My orders',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 170, 46, 92),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Current orders',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    _currentOrders.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'No current orders.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _currentOrders.length,
                            itemBuilder: (context, index) {
                              final order = _currentOrders[index];
                              return OrderCardWidget(
                                order: order,
                                onTap: () {
                                  // Use a Scaffold to ensure proper material context
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Scaffold(
                                        appBar: AppBar(
                                          backgroundColor: Colors.transparent,
                                          elevation: 0,
                                          title: Text(
                                            'Order Details',
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                255,
                                                170,
                                                46,
                                                92,
                                              ),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          leading: IconButton(
                                            icon: const Icon(Icons.arrow_back),
                                            color: const Color.fromARGB(
                                              255,
                                              170,
                                              46,
                                              92,
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                        ),
                                        body: Material(
                                          color: Colors.white,
                                          child: MobileOrderDetailsScreen(
                                            order: order,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Previous orders',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    _previousOrders.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'No previous orders.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _previousOrders.length,
                            itemBuilder: (context, index) {
                              final order = _previousOrders[index];
                              return OrderCardWidget(
                                order: order,
                                onTap: () {
                                  // Use a Scaffold to ensure proper material context
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Scaffold(
                                        appBar: AppBar(
                                          backgroundColor: Colors.transparent,
                                          elevation: 0,
                                          title: Text(
                                            'Order Details',
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                255,
                                                170,
                                                46,
                                                92,
                                              ),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          leading: IconButton(
                                            icon: const Icon(Icons.arrow_back),
                                            color: const Color.fromARGB(
                                              255,
                                              170,
                                              46,
                                              92,
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                        ),
                                        body: Material(
                                          color: Colors.white,
                                          child: MobileOrderDetailsScreen(
                                            order: order,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
