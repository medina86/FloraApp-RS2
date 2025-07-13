import 'package:flora_mobile_app/layouts/main_layout.dart';
import 'package:flora_mobile_app/providers/favorites_api.dart';
import 'package:flutter/material.dart';
import 'package:flora_mobile_app/models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final int userId;

  const ProductDetailScreen({
    Key? key,
    required this.product,
    required this.userId,
  }) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _showCardMessage = false;
  bool _showSpecialInstructions = false;
  bool _isFavorite = false;
  bool _isLoadingFavorite = false;
  
  final TextEditingController _cardMessageController = TextEditingController();
  final TextEditingController _specialInstructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  // Check if product is already in favorites
  Future<void> _checkIfFavorite() async {
    try {
      final favoriteIds = await FavoriteApiService.getFavoriteProductIds(widget.userId);
      setState(() {
        _isFavorite = favoriteIds.contains(widget.product.id);
      });
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  // Toggle favorite status
  Future<void> _toggleFavorite() async {
    if (_isLoadingFavorite) return;

    setState(() {
      _isLoadingFavorite = true;
    });

    try {
      bool success;
      if (_isFavorite) {
        // Remove from favorites
        success = await FavoriteApiService.removeFromFavoritesByFavoriteId(
          widget.userId, 
        );
        if (success) {
          setState(() {
            _isFavorite = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.product.name} removed from favorites'),
              backgroundColor: const Color(0xFFE91E63),
            ),
          );
        }
      } else {
        // Add to favorites
        success = await FavoriteApiService.addToFavorites(
          widget.userId, 
          widget.product.id
        );
        if (success) {
          setState(() {
            _isFavorite = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.product.name} added to favorites'),
              backgroundColor: const Color(0xFFE91E63),
            ),
          );
        }
      }

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${_isFavorite ? 'remove from' : 'add to'} favorites'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingFavorite = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = (widget.product.imageUrls.isNotEmpty)
        ? widget.product.imageUrls.first
        : 'https://via.placeholder.com/400';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Container(
                      height: 300,
                      width: double.infinity,
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Product Info Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE91E63),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Product Description
                          Text(
                            widget.product.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 15),
                          // Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${widget.product.price.toStringAsFixed(2)} KM',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE91E63),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Add card message section
                    _buildExpandableSection(
                      'Add card message',
                      _showCardMessage,
                      () => setState(() => _showCardMessage = !_showCardMessage),
                      _showCardMessage
                          ? TextField(
                              controller: _cardMessageController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Enter your message here...',
                                border: OutlineInputBorder(),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _buildExpandableSection(
                      'Special instructions',
                      _showSpecialInstructions,
                      () => setState(() => _showSpecialInstructions = !_showSpecialInstructions),
                      _showSpecialInstructions
                          ? TextField(
                              controller: _specialInstructionsController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Any special requests...',
                                border: OutlineInputBorder(),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 30),
                    // Add to Cart Button
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          _addToCart();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'ADD TO CART',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
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
          // Back Button
          GestureDetector(
            onTap: () {
              MainLayout.of(context)?.goBackToProductsList();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFFE91E63),
                size: 20,
              ),
            ),
          ),
          // Flora Title
          const Text(
            'Flora',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
              fontStyle: FontStyle.italic,
            ),
          ),
          // Favorite Heart Button
          GestureDetector(
            onTap: _toggleFavorite,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isLoadingFavorite
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFE91E63),
                      ),
                    )
                  : Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: const Color(0xFFE91E63),
                      size: 24,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(String title, bool isExpanded, VoidCallback onTap, Widget? content) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE91E63),
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: const Color(0xFFE91E63),
            ),
            onTap: onTap,
          ),
          if (isExpanded && content != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: content,
            ),
        ],
      ),
    );
  }

  void _addToCart() {
    // Implement add to cart functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart!'),
        backgroundColor: const Color(0xFFE91E63),
      ),
    );
  }

  @override
  void dispose() {
    _cardMessageController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }
}
