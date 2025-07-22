import 'package:flora_mobile_app/providers/cart_api.dart';
import 'package:flora_mobile_app/providers/favorites_api.dart';
import 'package:flora_mobile_app/providers/auth_provider.dart'; 
import 'package:flutter/material.dart';
import 'package:flora_mobile_app/models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final int userId;
  final VoidCallback? onBack;      
  final VoidCallback? onOpenCart;   

  const ProductDetailScreen({
    Key? key,
    required this.product,
    required this.userId,
    this.onBack,                    
    this.onOpenCart,               
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
    _checkAuthAndInitialize();
  }
  void _checkAuthAndInitialize() {
    if (!AuthProvider.isAuthenticated) {
      _showAuthError();
      return;
    }
    _checkIfFavorite();
  }

  void _showAuthError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Authentication required. Please login again.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _checkIfFavorite() async {
    if (!AuthProvider.isAuthenticated) {
      _showAuthError();
      return;
    }

    try {
      final favoriteIds = await FavoriteApiService.getFavoriteProductIds(widget.userId);
      setState(() {
        _isFavorite = favoriteIds.contains(widget.product.id);
      });
    } catch (e) {
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        AuthProvider.logout();
        _showAuthError();
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoadingFavorite) return;

    if (!AuthProvider.isAuthenticated) {
      _showAuthError();
      return;
    }

    setState(() {
      _isLoadingFavorite = true;
    });

    try {
      bool success;
      if (_isFavorite) {
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
      print('Error toggling favorite: $e');
    
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        AuthProvider.logout();
        _showAuthError();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingFavorite = false;
      });
    }
  }

  void _addToCart() async {
    if (!AuthProvider.isAuthenticated) {
      _showAuthError();
      return;
    }

    try {
      final cartId = await CartApiService.getCartIdByUser(widget.userId);

      if (cartId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No cart found for user'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await CartApiService.addToCart(
        cartId: cartId,
        productId: widget.product.id,
        quantity: 1,
        cardMessage: _cardMessageController.text.trim(),
        specialInstructions: _specialInstructionsController.text.trim(),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.product.name} added to cart!'),
            backgroundColor: const Color(0xFFE91E63),
          ),
        );
        _cardMessageController.clear();
        _specialInstructionsController.clear();
        setState(() {
          _showCardMessage = false;
          _showSpecialInstructions = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add to cart'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error adding to cart: $e');
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        AuthProvider.logout();
        _showAuthError();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding to cart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: AuthProvider.isAuthenticated ? _addToCart : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AuthProvider.isAuthenticated 
                              ? const Color(0xFFE91E63) 
                              : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          AuthProvider.isAuthenticated ? 'ADD TO CART' : 'LOGIN REQUIRED',
                          style: const TextStyle(
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
          GestureDetector(
            onTap: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                Navigator.pop(context);
              }
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
          GestureDetector(
            onTap: AuthProvider.isAuthenticated ? _toggleFavorite : null,
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
                      color: AuthProvider.isAuthenticated 
                          ? const Color(0xFFE91E63) 
                          : Colors.grey,
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

  @override
  void dispose() {
    _cardMessageController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }
}