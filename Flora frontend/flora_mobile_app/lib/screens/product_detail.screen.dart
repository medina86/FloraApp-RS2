import 'package:flora_mobile_app/models/custom_bouquet_model.dart';
import 'package:flora_mobile_app/providers/cart_api.dart';
import 'package:flora_mobile_app/providers/custom_bouquet_provider.dart';
import 'package:flora_mobile_app/providers/favorites_api.dart';
import 'package:flora_mobile_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flora_mobile_app/models/product_model.dart';

class CustomBouquetModel {
  final int id;
  final String color;
  final String? cardMessage;
  final String? specialInstructions;
  final double totalPrice;
  final List<CustomBouquetItemModel> items;

  CustomBouquetModel({
    required this.id,
    required this.color,
    this.cardMessage,
    this.specialInstructions,
    required this.totalPrice,
    required this.items,
  });

  factory CustomBouquetModel.fromJson(Map<String, dynamic> json) {
    return CustomBouquetModel(
      id: json['id'] as int,
      color: json['color'] as String,
      cardMessage: json['cardMessage'] as String?,
      specialInstructions: json['specialInstructions'] as String?,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      items: (json['items'] as List)
          .map(
            (item) =>
                CustomBouquetItemModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': color,
      'cardMessage': cardMessage,
      'specialInstructions': specialInstructions,
      'totalPrice': totalPrice,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class ProductDetailScreen extends StatefulWidget {
  final Product? product;
  final CustomBouquetModel? customBouquet;
  final int userId;
  final VoidCallback? onBack;
  final VoidCallback? onOpenCart;

  const ProductDetailScreen({
    Key? key,
    this.product,
    this.customBouquet,
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
  bool get _isCustomBouquet => widget.customBouquet != null;

  final TextEditingController _cardMessageController = TextEditingController();
  final TextEditingController _specialInstructionsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAuthAndInitialize();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (_isCustomBouquet) {
      _cardMessageController.text = widget.customBouquet!.cardMessage ?? '';
      _specialInstructionsController.text =
          widget.customBouquet!.specialInstructions ?? '';

      _showCardMessage = widget.customBouquet!.cardMessage?.isNotEmpty ?? false;
      _showSpecialInstructions =
          widget.customBouquet!.specialInstructions?.isNotEmpty ?? false;
    }
  }

  void _checkAuthAndInitialize() {
    if (!AuthProvider.isAuthenticated) {
      _showAuthError();
      return;
    }
    if (!_isCustomBouquet) {
      _checkIfFavorite();
    }
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
    if (!AuthProvider.isAuthenticated || _isCustomBouquet) {
      return;
    }

    try {
      final favoriteIds = await FavoriteApiService.getFavoriteProductIds(
        widget.userId,
      );
      setState(() {
        _isFavorite = favoriteIds.contains(widget.product!.id);
      });
    } catch (e) {
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        AuthProvider.logout();
        _showAuthError();
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoadingFavorite || _isCustomBouquet) return;

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
        // Get the favorite ID for this product
        final favoriteIds = await FavoriteApiService.getFavoriteProductIds(
          widget.userId,
        );
        if (favoriteIds.contains(widget.product!.id)) {
          success = await FavoriteApiService.removeFromFavoritesByFavoriteId(
            widget.product!.id,
          );
        } else {
          success = false;
        }
        if (success) {
          setState(() {
            _isFavorite = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.product!.name} removed from favorites'),
              backgroundColor: const Color(0xFFE91E63),
            ),
          );
        }
      } else {
        success = await FavoriteApiService.addToFavorites(
          widget.userId,
          widget.product!.id,
        );
        if (success) {
          setState(() {
            _isFavorite = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.product!.name} added to favorites'),
              backgroundColor: const Color(0xFFE91E63),
            ),
          );
        }
      }

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${_isFavorite ? 'remove from' : 'add to'} favorites',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error toggling favorite: $e');

      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        AuthProvider.logout();
        _showAuthError();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add to favorites. Please try again.'),
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

      bool success;
      if (_isCustomBouquet) {
        success = await CustomBouquetApiService.addCustomBouquetToCart(
          cartId: cartId,
          customBouquetId: widget.customBouquet!.id,
          cardMessage: _cardMessageController.text.trim(),
          specialInstructions: _specialInstructionsController.text.trim(),
          price: widget.customBouquet!.totalPrice,
        );
      } else {
        success = await CartApiService.addToCart(
          cartId: cartId,
          productId: widget.product!.id,
          quantity: 1,
          cardMessage: _cardMessageController.text.trim(),
          specialInstructions: _specialInstructionsController.text.trim(),
        );
      }

      if (success) {
        final productName = _isCustomBouquet
            ? 'Custom Bouquet'
            : widget.product!.name;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$productName added to cart!'),
            backgroundColor: const Color(0xFFE91E63),
          ),
        );
        if (!_isCustomBouquet) {
          _cardMessageController.clear();
          _specialInstructionsController.clear();
          setState(() {
            _showCardMessage = false;
            _showSpecialInstructions = false;
          });
        }
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
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        AuthProvider.logout();
        _showAuthError();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add item to cart. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context), // <-- Add header with favorite icon
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isCustomBouquet)
                      _buildCustomBouquetImage()
                    else
                      _buildProductImage(),
                    _buildProductInfo(),
                    const SizedBox(height: 20),
                    if (_isCustomBouquet)
                      _buildCustomBouquetItems()
                    else ...[
                      _buildExpandableSection(
                        'Add card message',
                        _showCardMessage,
                        () => setState(
                          () => _showCardMessage = !_showCardMessage,
                        ),
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
                        () => setState(
                          () => _showSpecialInstructions =
                              !_showSpecialInstructions,
                        ),
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
                    ],
                    if (_isCustomBouquet) ...[
                      _buildCustomBouquetExpandableSection(
                        'Card message',
                        _showCardMessage,
                        () => setState(
                          () => _showCardMessage = !_showCardMessage,
                        ),
                        _cardMessageController.text.isNotEmpty
                            ? _buildReadOnlyText(_cardMessageController.text)
                            : const Text(
                                'No card message',
                                style: TextStyle(color: Colors.grey),
                              ),
                      ),
                      const SizedBox(height: 10),
                      _buildCustomBouquetExpandableSection(
                        'Special instructions',
                        _showSpecialInstructions,
                        () => setState(
                          () => _showSpecialInstructions =
                              !_showSpecialInstructions,
                        ),
                        _specialInstructionsController.text.isNotEmpty
                            ? _buildReadOnlyText(
                                _specialInstructionsController.text,
                              )
                            : const Text(
                                'No special instructions',
                                style: TextStyle(color: Colors.grey),
                              ),
                      ),
                    ],
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: AuthProvider.isAuthenticated
                            ? _addToCart
                            : null,
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
                          AuthProvider.isAuthenticated
                              ? 'ADD TO CART'
                              : 'LOGIN REQUIRED',
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

  Widget _buildProductImage() {
    final imageUrl = (widget.product!.imageUrls.isNotEmpty)
        ? widget.product!.imageUrls.first
        : 'https://via.placeholder.com/400';

    return Container(
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
    );
  }

  Widget _buildCustomBouquetImage() {
    return Container(
      height: 300,
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getColorFromString(widget.customBouquet!.color).withOpacity(0.3),
            _getColorFromString(widget.customBouquet!.color).withOpacity(0.6),
          ],
        ),
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
        child: Container(
          decoration: BoxDecoration(
            color: _getColorFromString(
              widget.customBouquet!.color,
            ).withOpacity(0.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_florist,
                size: 80,
                color: _getColorFromString(widget.customBouquet!.color),
              ),
              const SizedBox(height: 10),
              Text(
                'Custom Bouquet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getColorFromString(widget.customBouquet!.color),
                ),
              ),
              Text(
                widget.customBouquet!.color.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _getColorFromString(
                    widget.customBouquet!.color,
                  ).withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
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
            _isCustomBouquet ? 'Custom Bouquet' : widget.product!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(height: 10),
          if (_isCustomBouquet) ...[
            Text(
              'Color: ${widget.customBouquet!.color}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE91E63),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Contains ${widget.customBouquet!.items.length} different flowers',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ] else
            Text(
              widget.product!.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_isCustomBouquet ? widget.customBouquet!.totalPrice : widget.product!.price} KM',
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
    );
  }

  Widget _buildCustomBouquetItems() {
    return Container(
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
          const Text(
            'Bouquet Contents',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(height: 15),
          ...widget.customBouquet!.items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${item.quantity}x',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildReadOnlyText(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildCustomBouquetExpandableSection(
    String title,
    bool isExpanded,
    VoidCallback onTap,
    Widget content,
  ) {
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
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: content,
            ),
        ],
      ),
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'pink':
        return Colors.pink;
      case 'purple':
        return Colors.purple;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'white':
        return Colors.grey[600]!;
      case 'green':
        return Colors.green;
      default:
        return const Color(0xFFE91E63);
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: (!_isCustomBouquet && AuthProvider.isAuthenticated)
              ? _toggleFavorite
              : null,
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
            child: _isCustomBouquet
                ? Icon(
                    Icons.palette,
                    color: _getColorFromString(widget.customBouquet!.color),
                    size: 24,
                  )
                : (_isLoadingFavorite
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
                        )),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection(
    String title,
    bool isExpanded,
    VoidCallback onTap,
    Widget? content,
  ) {
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
