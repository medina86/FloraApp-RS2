import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/models/cart_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartApiService {
  static Future<CartModel> getCartByUser(int userId) async {
    try {
      final cartResponse = await http.get(
        Uri.parse('$baseUrl/cart?UserId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (cartResponse.statusCode != 200) {
        throw Exception('Failed to load cart');
      }
      
      final cartData = json.decode(cartResponse.body);
      final cartInfo = cartData['items'][0];
      
      final itemsResponse = await http.get(
        Uri.parse('$baseUrl/cartItem?CartId=${cartInfo['id']}'),
        headers: {'Content-Type': 'application/json'},
      );
      
      List<CartItemModel> items = [];
      if (itemsResponse.statusCode == 200) {
        final itemsData = json.decode(itemsResponse.body);
        items = (itemsData['items'] as List)
            .map((item) => CartItemModel.fromJson(item))
            .toList();
      }
      
      return CartModel(
        id: cartInfo['id'],
        userId: cartInfo['userId'],
        createdAt: DateTime.parse(cartInfo['createdAt']),
        totalAmount: cartInfo['totalAmount']?.toDouble() ?? 0.0,
        items: items,
      );
    } catch (e) {
      throw Exception('Error fetching cart: $e');
    }
  }

  static Future<CartItemModel?> increaseQuantity(int itemId) async {
    try {
      print('Calling increase API for item $itemId');
      
      final response = await http.post(
        Uri.parse('$baseUrl/cartItem/$itemId/increase'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Increase API response: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CartItemModel.fromJson(data);
      }
      
      return null;
    } catch (e) {
      print('Error in increaseQuantity: $e');
      return null;
    }
  }

  static Future<dynamic> decreaseQuantity(int itemId) async {
    try {
      print('Calling decrease API for item $itemId');
      
      final response = await http.post(
        Uri.parse('$baseUrl/cartItem/$itemId/decrease'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Decrease API response: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['removed'] == true) {
          return {'removed': true};
        }
        return CartItemModel.fromJson(data);
      }
      
      return null;
    } catch (e) {
      print('Error in decreaseQuantity: $e');
      return null;
    }
  }

  static Future<CartItemModel?> updateCartItem({
    required int itemId,
    required int quantity,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/cartItem/$itemId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'quantity': quantity}),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CartItemModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Error updating cart item: $e');
    }
  }

  static Future<bool> removeCartItem(int itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cartItem/$itemId'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error removing cart item: $e');
    }
  }

  static Future<int?> getCartIdByUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cart?UserId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['items'] != null && jsonData['items'].isNotEmpty) {
          return jsonData['items'][0]['id'];
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error getting cartId: $e');
    }
  }

  static Future<bool> addToCart({
    required int cartId,
    required int productId,
    required int quantity,
    String cardMessage = '',
    String specialInstructions = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cartItem'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'cartId': cartId,
          'productId': productId,
          'quantity': quantity,
          'cardMessage': cardMessage,
          'specialInstructions': specialInstructions,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error adding to cart: $e');
    }
  }
}
