import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/layouts/main_layout.dart'; // DODANO - potrebno za navigaciju
import 'package:flora_mobile_app/models/product_model.dart';
import 'package:flora_mobile_app/screens/selected_category_products_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'categories_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> featuredProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeaturedProducts();
  }

  Future<List<String>> _fetchImageUrls(int productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Product/product_image_$productId'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> imagesJson = json.decode(response.body);
      return imagesJson.map((e) => e.toString()).toList();
    } else {
      return [];
    }
  }

  Future<void> _fetchFeaturedProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/Product/featured'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final List<Product> products = jsonData
          .map((item) => Product.fromJson(item))
          .toList();

      for (Product product in products) {
        product.imageUrls = await _fetchImageUrls(product.id);
      }

      setState(() {
        featuredProducts = products;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load featured products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              _buildSearchBar(),
              _buildFeaturedSection(),
              _buildBrowseByCategory(context),
              _buildBrowseByOccasions(),
              _buildRecommendedSection(),
              _buildScheduleSection(),
              _buildBlogSection(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.menu, color: Color(0xFFE91E63), size: 28),
          Image.asset('assets/images/Logo.png', width: 120, height: 120),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Color(0xFFE91E63),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.notifications, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (featuredProducts.isEmpty) {
      return const Center(child: Text("No featured products"));
    }

    return SizedBox(
      height: 240,
      child: PageView.builder(
        itemCount: featuredProducts.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, index) {
          final product = featuredProducts[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: product.imageUrls.isNotEmpty
                      ? NetworkImage(product.imageUrls.first)
                      : const NetworkImage(
                          'https://via.placeholder.com/400x200',
                        ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    const Color(0xFFE91E63).withOpacity(0.1),
                    BlendMode.overlay,
                  ),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFE91E63).withOpacity(0.8),
                    const Color(0xFFE91E63).withOpacity(0.6),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        MainLayout.of(context)?.openProductScreen(product);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFE91E63),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Shop now',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrowseByCategory(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Browse by Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCategoryItem('Bouquet', Icons.local_florist, context),
              _buildCategoryItem('Box', Icons.card_giftcard, context),
              _buildCategoryItem('Domes', Icons.home, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon, BuildContext context) {
    return GestureDetector(
      onTap: () {
        MainLayout.of(context)?.openCategoryScreen(0, title);
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Color(0xFFE91E63), size: 30),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseByOccasions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Browse by Occasions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Color(0xFFE91E63), size: 16),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOccasionItem('Wedding', Icons.favorite),
              _buildOccasionItem('Birthday', Icons.cake),
              _buildOccasionItem('Graduation', Icons.school),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOccasionItem(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        MainLayout.of(context)?.openOccasionScreen(title);
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xFFE91E63).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(0xFFE91E63), size: 25),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommended for you',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Color(0xFFE91E63), size: 16),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRecommendedItem('Spring Bliss'),
              _buildRecommendedItem('Pure Grace'),
              _buildRecommendedItem('SoftElegance'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedItem(String title) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE91E63).withOpacity(0.7),
              Color(0xFFE91E63).withOpacity(0.5),
            ],
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule an event decoration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFFE91E63),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      'Schedule now',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogSection() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Flora Blog',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Color(0xFFE91E63), size: 16),
            ],
          ),
          SizedBox(height: 15),
          _buildBlogItem('08-11-2021', 'Seasonal Picks'),
          SizedBox(height: 10),
          _buildBlogItem('08-11-2021', 'What\'s Blooming Now'),
        ],
      ),
    );
  }

  Widget _buildBlogItem(String date, String title) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(width: 60, height: 60),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                SizedBox(height: 5),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
