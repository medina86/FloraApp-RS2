import 'package:flora_mobile_app/screens/account_screen.dart';
import 'package:flora_mobile_app/screens/cart_screen.dart';
import 'package:flora_mobile_app/screens/categories_screen.dart';
import 'package:flora_mobile_app/screens/favorites_screen.dart';
import 'package:flora_mobile_app/screens/home_page.dart';
import 'package:flora_mobile_app/screens/product_by_occasion.dart';
import 'package:flora_mobile_app/screens/product_detail.screen.dart';
import 'package:flora_mobile_app/screens/selected_category_products_screen.dart';
import 'package:flora_mobile_app/screens/donation_campaigns_screen.dart';
import 'package:flora_mobile_app/screens/blog_list_screen.dart';
import 'package:flora_mobile_app/screens/blog_post_detail_screen.dart';
import 'package:flora_mobile_app/screens/decoration_request_screen.dart';
import 'package:flora_mobile_app/screens/my_orders_screen.dart';
import 'package:flora_mobile_app/screens/my_events_screen.dart';
import 'package:flora_mobile_app/screens/suggested_decoration_screen.dart';
import 'package:flora_mobile_app/screens/custom_bouquet_screen.dart';
import 'package:flora_mobile_app/screens/order_details_screen.dart';
import 'package:flora_mobile_app/models/product_model.dart';
import 'package:flora_mobile_app/models/order.dart';
import 'package:flora_mobile_app/widgets/global_app_header.dart';
import 'package:flora_mobile_app/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  final int userId;
  const MainLayout({super.key, required this.userId});

  static _MainLayoutState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainLayoutState>();

  static void openDonations(BuildContext context) {
    final mainLayout = of(context);
    if (mainLayout != null) {
      mainLayout.openDonationsScreen();
    }
  }

  static void openBlog(BuildContext context) {
    final mainLayout = of(context);
    if (mainLayout != null) {
      mainLayout.openBlogScreen();
    }
  }

  static void openBlogPost(BuildContext context, int blogPostId) {
    final mainLayout = of(context);
    if (mainLayout != null) {
      mainLayout.openBlogPostScreen(blogPostId);
    }
  }

  static void openDecorationRequest(BuildContext context) {
    final mainLayout = of(context);
    if (mainLayout != null) {
      mainLayout.openDecorationRequestScreen();
    }
  }

  static void openMyOrders(BuildContext context) {
    final mainLayout = of(context);
    if (mainLayout != null) {
      mainLayout.openMyOrdersScreen();
    }
  }

  static void openOrderDetails(BuildContext context, OrderModel order) {
    final mainLayout = of(context);
    if (mainLayout != null) {
      mainLayout.openOrderDetailsScreen(order);
    }
  }

  static void openMyEvents(BuildContext context) {
    final mainLayout = of(context);
    if (mainLayout != null) {
      mainLayout.openMyEventsScreen();
    }
  }

  static void openDecorationSuggestions(
    BuildContext context,
    DecorationRequest eventRequest,
  ) {
    final mainLayout = of(context);
    if (mainLayout != null) {
      mainLayout.openDecorationSuggestionsScreen(eventRequest);
    }
  }

  static void openCustomBouquets(BuildContext context) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => MainLayout(
              userId:
                  (context.findAncestorStateOfType<_MainLayoutState>()
                          as _MainLayoutState)
                      .widget
                      .userId,
            ),
          ),
        )
        .then((_) {
          final mainLayout = of(context);
          if (mainLayout != null) {
            mainLayout.openCustomBouquetScreen();
          }
        });
  }

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
      CartScreen(userId: widget.userId),
      AccountScreenWrapper(userId: widget.userId),
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
    setState(() {
      _selectedProductScreen = ProductDetailScreen(
        product: product,
        userId: widget.userId,
        onBack: goBackToProductsList,
        onOpenCart: openCartTab,
      );
    });
  }

  void openOccasionScreen(String occasionName) {
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

  void openDonationsScreen() {
    setState(() {
      final donationsScreen = DonationCampaignsScreen(
        userId: widget.userId,
        fromHomeScreen: true,
        onBack: goBackToHome,
      );

      _selectedProductScreen = null;
      _selectedCategoryScreen = null;
      _selectedOccasionScreen = null;
      _currentCategoryId = null;
      _currentCategoryName = null;
      _currentOccasionName = null;

      _selectedOccasionScreen = donationsScreen;
    });
  }

  void openBlogScreen() {
    setState(() {
      final blogScreen = BlogListScreen(
        fromHomeScreen: true,
        onBack: goBackToHome,
      );

      _selectedProductScreen = null;
      _selectedCategoryScreen = null;
      _selectedOccasionScreen = null;
      _currentCategoryId = null;
      _currentCategoryName = null;
      _currentOccasionName = null;

      _selectedOccasionScreen = blogScreen;
    });
  }

  void openDecorationRequestScreen() {
    setState(() {
      final decorationRequestScreen = DecorationRequestScreen(
        userId: widget.userId,
      );

      _selectedProductScreen = null;
      _selectedCategoryScreen = null;
      _selectedOccasionScreen = null;
      _currentCategoryId = null;
      _currentCategoryName = null;
      _currentOccasionName = null;

      _selectedOccasionScreen = decorationRequestScreen;
    });
  }

  void openMyOrdersScreen() {
    setState(() {
      _selectedProductScreen = null;
      _selectedCategoryScreen = null;
      _selectedOccasionScreen = MyOrdersScreen(userId: widget.userId);
      _currentCategoryId = null;
      _currentCategoryName = null;
      _currentOccasionName = "My Orders"; // Set screen name for header
    });
  }

  void openMyEventsScreen() {
    setState(() {
      // Set the screen directly without wrapping in a Scaffold
      _selectedProductScreen = null;
      _selectedCategoryScreen = null;
      _selectedOccasionScreen = MyEventsScreen(userId: widget.userId);
      _currentCategoryId = null;
      _currentCategoryName = null;
      _currentOccasionName = "My Events"; // Set screen name for header
    });
  }

  void openOrderDetailsScreen(OrderModel order) {
    setState(() {
      _selectedProductScreen = null;
      _selectedCategoryScreen = null;
      _selectedOccasionScreen = MobileOrderDetailsScreen(
        order: order,
        showAppBar: false, // Don't show AppBar since MainLayout provides one
      );
      _currentCategoryId = null;
      _currentCategoryName = null;
      _currentOccasionName = "Order Details"; // Set screen name for header
    });
  }

  void openDecorationSuggestionsScreen(DecorationRequest eventRequest) {
    setState(() {
      final suggestionsScreen = DecorationSuggestionsScreen(
        eventRequest: eventRequest,
      );

      _selectedProductScreen = null;
      _selectedCategoryScreen = null;
      _selectedOccasionScreen = null;
      _currentCategoryId = null;
      _currentCategoryName = null;
      _currentOccasionName = null;

      _selectedOccasionScreen = suggestionsScreen;
    });
  }

  void openCustomBouquetScreen() {
    setState(() {
      // Set the screen directly without wrapping in a Scaffold
      _selectedProductScreen = null;
      _selectedCategoryScreen = null;
      _selectedOccasionScreen = CreateCustomBouquetScreen(
        userId: widget.userId,
      );
      _currentCategoryId = null;
      _currentCategoryName = null;
      _currentOccasionName = "Custom Bouquet"; // Set screen name for header
    });
  }

  void openBlogPostScreen(int blogPostId) {
    setState(() {
      final blogPostScreen = BlogPostDetailScreen(
        postId: blogPostId,
        onBack: openBlogScreen,
      );

      _selectedProductScreen = null;
      _selectedCategoryScreen = null;
      _selectedOccasionScreen = null;
      _currentCategoryId = null;
      _currentCategoryName = null;
      _currentOccasionName = null;

      _selectedOccasionScreen = blogPostScreen;
    });
  }

  void goBackToProductsList() {
    setState(() => _selectedProductScreen = null);
  }

  void goBackToCategories() {
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

  // Enhanced back navigation method to handle all screens properly
  void goBackToHome() {
    setState(() {
      _selectedProductScreen = null;
      _selectedCategoryScreen = null;
      _selectedOccasionScreen = null;
      _currentCategoryId = null;
      _currentCategoryName = null;
      _currentOccasionName = null;
      _selectedIndex = 0; // Always go back to home tab
      _openedFromHome = false;
    });
  }

  void openCartTab() {
    setState(() {
      _selectedIndex = 3;
      _selectedProductScreen = null;
      _selectedCategoryScreen = null;
      _selectedOccasionScreen = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;

    if (_selectedProductScreen != null) {
      currentScreen = _selectedProductScreen!;
    } else if (_selectedOccasionScreen != null) {
      currentScreen = _selectedOccasionScreen!;
    } else if (_selectedCategoryScreen != null) {
      currentScreen = _selectedCategoryScreen!;
    } else {
      currentScreen = _pages[_selectedIndex];
    }

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        if (_selectedProductScreen != null) {
          goBackToProductsList();
          return false; // Don't exit the app
        } else if (_selectedCategoryScreen != null) {
          goBackToCategories();
          return false; // Don't exit the app
        } else if (_selectedOccasionScreen != null) {
          goBackToHome();
          return false; // Don't exit the app
        } else if (_selectedIndex != 0) {
          // If not on home screen, go to home
          setState(() {
            _selectedIndex = 0;
          });
          return false; // Don't exit the app
        } else {
          // If on home screen, allow normal back behavior (exit app)
          return true;
        }
      },
      child: Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: GlobalAppHeader(
        scaffoldKey: scaffoldKey,
        showBackButton:
            _selectedProductScreen != null ||
            _selectedCategoryScreen != null ||
            _selectedOccasionScreen != null,
        onBackPressed: () {
          if (_selectedProductScreen != null) {
            goBackToProductsList();
          } else if (_selectedCategoryScreen != null) {
            goBackToCategories();
          } else if (_selectedOccasionScreen != null) {
            goBackToHome();
          }
        },
        // Pass the correct title based on current screen
        title: _currentOccasionName != null
            ? _currentOccasionName!
            : _currentCategoryName != null
            ? _currentCategoryName!
            : _selectedIndex == 0
            ? 'Home'
            : _selectedIndex == 1
            ? 'Shop'
            : _selectedIndex == 2
            ? 'Favorites'
            : _selectedIndex == 3
            ? 'Cart'
            : _selectedIndex == 4
            ? 'Account'
            : 'Flora',
      ),
      drawer: AppDrawer(
        userId: widget.userId,
        onNavigate: (index) {
          _onItemTapped(index);
          scaffoldKey.currentState?.closeDrawer();
        },
      ),
      body: Material(color: Colors.white, child: currentScreen),
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
      ),
    );
  }
}
