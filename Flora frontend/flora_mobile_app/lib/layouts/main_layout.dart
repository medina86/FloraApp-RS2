import 'package:flora_mobile_app/screens/account_screen.dart';
import 'package:flora_mobile_app/screens/categories_screen.dart';
import 'package:flora_mobile_app/screens/favorites_screen.dart';
import 'package:flora_mobile_app/screens/home_page.dart';
import 'package:flora_mobile_app/screens/product_by_occasion.dart';
import 'package:flora_mobile_app/screens/product_detail.screen.dart';
import 'package:flora_mobile_app/screens/selected_category_products_screen.dart';
import 'package:flora_mobile_app/models/product_model.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  final int userId;
  const MainLayout({super.key, required this.userId});

  static _MainLayoutState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainLayoutState>();

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  Widget? _selectedCategoryScreen;
  Widget? _selectedProductScreen;
  Widget? _selectedOccasionScreen;

  int? _currentCategoryId;
  String? _currentCategoryName;
  int? _currentOccasionId;
  String? _currentOccasionName;
  bool _openedFromHome = false;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(userId: widget.userId),
      CategoriesScreen(userId: widget.userId),
      FavouritesScreen(userId: widget.userId),
      const Text("Cart"),
      AccountScreen(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedCategoryScreen = null;
      _selectedProductScreen = null;
      _selectedOccasionScreen = null;
      _currentCategoryId = null;
      _currentCategoryName = null;
      _currentOccasionName = null;
    });
  }

  void openCategoryScreen(
    int categoryId,
    String categoryName, {
    bool fromHome = false,
  }) {
    print('Opening category: $categoryName (ID: $categoryId)');
    setState(() {
      _currentCategoryId = categoryId;
      _currentCategoryName = categoryName;
      _openedFromHome = fromHome;
      _selectedCategoryScreen = SelectedCategoryProductsScreen(
        categoryId: categoryId,
        categoryName: categoryName,
        userId: widget.userId,
      );
      _selectedProductScreen = null;
      _selectedOccasionScreen = null;
    });
  }

  void openProductScreen(Product product) {
    print('Opening product: ${product.name}');
    setState(() {
      _selectedProductScreen = ProductDetailScreen(
        product: product,
        userId: widget.userId,
      );
    });
  }

  void openOccasionScreen(String occasionName) {
    print('Opening occasion: $occasionName');
    setState(() {
      _currentOccasionName = occasionName;
      _selectedOccasionScreen = OccasionProductsScreen(
        occasionName: occasionName,
        userId: widget.userId,
      );
      _selectedCategoryScreen = null;
      _selectedProductScreen = null;
    });
  }

  void goBackToProductsList() {
    print('Going back to products list');
    setState(() {
      _selectedProductScreen = null;
    });
  }

  void goBackToCategories() {
    print('Going back to categories');
    setState(() {
      _selectedProductScreen = null;
      _selectedCategoryScreen = null;
      _selectedOccasionScreen = null;
      _currentCategoryId = null;
      _currentCategoryName = null;
      _currentOccasionName = null;
      _selectedIndex = _openedFromHome ? 0 : 1;
      _openedFromHome = false;
    });
  }

  void goBackToHome() {
    print('Going back to home');
    setState(() {
      _selectedProductScreen = null;
      _selectedCategoryScreen = null;
      _selectedOccasionScreen = null;
      _currentCategoryId = null;
      _currentCategoryName = null;
      _currentOccasionName = null;
      _selectedIndex = 0; // Home tab
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;

    if (_selectedProductScreen != null) {
      print('Showing product detail screen');
      currentScreen = _selectedProductScreen!;
    } else if (_selectedOccasionScreen != null) {
      print('Showing occasion products screen');
      currentScreen = _selectedOccasionScreen!;
    } else if (_selectedCategoryScreen != null) {
      print('Showing category products screen');
      currentScreen = _selectedCategoryScreen!;
    } else {
      print('Showing main page: $_selectedIndex');
      currentScreen = _pages[_selectedIndex];
    }

    return Scaffold(
      body: currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color.fromARGB(255, 170, 46, 92),
        selectedItemColor: const Color.fromARGB(255, 255, 210, 233),
        unselectedItemColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,
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
    );
  }
}
