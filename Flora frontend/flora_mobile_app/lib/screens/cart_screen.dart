import 'package:flora_mobile_app/layouts/main_layout.dart';
import 'package:flora_mobile_app/layouts/cart_item_widget.dart';
import 'package:flora_mobile_app/layouts/custom_bouquet_cart_item_widget.dart';
import 'package:flora_mobile_app/models/product_model.dart';
import 'package:flora_mobile_app/screens/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flora_mobile_app/models/cart_model.dart';
import 'package:flora_mobile_app/providers/cart_api.dart';

class CartScreen extends StatefulWidget {
  final int userId;
  const CartScreen({super.key, required this.userId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  CartModel? _cart;
  bool _isLoading = true;
  Set<int> _updatingItems = {};

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final cart = await CartApiService.getCartByUser(widget.userId);
      
      print('Učitana korpa: ID=${cart.id}, ukupno stavki: ${cart.items.length}');
      
      for (var i = 0; i < cart.items.length; i++) {
        final item = cart.items[i];
        print('Stavka $i: ID=${item.id}, ProductID=${item.productId}, CustomBouquetID=${item.customBouquetId}, Naziv=${item.productName}');
      }
      
      setState(() {
        _cart = cart;
        _isLoading = false;
      });
    } catch (e) {
      print('Greška pri učitavanju korpe: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double get totalAmount {
    return _cart?.calculateTotalAmount() ?? 0.0;
  }

  List<CartItemModel> get cartItems {
    return _cart?.items ?? [];
  }

  Future<void> _increaseQuantity(int itemId) async {
    if (_updatingItems.contains(itemId)) return;

    setState(() {
      _updatingItems.add(itemId);
    });

    try {
      final result = await CartApiService.increaseQuantity(itemId);

      if (result != null) {
        setState(() {
          final index = _cart!.items.indexWhere((item) => item.id == itemId);
          if (index != -1) {
            _cart!.items[index] = result;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quantity increased'),
            backgroundColor: Color.fromARGB(255, 170, 46, 92),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        throw Exception('Failed to increase quantity');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _updatingItems.remove(itemId);
      });
    }
  }

  Future<void> _decreaseQuantity(int itemId) async {
    if (_updatingItems.contains(itemId)) return;

    setState(() {
      _updatingItems.add(itemId);
    });

    try {
      final result = await CartApiService.decreaseQuantity(itemId);

      if (result != null) {
        if (result is Map && result['removed'] == true) {
          setState(() {
            _cart!.items.removeWhere((item) => item.id == itemId);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item removed from cart'),
              backgroundColor: Color.fromARGB(255, 170, 46, 92),
            ),
          );
        } else if (result is CartItemModel) {
          setState(() {
            final index = _cart!.items.indexWhere((item) => item.id == itemId);
            if (index != -1) {
              _cart!.items[index] = result;
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quantity decreased'),
              backgroundColor: Color.fromARGB(255, 170, 46, 92),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        throw Exception('Failed to decrease quantity');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _updatingItems.remove(itemId);
      });
    }
  }

  Future<void> _removeItem(int itemId) async {
    if (_updatingItems.contains(itemId)) return;

    setState(() {
      _updatingItems.add(itemId);
    });

    try {
      final success = await CartApiService.removeCartItem(itemId);

      if (success) {
        setState(() {
          _cart!.items.removeWhere((item) => item.id == itemId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item removed from cart'),
            backgroundColor: Color.fromARGB(255, 170, 46, 92),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove item'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _updatingItems.remove(itemId);
      });
    }
  }

  void _checkout() {
    if (_cart != null && _cart!.items.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              CheckoutScreen(cart: _cart!, userId: widget.userId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Removed duplicate AppBar - using GlobalAppHeader from MainLayout
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 170, 46, 92),
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cart',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 170, 46, 92),
                        ),
                      ),
                      if (_updatingItems.isNotEmpty)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color.fromARGB(255, 170, 46, 92),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: cartItems.isEmpty
                      ? const Center(
                          child: Text(
                            'Your cart is empty',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            
                            // Debug ispis za provjeru vrijednosti
                            print('Cart item $index: ID=${item.id}, ProductID=${item.productId}, CustomBouquetID=${item.customBouquetId}');
                            
                            // Koristimo poseban widget za custom bukete
                            // Identifikujemo custom buket na osnovu customBouquetId, imena proizvoda ili productId=0
                            bool isCustomBouquet = item.customBouquetId != null || 
                                                  (item.productName == 'Custom bouquet' && item.productId == 0);
                            
                            if (isCustomBouquet) {
                              print('Prikazujem CUSTOM BUKET za item $index - ProductName=${item.productName}, ProductID=${item.productId}');
                              
                              return CustomBouquetCartItemWidget(
                                item: item,
                                onIncrease: () => _increaseQuantity(item.id),
                                onDecrease: () => _decreaseQuantity(item.id),
                                onRemove: () => _removeItem(item.id),
                                isUpdating: _updatingItems.contains(item.id),
                                // Za custom buket ne dodajemo onTap funkciju jer je prikaz detalja u samom widgetu
                              );
                            }

                            // Standardni widget za obične proizvode
                            return CartItemWidget(
                              item: item,
                              onIncrease: () => _increaseQuantity(item.id),
                              onDecrease: () => _decreaseQuantity(item.id),
                              onRemove: () => _removeItem(item.id),
                              isUpdating: _updatingItems.contains(item.id),
                              onTap: () async {
                                try {
                                  final product = Product(
                                    id: item.productId,
                                    name: item.productName,
                                    description: '',
                                    price: item.price,
                                    imageUrls: item.imageUrl != null
                                        ? [item.imageUrl!]
                                        : [],
                                    isNew: false,
                                    isFeatured: false,
                                    active: true,
                                    isAvailable: true,
                                  );
                                  if (!mounted) return;
                                  MainLayout.of(
                                    context,
                                  )?.openProductScreen(product);
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to load product details: $e',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                ),
                if (cartItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '${totalAmount.toStringAsFixed(2)} KM',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 170, 46, 92),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updatingItems.isEmpty
                                ? _checkout
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                170,
                                46,
                                92,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _updatingItems.isNotEmpty
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Proceed to Checkout',
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
    );
  }
}
