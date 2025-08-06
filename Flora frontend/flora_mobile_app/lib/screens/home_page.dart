import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/layouts/main_layout.dart';
import 'package:flora_mobile_app/models/product_model.dart';
import 'package:flora_mobile_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math'; // Potrebno za funkciju min
import 'package:http/http.dart' as http;
import 'package:flora_mobile_app/models/blog_post.dart';
import 'package:flora_mobile_app/providers/blog_api.dart';
import 'package:flora_mobile_app/helpers/image_loader.dart';
import 'package:flora_mobile_app/providers/blog_provider_enhanced.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({super.key, required this.userId});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> featuredProducts = [];
  List<Product> recommendedProducts = [];
  BlogPost? latestBlogPost;
  bool isLoading = true;
  bool isLoadingBlog = true;
  bool isLoadingRecommendations = true;

  @override
  void initState() {
    super.initState();
    _fetchFeaturedProducts();
    _fetchLatestBlogPost();
    _fetchRecommendedProducts();
  }

  Future<List<String>> _fetchImageUrls(int productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Product/product_image_$productId'),
      headers: AuthProvider.getHeaders(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> imagesJson = json.decode(response.body);
      return imagesJson.map((e) => e.toString()).toList();
    } else {
      return [];
    }
  }

  Future<void> _fetchFeaturedProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/Product/featured'),
      headers: AuthProvider.getHeaders(),
    );
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

  Future<void> _fetchRecommendedProducts() async {
    try {
      setState(() {
        isLoadingRecommendations = true;
      });

      final url = Uri.parse(
        '$baseUrl/Recommendations/user/${widget.userId}?maxResults=5',
      );
      final response = await http.get(url, headers: AuthProvider.getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        if (jsonData.isEmpty) {
          setState(() {
            recommendedProducts = [];
            isLoadingRecommendations = false;
          });
          return;
        }

        final List<Product> products = jsonData
            .map((item) => Product.fromJson(item))
            .toList();

        for (Product product in products) {
          if (!mounted) return;
          product.imageUrls = await _fetchImageUrls(product.id);
        }

        if (!mounted) return;
        setState(() {
          recommendedProducts = products;
          isLoadingRecommendations = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          recommendedProducts = [];
          isLoadingRecommendations = false;
        });
        print('Error loading recommended products: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in _fetchRecommendedProducts: $e');
      if (!mounted) return;
      setState(() {
        recommendedProducts = [];
        isLoadingRecommendations = false;
      });
    }
  }

  Future<void> _fetchLatestBlogPost() async {
    try {
      setState(() {
        isLoadingBlog = true;
      });

      final posts = await BlogApiService.getBlogPosts();

      if (posts.isNotEmpty) {
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (mounted) {
          setState(() {
            latestBlogPost = posts.first;
            isLoadingBlog = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            latestBlogPost = null;
            isLoadingBlog = false;
          });
        }
      }
    } catch (e) {
      print('Error loading latest blog post: $e');
      if (mounted) {
        setState(() {
          latestBlogPost = null;
          isLoadingBlog = false;
        });
      }
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
              _buildCategoryItem('Bouquets', Icons.local_florist, context),
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
        MainLayout.of(context)?.openCategoryScreen(0, title, fromHome: true);
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
              _buildOccasionItem('Newborns', Icons.favorite),
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
            ],
          ),
          SizedBox(height: 15),

          if (isLoadingRecommendations)
            Container(
              height: 100,
              alignment: Alignment.center,
              child: CircularProgressIndicator(color: Color(0xFFE91E63)),
            )
          else if (recommendedProducts.isNotEmpty)
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recommendedProducts.length,
                itemBuilder: (context, index) {
                  return _buildRecommendedItem(recommendedProducts[index]);
                },
              ),
            )
          else
            Container(
              height: 100,
              alignment: Alignment.center,
              child: Text('No recommendations available'),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendedItem(Product product) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          MainLayout.of(context)?.openProductScreen(product);
        },
        child: Container(
          width: 120,
          height: 160,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Slika proizvoda
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: product.imageUrls.isNotEmpty
                    ? Image.network(
                        product.imageUrls.first,
                        width: 120,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 90,
                            color: Colors.grey[200],
                            child: Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      )
                    : Container(
                        width: 120,
                        height: 90,
                        color: Colors.grey[200],
                        child: Icon(Icons.image, color: Colors.grey),
                      ),
              ),

              // Naziv i cijena
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 6.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${product.price.toStringAsFixed(2)} KM',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      children: [
        Padding(
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
                        onPressed: () {
                          MainLayout.openDecorationRequest(context);
                        },
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
                            color: Color(0xFFE91E63),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Donations section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 170, 46, 92).withOpacity(0.7),
                  Color.fromARGB(255, 170, 46, 92).withOpacity(0.5),
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
                        'Support our donation campaigns',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Open donations using the static method of MainLayout
                          MainLayout.openDonations(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color.fromARGB(255, 170, 46, 92),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          'Donate now',
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
        ),
      ],
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
              TextButton(
                onPressed: () {
                  MainLayout.openBlog(context);
                },
                child: Row(
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(color: Color(0xFFE91E63)),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFFE91E63),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),

          if (isLoadingBlog)
            Container(
              height: 100,
              alignment: Alignment.center,
              child: CircularProgressIndicator(color: Color(0xFFE91E63)),
            )
          else if (latestBlogPost != null)
            InkWell(
              onTap: () {
                MainLayout.openBlogPost(context, latestBlogPost!.id);
              },
              child: _buildLatestBlogItem(latestBlogPost!),
            )
          else
            Container(
              height: 100,
              alignment: Alignment.center,
              child: Text('No blog posts available'),
            ),
        ],
      ),
    );
  }

  Widget _buildLatestBlogItem(BlogPost blog) {
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: blog.imageUrls.isNotEmpty
                ? ImageLoader.loadImage(
                    url:
                        BlogProviderEnhanced.getValidImageUrl(blog.imageUrls) ??
                        '',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
          ),

          SizedBox(width: 15),

          // Blog text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd.MM.yyyy').format(blog.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                SizedBox(height: 5),
                Text(
                  blog.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5),
                Text(
                  blog.content,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
