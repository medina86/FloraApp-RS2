import 'dart:convert';
import 'package:flora_mobile_app/models/favorite_product.dart';
import 'package:flora_mobile_app/providers/favorites_api.dart';
import 'package:flutter/material.dart';
import 'package:flora_mobile_app/layouts/main_layout.dart';

class FavouritesScreen extends StatefulWidget {
  final int userId;

  const FavouritesScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _FavouritesScreenState createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  late Future<List<FavoriteProduct>> _futureFavorites;
  final TextEditingController _searchController = TextEditingController();
  List<FavoriteProduct> _allFavorites = [];
  List<FavoriteProduct> _filteredFavorites = [];
  List<int> _selectedProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadFavorites() {
    setState(() {
      _futureFavorites = FavoriteApiService.getFavoritesByUser(widget.userId);
      _allFavorites = [];
      _filteredFavorites = [];
    });
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFavorites = List.from(_allFavorites);
      } else {
        _filteredFavorites = _allFavorites
            .where(
              (product) =>
                  product.productName?.toLowerCase().contains(query) ?? false,
            )
            .toList();
      }
    });
  }

  void _toggleProductSelection(int productId) {
    setState(() {
      if (_selectedProducts.contains(productId)) {
        _selectedProducts.remove(productId);
      } else {
        _selectedProducts.add(productId);
      }
    });
  }

  void _addSelectedToCart() {
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select products to add to cart'),
          backgroundColor: Color(0xFFE91E63),
        ),
      );
      return;
    }

    final selectedProductNames = _filteredFavorites
        .where((product) => _selectedProducts.contains(product.productId))
        .map((product) => product.productName ?? 'Unknown')
        .join(', ');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to cart: $selectedProductNames'),
        backgroundColor: const Color(0xFFE91E63),
      ),
    );

    setState(() {
      _selectedProducts.clear();
    });
  }

  Future<void> _removeFromFavorites(FavoriteProduct product) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await FavoriteApiService.removeFromFavoritesByFavoriteId(
        product.favoriteId,
      );

      if (success) {
        setState(() {
          _allFavorites.removeWhere((p) => p.productId == product.productId);
          _filteredFavorites.removeWhere(
            (p) => p.productId == product.productId,
          );
          _selectedProducts.remove(product.productId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.productName} removed from favorites'),
            backgroundColor: const Color(0xFFE91E63),
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () async {
                final addSuccess = await FavoriteApiService.addToFavorites(
                  widget.userId,
                  product.productId,
                );
                if (addSuccess) {
                  _loadFavorites();
                }
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove from favorites'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to remove item from favorites. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Removed duplicate header - using GlobalAppHeader from MainLayout
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Favourites',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
              ),
            ),
            _buildSearchBar(),
            Expanded(
              child: FutureBuilder<List<FavoriteProduct>>(
                future: _futureFavorites,
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
                            'Error loading favorites',
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
                            onPressed: _loadFavorites,
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  } else {
                    if (_allFavorites.isEmpty) {
                      _allFavorites = snapshot.data!;
                      _filteredFavorites = List.from(_allFavorites);
                    }

                    return _filteredFavorites.isEmpty
                        ? _buildNoSearchResults()
                        : _buildFavoritesList();
                  }
                },
              ),
            ),
            if (_filteredFavorites.isNotEmpty) _buildAddToCartButton(),
          ],
        ),
      ),
    );
  }

  // Removed _buildHeader method as we're now using the GlobalAppHeader from MainLayout

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.pink[50],
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _filteredFavorites.length,
            itemBuilder: (context, index) {
              final product = _filteredFavorites[index];
              final isSelected = _selectedProducts.contains(product.productId);

              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: _buildFavoriteItem(product, isSelected),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteItem(FavoriteProduct product, bool isSelected) {
    final imageUrl = product.imageUrls.isNotEmpty
        ? product.imageUrls.first
        : 'https://via.placeholder.com/80x80/FFB6C1/FFFFFF?text=No+Image';

    return GestureDetector(
      onTap: () {
        // Convert FavoriteProduct to Product and navigate
        MainLayout.of(context)?.openProductScreen(product.toProduct());
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? Border.all(color: const Color(0xFFE91E63), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 15),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName ?? 'Unknown Product',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${product.price.toStringAsFixed(0)} KM',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFE91E63),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Selection Checkbox
            GestureDetector(
              onTap: () => _toggleProductSelection(product.productId),
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE91E63)
                      : Colors.transparent,
                  border: Border.all(color: const Color(0xFFE91E63), width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),
            // Heart Icon with loading state
            GestureDetector(
              onTap: _isLoading ? null : () => _removeFromFavorites(product),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFE91E63),
                      ),
                    )
                  : const Icon(
                      Icons.favorite,
                      color: Color(0xFFE91E63),
                      size: 24,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: _addSelectedToCart,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE91E63),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          _selectedProducts.isEmpty
              ? 'ADD TO CART'
              : 'ADD TO CART (${_selectedProducts.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No Favorites Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Start adding products to your favorites\nto see them here',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              MainLayout.of(context)?.goBackToHome();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Browse Products',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No Results Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Try searching with different keywords',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
