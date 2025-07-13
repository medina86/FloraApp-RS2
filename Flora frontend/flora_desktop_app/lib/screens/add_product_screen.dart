import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flora_desktop_app/layouts/constants.dart';
import 'package:flora_desktop_app/providers/product_provider.dart';


class AddProductPage extends StatefulWidget {
  final List<Category> categories;
  const AddProductPage({Key? key, required this.categories}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  int? selectedCategoryId;
  int? selectedOccasionId; 
  bool isNew = false;
  bool isFeatured = false;
  bool active = true;
  bool isAvailable = true;
  List<File> selectedImages = [];
  bool isUploadingImages = false;
  

  List<Occasion> occasions = [];
  bool occasionsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOccasions(); 
  }
Future<void> _fetchOccasions() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/Occasion'));
    
    print('Response status: ${response.statusCode}'); 
    print('Response body: ${response.body}'); 
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      
      final List<dynamic> items = jsonResponse['items'] ?? [];
      
      setState(() {
        occasions = items.map((json) => Occasion.fromJson(json)).toList();
        occasionsLoading = false;
      });
      
      print('Loaded ${occasions.length} occasions'); 
    } else {
      setState(() {
        occasionsLoading = false;
      });
      print('Failed to load occasions: ${response.statusCode}');
    }
  } catch (e) {
    setState(() {
      occasionsLoading = false;
    });
    print('Error fetching occasions: $e');
  }
}
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (images.isNotEmpty) {
      setState(() {
        for (var image in images) {
          if (selectedImages.length < 5) {
            selectedImages.add(File(image.path));
          }
        }
      });
      if (images.length + selectedImages.length > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maximum 5 images allowed'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<List<String>> uploadImages(
    List<File> imageFiles,
    int productId,
  ) async {
    List<String> uploadedUrls = [];
    for (File imageFile in imageFiles) {
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
          if (urls.isNotEmpty) {
            uploadedUrls.add(urls[0] as String);
          }
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    return uploadedUrls;
  }

  Future<void> createProduct() async {
    try {
      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'categoryId': selectedCategoryId,
        'occasionId': selectedOccasionId, // DODANO - može biti null
        'isNew': isNew,
        'isFeatured': isFeatured,
        'active': active,
        'isAvailable': isAvailable,
        'imageUrls': <String>[],
      };

      final response = await http.post(
        Uri.parse('$baseUrl/Product'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(productData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        final int productId = responseBody['id'];

        if (selectedImages.isNotEmpty) {
          setState(() {
            isUploadingImages = true;
          });
          await uploadImages(selectedImages, productId);
          setState(() {
            isUploadingImages = false;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to create product: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isUploadingImages = false;
      });
      print('Error creating product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 8),
            Text(
              'Click to add images',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'JPG, PNG up to 5MB • Max 5 images',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount:
              selectedImages.length + (selectedImages.length < 5 ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == selectedImages.length) {
              return _buildAddMoreButton();
            }
            return _buildImageItem(selectedImages[index], index);
          },
        ),
        SizedBox(height: 8),
        Text(
          '${selectedImages.length}/5 images selected',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildAddMoreButton() {
    return GestureDetector(
      onTap: selectedImages.length < 5 ? _pickImages : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 24,
              color: selectedImages.length < 5
                  ? Color(0xFFE91E63)
                  : Colors.grey.shade400,
            ),
            SizedBox(height: 4),
            Text(
              'Add more',
              style: TextStyle(
                fontSize: 10,
                color: selectedImages.length < 5
                    ? Color(0xFFE91E63)
                    : Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(File imageFile, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: index == 0 ? Color(0xFFE91E63) : Colors.grey.shade300,
          width: index == 0 ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.file(
              imageFile,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          if (index == 0)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFFE91E63),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PRIMARY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedImages.removeAt(index);
                });
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.drag_handle, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back, color: Color(0xFFE91E63)),
                ),
                SizedBox(width: 16),
                Text(
                  'Add New Product',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE91E63),
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
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<int>(
                                value: selectedCategoryId,
                                hint: Text(
                                  'Select Category',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                underline: SizedBox(),
                                isExpanded: true,
                                items: widget.categories.map((category) {
                                  return DropdownMenuItem<int>(
                                    value: category.id,
                                    child: Text(category.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategoryId = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 24),

                            // DODANO - Occasion dropdown
                            Text(
                              'Occasion (Optional)',
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
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: occasionsLoading
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Color(0xFFE91E63),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text('Loading occasions...'),
                                        ],
                                      ),
                                    )
                                  : DropdownButton<int>(
                                      value: selectedOccasionId,
                                      hint: Text(
                                        'Select Occasion (Optional)',
                                        style: TextStyle(color: Colors.grey.shade600),
                                      ),
                                      underline: SizedBox(),
                                      isExpanded: true,
                                      items: [
                                        // "None" opcija
                                        DropdownMenuItem<int>(
                                          value: null,
                                          child: Text(
                                            'None',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                        // Occasions iz baze
                                        ...occasions.map((occasion) {
                                          return DropdownMenuItem<int>(
                                            value: occasion.occasionId,
                                            child: Text(occasion.name),
                                          );
                                        }).toList(),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          selectedOccasionId = value;
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
                      // Right Column - ostaje isto kao prije
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
                                Expanded(
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: isNew,
                                        onChanged: (value) {
                                          setState(() {
                                            isNew = value ?? false;
                                          });
                                        },
                                        activeColor: Color(0xFFE91E63),
                                      ),
                                      Expanded(child: Text('New Product')),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: isFeatured,
                                        onChanged: (value) {
                                          setState(() {
                                            isFeatured = value ?? false;
                                          });
                                        },
                                        activeColor: Color(0xFFE91E63),
                                      ),
                                      Expanded(child: Text('Featured')),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: active,
                                        onChanged: (value) {
                                          setState(() {
                                            active = value ?? true;
                                          });
                                        },
                                        activeColor: Color(0xFFE91E63),
                                      ),
                                      Expanded(child: Text('Active')),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: isAvailable,
                                        onChanged: (value) {
                                          setState(() {
                                            isAvailable = value ?? true;
                                          });
                                        },
                                        activeColor: Color(0xFFE91E63),
                                      ),
                                      Expanded(child: Text('Available')),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            // Product images
                            Text(
                              'Product images',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFE91E63),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              constraints: BoxConstraints(minHeight: 120),
                              child: selectedImages.isEmpty
                                  ? _buildAddImageButton()
                                  : _buildImageGrid(),
                            ),
                            SizedBox(height: 30),
                            // CREATE Button
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
                                onPressed: isUploadingImages
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

                                        await createProduct();
                                      },
                                child: isUploadingImages
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
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text('Creating...'),
                                        ],
                                      )
                                    : Text(
                                        'CREATE PRODUCT',
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
      ),
    );
  }
}