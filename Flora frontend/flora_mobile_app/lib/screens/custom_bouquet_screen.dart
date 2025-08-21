import 'package:flora_mobile_app/models/custom_bouquet_model.dart';
import 'package:flora_mobile_app/providers/custom_bouquet_provider.dart';
import 'package:flora_mobile_app/widgets/flower_quantity.dart';
import 'package:flutter/material.dart';
import 'package:flora_mobile_app/layouts/main_layout.dart';
import 'package:flora_mobile_app/models/product_model.dart';

class CreateCustomBouquetScreen extends StatefulWidget {
  final int userId;
  const CreateCustomBouquetScreen({super.key, required this.userId});

  @override
  State<CreateCustomBouquetScreen> createState() =>
      _CreateCustomBouquetScreenState();
}

class _CreateCustomBouquetScreenState extends State<CreateCustomBouquetScreen> {
  String _selectedColor = 'Pink';
  final List<String> _colors = [
    'Pink',
    'Purple',
    'Yellow',
    'Red',
    'DarkPurple',
    'LightPink',
    'Teal',
    'White',
    'Mint',
    'Grey',
    'LightBlue',
    'Cream',
  ];
  final Map<String, Color> _colorMap = {
    'Pink': const Color.fromARGB(255, 255, 170, 187),
    'Purple': const Color.fromARGB(255, 180, 100, 200),
    'Yellow': const Color.fromARGB(255, 255, 230, 150),
    'Red': const Color.fromARGB(255, 255, 80, 80),
    'DarkPurple': const Color.fromARGB(255, 80, 0, 80),
    'LightPink': const Color.fromARGB(255, 255, 220, 230),
    'Teal': const Color.fromARGB(255, 0, 150, 150),
    'White': Colors.white,
    'Mint': const Color.fromARGB(255, 150, 255, 200),
    'Grey': const Color.fromARGB(255, 150, 160, 170),
    'LightBlue': const Color.fromARGB(255, 150, 220, 255),
    'Cream': const Color.fromARGB(255, 255, 255, 220),
  };

  List<Product> _availableFlowers = [];
  Map<int, int> _flowerQuantities = {}; // productId -> quantity
  bool _isLoadingFlowers = true;
  bool _isCreatingBouquet = false;

