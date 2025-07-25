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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                              childAspectRatio: 0.8,
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              MainLayout.of(context)?.goBackToCategories();
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFFE91E63),
              size: 24,
            ),
          ),
          const Text(
            'Flora',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
              fontStyle: FontStyle.italic,
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

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
              flex: 3,
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
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(2)} KM',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE91E63),
                          ),
                        ),
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
                            width: 30,
                            height: 30,
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