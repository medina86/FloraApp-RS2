import 'package:flora_desktop_app/models/order_model.dart';
import 'package:flora_desktop_app/models/paged_result.dart';
import 'package:flora_desktop_app/providers/order_provider.dart';
import 'package:flora_desktop_app/screens/order_detail_screen.dart';
import 'package:flora_desktop_app/widgets/order_list_table_widget.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with TickerProviderStateMixin {
  // Pagination state
  final int _pageSize = 5; // Srednja vrijednost za lakše testiranje
  int _currentActivePage = 0;
  int _currentCompletedPage = 0;
  int? _totalActiveCount = 0;
  int? _totalCompletedCount = 0;

  // Search state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;

  // Tab controller
  late TabController _tabController;

  // Data state
  List<OrderModel> _pendingOrders = [];
  List<OrderModel> _completedOrders = [];
  bool _isLoadingPending = false;
  bool _isLoadingCompleted = false;
  OrderModel? _selectedOrder;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _fetchActiveOrders();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 0) {
      // Active orders tab
      if (_pendingOrders.isEmpty) {
        _fetchActiveOrders();
      }
    } else {
      // Completed orders tab
      if (_completedOrders.isEmpty) {
        _fetchCompletedOrders();
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    // Debounce search to avoid too many API calls
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _resetPaginationAndSearch();
    });
  }

  void _resetPaginationAndSearch() {
    setState(() {
      _currentActivePage = 0;
      _currentCompletedPage = 0;
    });

    if (_tabController.index == 0) {
      _fetchActiveOrders();
    } else {
      _fetchCompletedOrders();
    }
  }

  void _onPageChanged(int page, bool isActiveTab) {
    if (isActiveTab) {
      setState(() {
        _currentActivePage = page;
      });
      _fetchActiveOrders();
    } else {
      setState(() {
        _currentCompletedPage = page;
      });
      _fetchCompletedOrders();
    }
  }

  Future<void> _fetchActiveOrders() async {
    setState(() {
      _isLoadingPending = true;
    });

    try {
      final result = await OrderApiService.getActiveOrdersPaginated(
        page: _currentActivePage,
        pageSize: _pageSize,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );

      print(
        'Debug - Active orders: page=${_currentActivePage}, items=${result.items.length}, total=${result.totalCount}',
      );

      setState(() {
        _pendingOrders = result.items;
        _totalActiveCount = result.totalCount;
      });
    } catch (e) {
      print('Error fetching active orders: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading active orders: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingPending = false;
      });
    }
  }

  Future<void> _fetchCompletedOrders() async {
    setState(() {
      _isLoadingCompleted = true;
    });

    try {
      final result = await OrderApiService.getCompletedOrdersPaginated(
        page: _currentCompletedPage,
        pageSize: _pageSize,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );

      setState(() {
        _completedOrders = result.items;
        _totalCompletedCount = result.totalCount;
      });
    } catch (e) {
      print('Error fetching completed orders: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading completed orders: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
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
    // Refresh current tab
    if (_tabController.index == 0) {
      _fetchActiveOrders();
    } else {
      _fetchCompletedOrders();
    }
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
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Search bar
            Container(
              width: 400,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Search orders...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
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
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerHeight: 0,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color.fromARGB(255, 170, 46, 92),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: const Color.fromARGB(255, 255, 102, 204),
                  ),
                  tabs: const [
                    Tab(text: 'Active Orders', height: 40),
                    Tab(text: 'Completed Orders', height: 40),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersTab(isActiveTab: true),

                  _buildOrdersTab(isActiveTab: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab({required bool isActiveTab}) {
    final isLoading = isActiveTab ? _isLoadingPending : _isLoadingCompleted;
    final orders = isActiveTab ? _pendingOrders : _completedOrders;
    final totalCount = isActiveTab ? _totalActiveCount : _totalCompletedCount;
    final currentPage = isActiveTab
        ? _currentActivePage
        : _currentCompletedPage;
    final totalPages = (totalCount! / _pageSize).ceil();

    print(
      'Debug - BuildOrdersTab: isActive=$isActiveTab, orders=${orders.length}, totalCount=$totalCount, totalPages=$totalPages',
    );

    return Column(
      children: [
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 170, 46, 92),
                  ),
                )
              : OrderListTable(
                  orders: orders,
                  onOrderSelected: _onOrderSelected,
                  onRefresh: () => isActiveTab
                      ? _fetchActiveOrders()
                      : _fetchCompletedOrders(),
                  orderStatus: isActiveTab ? 'Active' : 'Completed',
                ),
        ),

        // Pagination controls - Uvijek prikaži za testiranje
        const SizedBox(height: 16),
        _buildPaginationControls(
          currentPage:
              currentPage + 1, // Convert 0-based to 1-based for display
          totalPages: totalPages.clamp(1, 100), // Osiguraj da nije 0
          onPageChanged: (page) =>
              _onPageChanged(page - 1, isActiveTab), // Convert back to 0-based
        ),
      ],
    );
  }

  Widget _buildPaginationControls({
    required int currentPage,
    required int totalPages,
    required Function(int) onPageChanged,
  }) {
    print(
      'Debug - PaginationControls: currentPage=$currentPage, totalPages=$totalPages',
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        IconButton(
          onPressed: currentPage > 1
              ? () => onPageChanged(currentPage - 1)
              : null,
          icon: const Icon(Icons.chevron_left),
          style: IconButton.styleFrom(
            backgroundColor: currentPage > 1
                ? const Color.fromARGB(255, 170, 46, 92)
                : Colors.grey.shade300,
            foregroundColor: currentPage > 1 ? Colors.white : Colors.grey,
          ),
        ),

        const SizedBox(width: 16),

        // Page numbers (show max 5 pages)
        ...List.generate((totalPages > 5) ? 5 : totalPages, (index) {
          int page;
          if (totalPages <= 5) {
            page = index + 1;
          } else {
            // Smart pagination - show pages around current page
            final start = (currentPage - 2).clamp(1, totalPages - 4);
            page = start + index;
          }

          final isCurrentPage = page == currentPage;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onPageChanged(page),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCurrentPage
                      ? const Color.fromARGB(255, 170, 46, 92)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    page.toString(),
                    style: TextStyle(
                      color: isCurrentPage ? Colors.white : Colors.black,
                      fontWeight: isCurrentPage
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(width: 16),

        // Next button
        IconButton(
          onPressed: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
          style: IconButton.styleFrom(
            backgroundColor: currentPage < totalPages
                ? const Color.fromARGB(255, 170, 46, 92)
                : Colors.grey.shade300,
            foregroundColor: currentPage < totalPages
                ? Colors.white
                : Colors.grey,
          ),
        ),

        const SizedBox(width: 16),

        // Page info text
        Text(
          'Page $currentPage of $totalPages (Total: $_totalActiveCount)',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
