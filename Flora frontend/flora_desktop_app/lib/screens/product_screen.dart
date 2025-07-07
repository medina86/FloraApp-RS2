import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flora_desktop_app/layouts/constants.dart';

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], name: json['name'] ?? '');
  }
}

class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final List<String> imageUrls;
  final int? categoryId;
  final String? categoryName;
  final bool isNew;
  final bool isFeatured;
  final int? occasionId;
  final String? occasionName;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.imageUrls,
    this.categoryId,
    this.categoryName,
    required this.isNew,
    required this.isFeatured,
    this.occasionId,
    this.occasionName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      isNew: json['isNew'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      occasionId: json['occasionId'],
      occasionName: json['occasionName'],
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    List<String>? imageUrls,
    int? categoryId,
    String? categoryName,
    bool? isNew,
    bool? isFeatured,
    int? occasionId,
    String? occasionName,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isNew: isNew ?? this.isNew,
      isFeatured: isFeatured ?? this.isFeatured,
      occasionId: occasionId ?? this.occasionId,
      occasionName: occasionName ?? this.occasionName,
    );
  }
}

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
  bool showAddForm = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([fetchProducts(), fetchCategories()]);
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Category'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> jsonData;

        if (responseData is List) {
          jsonData = responseData;
        } else if (responseData is Map<String, dynamic>) {
          jsonData = responseData['items'] ?? responseData['data'] ?? [];
        } else {
          jsonData = [];
        }

        final List<Category> loadedCategories = jsonData
            .map((item) => Category.fromJson(item))
            .toList();

        setState(() {
          categories = loadedCategories;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Product'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> jsonData = responseData['items'] as List<dynamic>;

        final List<Product> loadedProducts = jsonData
            .map((item) => Product.fromJson(item))
            .toList();

        setState(() {
          products = loadedProducts;
          filteredProducts = loadedProducts;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
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

  Future<String?> uploadImage(File imageFile, int productId) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/Product/$productId/upload-images'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('files', imageFile.path),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final List<dynamic> urls = json.decode(responseData);
        return urls.isNotEmpty ? urls[0] as String : null;
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<void> createProduct(
    Map<String, dynamic> productData,
    File? imageFile,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Product'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(productData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        final int productId = responseBody['id'];

        if (imageFile != null) {
          await uploadImage(imageFile, productId);
        }

        await fetchProducts();
        setState(() {
          showAddForm = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to create product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/Product/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'categoryId': product.categoryId,
          'isNew': product.isNew,
          'isFeatured': product.isFeatured,
          'occasionId': product.occasionId,
        }),
      );

      if (response.statusCode == 200) {
        await fetchProducts();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'All') {
        filteredProducts = products;
      } else {
        filteredProducts = products
            .where((product) => product.categoryName == category)
            .toList();
      }
    });
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

  Color getAvatarColor(int index) {
    List<Color> colors = [
      Color(0xFF9C27B0),
      Color(0xFF673AB7),
      Color(0xFF3F51B5),
      Color(0xFF2196F3),
      Color(0xFF009688),
      Color(0xFF4CAF50),
      Color(0xFFFF9800),
      Color(0xFFE91E63),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (showAddForm) {
      return _buildAddForm();
    }

    final categoryNames = ['All', ...categories.map((c) => c.name)];

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
              Row(
                children: [
                  // Category Filter
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
                  // Add New Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      setState(() {
                        showAddForm = true;
                      });
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
            ],
          ),

          SizedBox(height: 30),

          // Table
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
                  // Table Header
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
                            'Category',
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

                  // Table Content
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
                        : ListView.separated(
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
                                    // Product
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: getAvatarColor(
                                              index,
                                            ),
                                            child: Text(
                                              getInitials(product.name),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
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
                                    // Category
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          Text(
                                            product.categoryName ?? 'Unknown',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          if (product.isNew)
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(8),
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
                                          if (product.isFeatured)
                                            Container(
                                              margin: EdgeInsets.only(left: 4),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(8),
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
                                      ),
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
                                            onPressed: () =>
                                                _showEditDialog(product),
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
          ),
        ],
      ),
    );
  }

  Widget _buildAddForm() {
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _priceController = TextEditingController();

    int? selectedCategoryId;
    bool isNew = false;
    bool isFeatured = false;
    File? selectedImage;
    bool isUploadingImage = false;

    return StatefulBuilder(
      builder: (context, setFormState) {
        return Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        showAddForm = false;
                      });
                    },
                    icon: Icon(Icons.arrow_back, color: Color(0xFFE91E63)),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE91E63),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Form
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product category
                              Text(
                                'Product category',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFE91E63),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButton<int>(
                                  value: selectedCategoryId,
                                  hint: Text(
                                    'Category',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  underline: SizedBox(),
                                  isExpanded: true,
                                  items: categories.map((category) {
                                    return DropdownMenuItem<int>(
                                      value: category.id,
                                      child: Text(category.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setFormState(() {
                                      selectedCategoryId = value;
                                    });
                                  },
                                ),
                              ),

                              SizedBox(height: 24),

                              // Product name
                              Text(
                                'Product name',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFE91E63),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Color(0xFFE91E63),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 24),

                              // Price
                              Text(
                                'Price (KM)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFE91E63),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: _priceController,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Color(0xFFE91E63),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 40),

                        // Right Column
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Description
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFE91E63),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: _descriptionController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Color(0xFFE91E63),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 24),

                              // Status checkboxes
                              Text(
                                'Status:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFE91E63),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Checkbox(
                                    value: isNew,
                                    onChanged: (value) {
                                      setFormState(() {
                                        isNew = value ?? false;
                                      });
                                    },
                                    activeColor: Color(0xFFE91E63),
                                  ),
                                  Text('New Product'),
                                  SizedBox(width: 20),
                                  Checkbox(
                                    value: isFeatured,
                                    onChanged: (value) {
                                      setFormState(() {
                                        isFeatured = value ?? false;
                                      });
                                    },
                                    activeColor: Color(0xFFE91E63),
                                  ),
                                  Text('Featured'),
                                ],
                              ),

                              SizedBox(height: 24),

                              Text(
                                'Product image',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFE91E63),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    maxWidth: 1024,
                                    maxHeight: 1024,
                                    imageQuality: 85,
                                  );

                                  if (image != null) {
                                    setFormState(() {
                                      selectedImage = File(image.path);
                                    });
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selectedImage != null
                                          ? Color(0xFFE91E63)
                                          : Colors.grey.shade300,
                                      width: selectedImage != null ? 2 : 1,
                                    ),
                                  ),
                                  child: selectedImage != null
                                      ? Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: Image.file(
                                                selectedImage!,
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setFormState(() {
                                                    selectedImage = null;
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons
                                                  .add_photo_alternate_outlined,
                                              size: 40,
                                              color: Colors.grey.shade400,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Click to upload image',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'JPG, PNG up to 5MB',
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),

                              SizedBox(height: 30),

                              // ADD Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFE91E63),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: isUploadingImage
                                      ? null
                                      : () async {
                                          // Validation
                                          if (_nameController.text
                                              .trim()
                                              .isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Product name is required',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          if (_priceController.text
                                              .trim()
                                              .isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Price is required',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          if (selectedCategoryId == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Category is required',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          final price = double.tryParse(
                                            _priceController.text,
                                          );
                                          if (price == null || price < 0) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Please enter a valid price',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          List<String> imageUrls = [];

                                          if (selectedImage != null) {
                                            setFormState(() {
                                              isUploadingImage = true;
                                            });

                                            setFormState(() {
                                              isUploadingImage = false;
                                            });
                                          }

                                          final productData = {
                                            'name': _nameController.text.trim(),
                                            'description':
                                                _descriptionController.text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : _descriptionController.text
                                                      .trim(),
                                            'price': price,
                                            'categoryId': selectedCategoryId,
                                            'isNew': isNew,
                                            'isFeatured': isFeatured,
                                            'imageUrls': imageUrls,
                                          };

                                          await createProduct(
                                            productData,
                                            selectedImage,
                                          );
                                        },
                                  child: isUploadingImage
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text('Uploading...'),
                                          ],
                                        )
                                      : Text(
                                          'ADD',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
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
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(Product product) {
    final _nameController = TextEditingController(text: product.name);
    final _descriptionController = TextEditingController(
      text: product.description ?? '',
    );
    final _priceController = TextEditingController(
      text: product.price.toString(),
    );

    int? selectedCategoryId = product.categoryId;
    bool isNew = product.isNew;
    bool isFeatured = product.isFeatured;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Edit Product'),
              content: Container(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Price (KM)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem<int>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedCategoryId = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: Text('New'),
                              value: isNew,
                              onChanged: (value) {
                                setDialogState(() {
                                  isNew = value ?? false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              title: Text('Featured'),
                              value: isFeatured,
                              onChanged: (value) {
                                setDialogState(() {
                                  isFeatured = value ?? false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final updatedProduct = product.copyWith(
                      name: _nameController.text,
                      description: _descriptionController.text.isEmpty
                          ? null
                          : _descriptionController.text,
                      price:
                          double.tryParse(_priceController.text) ??
                          product.price,
                      categoryId: selectedCategoryId,
                      categoryName: categories
                          .firstWhere(
                            (c) => c.id == selectedCategoryId,
                            orElse: () => Category(id: 0, name: 'Unknown'),
                          )
                          .name,
                      isNew: isNew,
                      isFeatured: isFeatured,
                    );

                    Navigator.of(context).pop();
                    await updateProduct(updatedProduct);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE91E63),
                  ),
                  child: Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
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
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Delete functionality - Coming soon!'),
                  ),
                );
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
