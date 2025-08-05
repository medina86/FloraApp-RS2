import 'dart:convert';
import 'package:flora_desktop_app/providers/base_provider.dart';
import 'package:flora_desktop_app/screens/add_product_screen.dart';
import 'package:flora_desktop_app/screens/edit_product_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flora_desktop_app/layouts/constants.dart';
import 'package:flora_desktop_app/providers/product_provider.dart';

class ProductsPage extends StatefulWidget {
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  List<Category> categories = [];
  String selectedCategory = 'All';
  bool isLoading = true;
  String searchQuery = '';
  bool? activeFilter; // null = all, true = active only, false = inactive only
  bool? availableFilter; // null = all, true = available only, false = unavailable only
  final TextEditingController _searchController = TextEditingController();
  
  // Pagination variables
  int currentPage = 0;
  int pageSize = 10;
  int? totalItems;
  int? totalPages;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([fetchProducts(), fetchCategories()]);
  }

  Future<void> fetchCategories() async {
    try {
      final categories = await BaseApiService.get<List<Category>>('/Category', (
        data,
      ) {
        if (data is List) {
          return data.map((item) => Category.fromJson(item)).toList();
        } else if (data is Map<String, dynamic>) {
          final items = data['items'] ?? data['data'] ?? [];
          return (items as List)
              .map((item) => Category.fromJson(item))
              .toList();
        }
        return <Category>[];
      });

      setState(() {
        this.categories = categories;
      });
    } on UnauthorizedException catch (e) {
      _handleAuthError(e.message);
    } on ApiException catch (e) {
      print('Error loading categories: ${e.message}');
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> fetchProductImages(Product product) async {
    try {
      final imageUrls = await BaseApiService.get<List<String>>(
        '/Product/product_image_${product.id}',
        (data) => (data as List).cast<String>(),
      );
      product.imageUrls = imageUrls;
    } on UnauthorizedException catch (e) {
      _handleAuthError(e.message);
    } catch (e) {
      print('Error fetching images for product ${product.id}: $e');
    }
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      Map<String, dynamic> queryParams = {
        'page': currentPage.toString(),
        'pageSize': pageSize.toString(),
        'includeTotalCount': 'true',
      };

      if (searchQuery.isNotEmpty) {
        queryParams['name'] = searchQuery;
      }
      if (activeFilter != null) {
        queryParams['active'] = activeFilter.toString();
      }
      if (availableFilter != null) {
        queryParams['isAvailable'] = availableFilter.toString();
      }

      final response = await BaseApiService.getWithParams<Map<String, dynamic>>(
        '/Product',
        queryParams,
        (data) {
          return data as Map<String, dynamic>;
        },
      );

      List<Product> productsResponse = [];

      if (response.containsKey('items')) {
        final items = response['items'] as List;
        productsResponse = items.map((item) => Product.fromJson(item)).toList();
        
        // Postavimo ukupni broj proizvoda ako je dostupan
        if (response.containsKey('totalCount')) {
          totalItems = response['totalCount'] as int;
          totalPages = (totalItems! / pageSize).ceil();
        }
      }

      // Dohvatanje slika za svaki proizvod
      for (var product in productsResponse) {
        await fetchProductImages(product);
      }

      setState(() {
        products = productsResponse;
        if (selectedCategory != 'All') {
          _applyLocalFilters(); // Koristimo lokalno filtriranje samo za kategoriju
        } else {
          filteredProducts = productsResponse; // Za ostale filtere, API nam vraća već filtrirane rezultate
        }
        isLoading = false;
      });
    } on UnauthorizedException catch (e) {
      _handleAuthError(e.message);
      setState(() => isLoading = false);
    } on ApiException catch (e) {
      print('Error loading products: ${e.message}');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleAuthError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication error: $message'),
          backgroundColor: Colors.red,
        ),
      );
      // Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _applyLocalFilters() {
    List<Product> filtered = List.from(products);

    if (selectedCategory != 'All') {
      filtered = filtered
          .where((product) => product.categoryName == selectedCategory)
          .toList();
    }

    setState(() {
      // Ažuriranje paginacije za lokalne filtere
      totalItems = filtered.length;
      totalPages = (totalItems! / pageSize).ceil();
      
      // Osiguramo da currentPage ne ide izvan granica
      if (currentPage >= totalPages! && totalPages! > 0) {
        currentPage = totalPages! - 1;
      }
      
      // Primijenimo paginaciju na filtrirane proizvode
      if (totalItems! > pageSize) {
        int startIndex = currentPage * pageSize;
        int endIndex = startIndex + pageSize;
        if (endIndex > filtered.length) {
          endIndex = filtered.length;
        }
        
        filteredProducts = filtered.sublist(startIndex, endIndex);
      } else {
        filteredProducts = filtered;
      }
    });
  }

  Future<void> searchProducts(String query) async {
    setState(() {
      searchQuery = query;
      currentPage = 0; // Reset na prvu stranicu kada pretražujemo
    });
    await fetchProducts();
  }

  void _updateFilters() async {
    setState(() {
      currentPage = 0; // Reset na prvu stranicu kada mijenjamo filtere
    });
    await fetchProducts();
  }

  void filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      currentPage = 0; 
    });
    _applyLocalFilters();
  }

  String getInitials(String name) {
    if (name.isEmpty) return 'P';
    List<String> words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name[0].toUpperCase();
  }

  Widget _buildPlaceholder(String productName) {
    return Container(
      color: Color(0xFFE91E63).withOpacity(0.1),
      child: Center(
        child: Text(
          getInitials(productName),
          style: TextStyle(
            color: Color(0xFFE91E63),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicators(Product product) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        // Active status - zelena tačkica
        if (product.active)
          Tooltip(
            message: 'Active',
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),

        // Inactive status - siva tačkica
        if (!product.active)
          Tooltip(
            message: 'Inactive',
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
          ),

        // Available status - plava tačkica
        if (product.isAvailable)
          Tooltip(
            message: 'Available',
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),

        // Unavailable status - crvena tačkica
        if (!product.isAvailable)
          Tooltip(
            message: 'Unavailable',
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                shape: BoxShape.circle,
              ),
            ),
          ),

        // NEW badge
        if (product.isNew)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'NEW',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        // FEATURED badge
        if (product.isFeatured)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'FEATURED',
              style: TextStyle(
                fontSize: 10,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  void _showImageDialog(Product product) {
    if (product.imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No image available for this product'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
              ),
              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFE91E63),
                                    ),
                                  ),
                                  if (product.description != null)
                                    Text(
                                      product.description!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.close),
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Hero(
                          tag: '$baseUrl/product_image_${product.id}',
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              child: Image.network(
                                product.imageUrls.first,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 300,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            size: 48,
                                            color: Colors.grey.shade400,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Failed to load image',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 300,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFFE91E63),
                                                ),
                                          ),
                                        ),
                                      );
                                    },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryNames = ['All', ...categories.map((c) => c.name)];
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Products',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE91E63),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddProductPage(categories: categories),
                    ),
                  );
                  if (result == true) {
                    await fetchProducts();
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'ADD NEW',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          Row(
            children: [
              // Search
              Expanded(
                flex: 2,
                child: Container(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFFE91E63)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      searchProducts(value);
                    },
                  ),
                ),
              ),

              SizedBox(width: 16),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButton<String>(
                  value: selectedCategory,
                  hint: Text('Category'),
                  underline: SizedBox(),
                  items: categoryNames
                      .map(
                        (cat) => DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      filterByCategory(value);
                    }
                  },
                ),
              ),

              SizedBox(width: 16),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Active'),
                    SizedBox(width: 8),
                    Checkbox(
                      value: activeFilter,
                      tristate: true,
                      onChanged: (value) {
                        setState(() {
                          activeFilter = value;
                        });
                        _updateFilters();
                      },
                      activeColor: Color(0xFFE91E63),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 16),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Available'),
                    SizedBox(width: 8),
                    Checkbox(
                      value: availableFilter,
                      tristate: true,
                      onChanged: (value) {
                        setState(() {
                          availableFilter = value;
                        });
                        _updateFilters();
                      },
                      activeColor: Color(0xFFE91E63),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 30),

          Expanded(
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
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Product',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Price',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Status',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        SizedBox(width: 100),
                      ],
                    ),
                  ),
                  Expanded(
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : filteredProducts.isEmpty
                        ? Center(
                            child: Text(
                              'No products found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: ListView.separated(
                                  itemCount: filteredProducts.length,
                                  separatorBuilder: (context, index) =>
                                      Divider(height: 1, color: Colors.grey.shade200),
                                  itemBuilder: (context, index) {
                                    final product = filteredProducts[index];
                                    return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () =>
                                                _showImageDialog(product),
                                            child: Hero(
                                              tag:
                                                  'product_image_${product.id}',
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                  child:
                                                      product
                                                          .imageUrls
                                                          .isNotEmpty
                                                      ? Image.network(
                                                          product
                                                              .imageUrls
                                                              .first,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return _buildPlaceholder(
                                                                  product.name,
                                                                );
                                                              },
                                                          loadingBuilder:
                                                              (
                                                                context,
                                                                child,
                                                                loadingProgress,
                                                              ) {
                                                                if (loadingProgress ==
                                                                    null)
                                                                  return child;
                                                                return Container(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade100,
                                                                  child: Center(
                                                                    child: SizedBox(
                                                                      width: 16,
                                                                      height:
                                                                          16,
                                                                      child: CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            2,
                                                                        valueColor:
                                                                            AlwaysStoppedAnimation<
                                                                              Color
                                                                            >(
                                                                              Color(
                                                                                0xFFE91E63,
                                                                              ),
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                        )
                                                      : _buildPlaceholder(
                                                          product.name,
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (product.description != null)
                                                  Text(
                                                    product.description!,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                Text(
                                                  product.categoryName ??
                                                      'Unknown',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade500,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Price
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${product.price.toStringAsFixed(2)} KM',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    // Status
                                    Expanded(
                                      flex: 2,
                                      child: _buildStatusIndicators(product),
                                    ),
                                    // Actions
                                    SizedBox(
                                      width: 100,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit_outlined,
                                              color: Colors.blue.shade600,
                                              size: 20,
                                            ),
                                            onPressed: () async {
                                              final result =
                                                  await showEditProductDialog(
                                                    context,
                                                    product,
                                                    categories,
                                                  );
                                              if (result == true) {
                                                await fetchProducts();
                                              }
                                            },
                                            tooltip: 'Edit Product',
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete_outline,
                                              color: Colors.red.shade400,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                _showDeleteDialog(product),
                                            tooltip: 'Delete Product',
                                          ),
                                        ],
                                      ),
                                    ),
                                                             ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ]
        ),
            ),          ),
          // Pagination controls
          if (totalPages != null && totalPages! > 1)
            Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left),
                    onPressed: currentPage > 0
                        ? () {
                            setState(() {
                              currentPage--;
                            });
                            if (selectedCategory != 'All') {
                              _applyLocalFilters(); // Lokalna paginacija za kategorije
                            } else {
                              fetchProducts(); // API paginacija za ostalo
                            }
                          }
                        : null,
                    color: currentPage > 0
                        ? Color(0xFFE91E63)
                        : Colors.grey.shade400,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Page ${currentPage + 1} of $totalPages',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.chevron_right),
                    onPressed: totalPages != null &&
                            currentPage < totalPages! - 1
                        ? () {
                            setState(() {
                              currentPage++;
                            });
                            if (selectedCategory != 'All') {
                              _applyLocalFilters(); // Lokalna paginacija za kategorije
                            } else {
                              fetchProducts(); // API paginacija za ostalo
                            }
                          }
                        : null,
                    color: totalPages != null &&
                            currentPage < totalPages! - 1
                        ? Color(0xFFE91E63)
                        : Colors.grey.shade400,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }


  void _showDeleteDialog(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  final success = await BaseApiService.delete(
                    '/Product/${product.id}',
                  );

                  if (success) {
                    setState(() {
                      products.removeWhere((p) => p.id == product.id);
                      filteredProducts.removeWhere((p) => p.id == product.id);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Product deleted successfully.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete product.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
                on UnauthorizedException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Unauthorized: ${e.message}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
