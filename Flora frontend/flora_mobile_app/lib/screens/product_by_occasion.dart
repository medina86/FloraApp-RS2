import 'dart:convert';
import 'package:flora_mobile_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flora_mobile_app/models/product_model.dart';
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/layouts/main_layout.dart';
import 'package:http/http.dart' as http;

Future<List<Product>> fetchProductsByOccasionName(String occasionName) async {
  try {
    final encodedName = Uri.encodeComponent(occasionName);

    print('🔍 Fetching products for occasion: $occasionName');
    print('🌐 URL: $baseUrl/product?occasionName=$encodedName');

    final response = await http.get(
      Uri.parse('$baseUrl/product?occasionName=$encodedName'),
      headers: AuthProvider.getHeaders(),
    );

    print('📡 Response status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> items = jsonResponse['items'];

      print('✅ Found ${items.length} products for occasion: $occasionName');

      final products = items
          .map((json) {
            final product = Product.fromJson(json);
            print('🖼️ Product: ${product.name} - Active: ${product.active} - Available: ${product.isAvailable}');
            return product;
          })
          .where((product) => product.active && product.isAvailable)
          .toList();

      print('✅ Returning ${products.length} active and available products');
      return products;
    } else {
      print('❌ Failed to load products: ${response.statusCode}');
      print('❌ Response body: ${response.body}');
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  } catch (e) {
    print('💥 Exception fetching products for occasion $occasionName: $e');
    rethrow;
  }
}

class OccasionProductsScreen extends StatefulWidget {
  final String occasionName;
  final int userId;

  const OccasionProductsScreen({
    Key? key,
    required this.occasionName,
    required this.userId,
  }) : super(key: key);

  @override
  _OccasionProductsScreenState createState() => _OccasionProductsScreenState();
}

class _OccasionProductsScreenState extends State<OccasionProductsScreen> {
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    print('🚀 Loading products for: ${widget.occasionName}');
    _futureProducts = fetchProductsByOccasionName(widget.occasionName);
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
            // Removed duplicate header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${widget.occasionName} Collection',
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
                    print('❌ FutureBuilder error: ${snapshot.error}');
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
                            'Error loading products',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _futureProducts = fetchProductsByOccasionName(
                                  widget.occasionName,
                                );
                              });
                            },
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No products found for this occasion.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  } else {
                    final products = snapshot.data!;
                    print('✅ Displaying ${products.length} products');
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
    ),
  );
  }

  // Removed the _buildHeader method as we're now using the global header

  Widget _buildProductCard(Product product) {
    print('🖼️ Building card for: ${product.name}');
    print('🖼️ Images: ${product.imageUrls}');
    print('🖼️ Images length: ${product.imageUrls.length}');

    // ISPRAVKA - isti kod kao categories
    final imageUrl = (product.imageUrls.isNotEmpty)
        ? product.imageUrls.first
        : 'https://via.placeholder.com/150';

    print('🖼️ Using imageUrl: $imageUrl');

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
                    onError: (error, stackTrace) {
                      print('❌ Image error for $imageUrl: $error');
                    },
                  ),
                ),
              ),
            ),
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
