import 'dart:convert';
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/layouts/main_layout.dart';
import 'package:flora_mobile_app/models/product_model.dart';
import 'package:flora_mobile_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Product>> fetchProductsByCategory(int categoryId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/product?categoryId=$categoryId'),
    headers: AuthProvider.getHeaders(),
  );
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final List<dynamic> items = jsonResponse['items'];
    return items
        .map((json) => Product.fromJson(json))
        .where((product) => product.active && product.isAvailable)
        .toList();
  } else {
    throw Exception('Failed to load products');
  }
}

Future<List<Product>> fetchProductsByCategoryName(String categoryName) async {
  final encodedName = Uri.encodeComponent(categoryName);
  final response = await http.get(
    Uri.parse('$baseUrl/product?categoryName=$encodedName'),
    headers: AuthProvider.getHeaders(),
  );
  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final List<dynamic> items = jsonResponse['items'];
    return items
        .map((json) => Product.fromJson(json))
        .where((product) => product.active && product.isAvailable)
        .toList();
  } else {
    throw Exception('Failed to load products');
  }
}

class SelectedCategoryProductsScreen extends StatefulWidget {
  final int? categoryId;
  final String categoryName;
  final int userId;

  const SelectedCategoryProductsScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    required this.userId,
  }) : super(key: key);

  @override
  _SelectedCategoryProductsScreenState createState() =>
      _SelectedCategoryProductsScreenState();
}

class _SelectedCategoryProductsScreenState
    extends State<SelectedCategoryProductsScreen> {
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null && widget.categoryId != 0) {
      _futureProducts = fetchProductsByCategory(widget.categoryId!);
    } else if (widget.categoryName.isNotEmpty) {
      _futureProducts = fetchProductsByCategoryName(widget.categoryName);
    } else {
      throw Exception('Either categoryId or categoryName must be provided.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              // Category title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.categoryName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE91E63),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Product>>(
                  future: _futureProducts,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE91E63),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No products found.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    } else {
                      final products = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio:
                                    0.7, // Adjusted from 0.8 to give more height
                              ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return _buildProductCard(product);
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Removed the _buildHeader method as we're now using the global header

  Widget _buildProductCard(Product product) {
    final imageUrl = (product.imageUrls.isNotEmpty)
        ? product.imageUrls.first
        : 'https://via.placeholder.com/150';

    return GestureDetector(
      onTap: () {
        MainLayout.of(context)?.openProductScreen(product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex:
                  5, // Adjusted from 3 to give proportionally less space to the image
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Product Info
            Expanded(
              flex:
                  4, // Adjusted from 2 to give proportionally more space to the text
              child: Padding(
                padding: const EdgeInsets.all(
                  8,
                ), // Reduced padding from 12 to 8
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 13, // Slightly reduced font size from 14
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            '${product.price.toStringAsFixed(2)} KM',
                            style: const TextStyle(
                              fontSize: 14, // Reduced from 16
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE91E63),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4), // Add small gap
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart!'),
                                backgroundColor: const Color(0xFFE91E63),
                              ),
                            );
                          },
                          child: Container(
                            width: 28, // Slightly smaller from 30
                            height: 28, // Slightly smaller from 30
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
