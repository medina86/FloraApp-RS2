import 'dart:convert';
import 'package:flora_mobile_app/providers/auth_provider.dart';
import 'package:flora_mobile_app/screens/selected_category_products_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/models/custom_bouquet_model.dart';
import 'package:flora_mobile_app/models/product_model.dart';

class CustomBouquetApiService {
  
  static Future<CustomBouquetModel> createCustomBouquet({
    required String color,
    String? cardMessage,
    String? specialInstructions,
    required double totalPrice,
    required int userId,
    required List<CustomBouquetItemModel> items,
  }) async {
    try {
      final requestBody = json.encode({
        'color': color,
        'cardMessage': cardMessage,
        'specialInstructions': specialInstructions,
        'totalPrice': totalPrice,
        'userId': userId,
        'customBouquetItems': items.map((item) => item.toJson()).toList(),
      });

      final url = Uri.parse('$baseUrl/CustomBouquet');
      print('Custom Bouquet API Request URL: $url');
      print('Custom Bouquet API Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: AuthProvider.getHeaders(),
        body: requestBody,
      );

      print('Custom Bouquet API Response Status Code: ${response.statusCode}');
      print('Custom Bouquet API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return CustomBouquetModel.fromJson(data);
      } else {
        throw Exception('Failed to create custom bouquet: ${response.body}');
      }
    } catch (e) {
      print('Error in CustomBouquetApiService.createCustomBouquet: $e');
      throw Exception('Error creating custom bouquet: $e');
    }
  }

  static Future<List<Product>> getAvailableFlowers() async {
    try {
      final url = Uri.parse('$baseUrl/Product?categoryName=Flower');
      print('Fetching available flowers from: $url');

      final response = await http.get(url, headers: AuthProvider.getHeaders());

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        return items.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load available flowers: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching available flowers: $e');
    }
  }

  static Future<int?> getCartIdByUser(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/Cart?UserId=$userId');
      print('Getting cart ID for user: $userId from $url');

      final response = await http.get(url, headers: AuthProvider.getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          return data['items'][0]['id'] as int?;
        }
        return null;
      } else {
        throw Exception('Failed to get cart ID: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting cart ID: $e');
      throw Exception('Error getting cart ID: $e');
    }
  }

  static Future<bool> addCustomBouquetToCart({
    required int cartId,
    required int customBouquetId,
    int quantity = 1,
    String? cardMessage,
    String? specialInstructions,
  }) async {
    try {
      final requestBody = json.encode({
        'cartId': cartId,
        'customBouquetId': customBouquetId,
        'quantity': quantity,
        'cardMessage': cardMessage ?? '',
        'specialInstructions': specialInstructions ?? '',
      });

      final url = Uri.parse('$baseUrl/CartItem');
      print('Adding custom bouquet to cart: $url');
      print('Request body: $requestBody');

      final response = await http.post(
        url,
        headers: AuthProvider.getHeaders(),
        body: requestBody,
      );

      print('Add to cart response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to add custom bouquet to cart: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding custom bouquet to cart: $e');
      return false;
    }
  }

  static Future<CustomBouquetModel?> createAndAddToCart({
    required String color,
    String? cardMessage,
    String? specialInstructions,
    required double totalPrice,
    required int userId,
    required List<CustomBouquetItemModel> items,
    int cartQuantity = 1,
  }) async {
    try {
      // 1. Kreiraj custom bouquet
      print('Step 1: Creating custom bouquet...');
      final customBouquet = await createCustomBouquet(
        color: color,
        cardMessage: cardMessage,
        specialInstructions: specialInstructions,
        totalPrice: totalPrice,
        userId: userId,
        items: items,
      );

      print('Step 2: Custom bouquet created with ID: ${customBouquet.id}');

      print('Step 3: Getting cart ID for user: $userId');
      final cartId = await getCartIdByUser(userId);

      if (cartId == null) {
        print('Error: No cart found for user $userId');
        throw Exception('No cart found for user $userId');
      }

      print('Step 4: Found cart ID: $cartId');

      print('Step 5: Adding custom bouquet to cart...');
      final addedToCart = await addCustomBouquetToCart(
        cartId: cartId,
        customBouquetId: customBouquet.id!,
        quantity: cartQuantity,
        cardMessage: cardMessage,
        specialInstructions: specialInstructions,
      );

      if (addedToCart) {
        print('Success: Custom bouquet added to cart!');
        return customBouquet;
      } else {
        print('Error: Failed to add custom bouquet to cart');
        throw Exception('Failed to add custom bouquet to cart');
      }
    } catch (e) {
      print('Error in createAndAddToCart: $e');
      rethrow;
    }
  }
}