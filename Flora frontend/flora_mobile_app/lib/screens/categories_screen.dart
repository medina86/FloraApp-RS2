import 'dart:convert';
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/layouts/main_layout.dart';
import 'package:flora_mobile_app/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategoriesScreen extends StatefulWidget {
  final int userId;
  const CategoriesScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<Category>> _futureCategories;

  @override
  void initState() {
    super.initState();
    _futureCategories = fetchCategories();
  }

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/category'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> items = jsonResponse['items'];
      return items.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  final List<Color> categoryColors = [
    Colors.pink[100]!,
    Colors.pink[50]!,
    Colors.green[50]!,
    Colors.purple[50]!,
    Colors.green[100]!,
    Colors.orange[50]!,
    Colors.blue[50]!,
    Colors.yellow[50]!,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Category>>(
                future: _futureCategories,
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
                  } else {
                    final categories = snapshot.data ?? [];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.builder(
                        itemCount: categories.length + 1, 
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: _buildCustomBouquetCard(context),
                            );
                          } else {
                            final category = categories[index - 1]; 
                            final backgroundColor =
                                categoryColors[(index - 1) % categoryColors.length];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: _buildCategoryCard(
                                context,
                                category,
                                backgroundColor,
                              ),
                            );
                          }
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
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.menu, color: Color(0xFFE91E63), size: 24),
          Text(
            'Flora',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
              fontStyle: FontStyle.italic,
            ),
          ),
          Icon(Icons.notifications, color: Color(0xFFE91E63), size: 24),
        ],
      ),
    );
  }
        // Navigator.push(context, MaterialPageRoute(builder: (context) => CustomBouquetScreen()));
        // ili
        // MainLayout.of(context)?.openCustomBouquetScreen();

 
 Widget _buildCustomBouquetCard(BuildContext context) {
  return GestureDetector(
    onTap: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Custom Bouquets - Coming Soon!'),
          backgroundColor: Color(0xFFE91E63),
        ),
      );
    },
    child: Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        image: DecorationImage(
          image: AssetImage('assets/images/custom_bouqet.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent
                ],
              ),
            ),
          ),
          
          const Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            right: 60,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'CUSTOM BOUQUETS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, 
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildCategoryCard(
    BuildContext context,
    Category category,
    Color backgroundColor,
  ) {
    return GestureDetector(
      onTap: () {
        MainLayout.of(context)?.openCategoryScreen(category.id, category.name);
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (category.categoryImageUrl != null &&
                category.categoryImageUrl!.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(category.categoryImageUrl!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      backgroundColor.withOpacity(0.4),
                      BlendMode.overlay,
                    ),
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
            
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              right: 60,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  category.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black54,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}