  final TextEditingController _cardMessageController = TextEditingController();
  final TextEditingController _specialInstructionsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAvailableFlowers();
  }

  @override
  void dispose() {
    _cardMessageController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableFlowers() async {
    setState(() {
      _isLoadingFlowers = true;
    });
    try {
      final flowers = await CustomBouquetApiService.getAvailableFlowers();
      setState(() {
        _availableFlowers = flowers;
        for (var flower in flowers) {
          _flowerQuantities[flower.id] = 0;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to load flowers. Please check your connection and try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingFlowers = false;
      });
    }
  }

  void _updateFlowerQuantity(int productId, int newQuantity) {
    setState(() {
      _flowerQuantities[productId] = newQuantity.clamp(0, 99);
    });
  }

  double _calculateTotalPrice() {
    double total = 0.0;
    _flowerQuantities.forEach((productId, quantity) {
      final flower = _availableFlowers.firstWhere((f) => f.id == productId);
      total += flower.price * quantity;
    });
    return total;
  }

  Future<void> _createBouquet() async {
    final selectedItems = _flowerQuantities.entries
        .where((entry) => entry.value > 0)
        .map((entry) {
          final product = _availableFlowers.firstWhere(
            (f) => f.id == entry.key,
          );
          return CustomBouquetItemModel(
            productId: product.id,
            productName: product.name,
            quantity: entry.value,
          );
        })
        .toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose at least one flower.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCreatingBouquet = true;
    });

    try {
      print('🔸 Step 1: Creating custom bouquet...');
      final createdBouquet = await CustomBouquetApiService.createCustomBouquet(
        color: _selectedColor,
        cardMessage: _cardMessageController.text.trim().isEmpty
            ? null
            : _cardMessageController.text.trim(),
        specialInstructions: _specialInstructionsController.text.trim().isEmpty
            ? null
            : _specialInstructionsController.text.trim(),
        totalPrice: _calculateTotalPrice(),
        userId: widget.userId,
        items: selectedItems,
      );

      print(
        '✅ Step 1 Complete: Custom bouquet created with ID: ${createdBouquet.id}',
      );

      print('🔸 Step 2: Getting cart ID for user ${widget.userId}...');
      final cartId = await CustomBouquetApiService.getCartIdByUser(
        widget.userId,
      );

      if (cartId == null) {
        throw Exception('No cart found for user ${widget.userId}');
      }

      print('✅ Step 2 Complete: Cart ID found: $cartId');

      print('🔸 Step 3: Adding custom bouquet to cart...');
      final addedToCart = await CustomBouquetApiService.addCustomBouquetToCart(
        cartId: cartId,
        customBouquetId: createdBouquet.id!,
        quantity: 1,
        cardMessage: _cardMessageController.text.trim().isEmpty
            ? null
            : _cardMessageController.text.trim(),
        specialInstructions: _specialInstructionsController.text.trim().isEmpty
            ? null
            : _specialInstructionsController.text.trim(),
      );

      if (!addedToCart) {
        throw Exception('Failed to add custom bouquet to cart');
      }

      print('✅ Step 3 Complete: Custom bouquet added to cart successfully!');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bouquet #${createdBouquet.id} created and added to cart successfully!',
          ),
          backgroundColor: Color.fromARGB(255, 170, 46, 92),
          duration: Duration(seconds: 3),
        ),
      );

      // Reset form
      setState(() {
        _selectedColor = 'Pink';
        _flowerQuantities = {
          for (var flower in _availableFlowers) flower.id: 0,
        };
        _cardMessageController.clear();
        _specialInstructionsController.clear();
      });
    } catch (e) {
      print('🔴 Error in _createBouquet: $e');

      String errorMessage;
      if (e.toString().contains('404')) {
        errorMessage =
            'API endpoint not found. Please check if CustomBouquet API is available.';
      } else if (e.toString().contains('No cart found')) {
        errorMessage =
            'No cart found for your account. Please check your account settings.';
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isCreatingBouquet = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        centerTitle: true,
        title: Text(
          "Flora",
          style: const TextStyle(
            color: Color.fromARGB(255, 232, 30, 123),
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 170, 46, 92),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(
          context,
        ).copyWith(canvasColor: Color.fromARGB(255, 170, 46, 92)),
        child: BottomNavigationBar(
          selectedItemColor: const Color.fromARGB(255, 255, 210, 233),
          unselectedItemColor: Colors.white,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          onTap: (index) {
            Navigator.pop(context);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: "Shop"),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Favorites",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: "Cart",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
          ],
        ),
      ),
      body: _isLoadingFlowers
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 170, 46, 92),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add title at the top
                  const Text(
                    'Create custom bouquet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 170, 46, 92),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Choose color of bouquet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: _colors.length,
                    itemBuilder: (context, index) {
                      final colorName = _colors[index];
                      final color = _colorMap[colorName] ?? Colors.grey;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = colorName;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _selectedColor == colorName
                                  ? const Color.fromARGB(255, 170, 46, 92)
                                  : Colors.transparent,
                              width: _selectedColor == colorName ? 3.0 : 0.0,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Choose flowers:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _availableFlowers.length,
                    itemBuilder: (context, index) {
                      final flower = _availableFlowers[index];
                      final quantity = _flowerQuantities[flower.id] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  flower.imageUrls.isNotEmpty
                                      ? flower.imageUrls[0]
                                      : 'https://via.placeholder.com/80x80/FFB6C1/FFFFFF?text=No+Image',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    flower.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${flower.price.toStringAsFixed(2)} KM',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 170, 46, 92),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FlowerQuantityControl(
                              quantity: quantity,
                              onIncrease: () => _updateFlowerQuantity(
                                flower.id,
                                quantity + 1,
                              ),
                              onDecrease: () => _updateFlowerQuantity(
                                flower.id,
                                quantity - 1,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _cardMessageController,
                    decoration: InputDecoration(
                      labelText: 'Add card message',
                      border: const OutlineInputBorder(),
                      suffixIcon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                      ),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _specialInstructionsController,
                    decoration: InputDecoration(
                      labelText: 'Special instructions',
                      border: const OutlineInputBorder(),
                      suffixIcon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                      ),
                    ),
                    maxLines: null, // Omogućava više linija
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Cost: ${_calculateTotalPrice().toStringAsFixed(2)} KM',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isCreatingBouquet ? null : _createBouquet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 170, 46, 92),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isCreatingBouquet
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Create Bouquet',
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
    );
  }
}
