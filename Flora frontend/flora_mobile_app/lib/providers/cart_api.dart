import 'package:flora_mobile_app/models/cart_model.dart';
import 'package:flora_mobile_app/providers/base_provider.dart';

class CartApiService {
  static Future<CartModel> getCartByUser(int userId) async {
    try {
      final cartData = await BaseApiService.get(
        '/cart?UserId=$userId',
        (data) => data,
      );
      
      if (cartData['items'] == null || cartData['items'].isEmpty) {
        throw ApiException('Cart not found for user $userId');
      }
      
      final cartInfo = cartData['items'][0];
      
      List<CartItemModel> items = [];
      try {
        final itemsData = await BaseApiService.get(
          '/cartItem?CartId=${cartInfo['id']}',
          (data) => data,
        );
        
        if (itemsData['items'] != null) {
          items = (itemsData['items'] as List)
              .map((item) => CartItemModel.fromJson(item))
              .toList();
        }
      } catch (e) {
        print('No items found for cart ${cartInfo['id']}: $e');
      }
      
      return CartModel(
        id: cartInfo['id'],
        userId: cartInfo['userId'],
        createdAt: DateTime.parse(cartInfo['createdAt']),
        totalAmount: cartInfo['totalAmount']?.toDouble() ?? 0.0,
        items: items,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error fetching cart: $e');
    }
  }

  static Future<CartItemModel?> increaseQuantity(int itemId) async {
    try {
      return await BaseApiService.postEmpty(
        '/cartItem/$itemId/increase',
        (data) => data != null ? CartItemModel.fromJson(data) : null,
      );
    } catch (e) {
      print('Error in increaseQuantity: $e');
      return null;
    }
  }

  static Future<dynamic> decreaseQuantity(int itemId) async {
    try {
      return await BaseApiService.postEmpty(
        '/cartItem/$itemId/decrease',
        (data) {
          if (data == null) return null;
          
          if (data['removed'] == true) {
            return {'removed': true};
          }
          return CartItemModel.fromJson(data);
        },
      );
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
      return await BaseApiService.put(
        '/cartItem/$itemId',
        {'quantity': quantity},
        (data) => data != null ? CartItemModel.fromJson(data) : null,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error updating cart item: $e');
    }
  }

  static Future<bool> removeCartItem(int itemId) async {
    try {
      return await BaseApiService.delete('/cartItem/$itemId');
    } catch (e) {
      throw ApiException('Error removing cart item: $e');
    }
  }

  static Future<int?> getCartIdByUser(int userId) async {
    try {
      return await BaseApiService.get(
        '/cart?UserId=$userId',
        (data) {
          if (data['items'] != null && data['items'].isNotEmpty) {
            return data['items'][0]['id'] as int?;
          }
          return null;
        },
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error getting cartId: $e');
    }
  }
static Future<bool> addToCart({
  required int cartId,
  int? productId,
  int? customBouquetId,
  required int quantity,
  String cardMessage = '',
  String specialInstructions = '',
}) async {
  try {
    final body = {
      'cartId': cartId,
      'quantity': quantity,
      'cardMessage': cardMessage,
      'specialInstructions': specialInstructions,
    };

    if (productId != null) {
      body['productId'] = productId;
    } else if (customBouquetId != null) {
      body['customBouquetId'] = customBouquetId;
    } else {
      throw ApiException('Either productId or customBouquetId must be provided');
    }

    await BaseApiService.post('/cartItem', body, (data) => data);
    return true;
  } catch (e) {
    if (e is ApiException) {
      print('API Error adding to cart: $e');
      return false;
    }
    throw ApiException('Error adding to cart: $e');
  }
}
  static Future<CartModel> getCartByUserWithParams(int userId) async {
    return await BaseApiService.getWithParams(
      '/cart',
      {'UserId': userId},
      (data) {
        if (data['items'] == null || data['items'].isEmpty) {
          throw ApiException('Cart not found for user $userId');
        }
        
        final cartInfo = data['items'][0];
        return CartModel.fromJson(cartInfo);
      },
    );
  }

  static Future<List<CartItemModel>> bulkUpdateItems(
    List<Map<String, dynamic>> updates
  ) async {
    try {
      return await BaseApiService.put(
        '/cartItem/bulk-update',
        {'updates': updates},
        (data) {
          if (data['items'] != null) {
            return (data['items'] as List)
                .map((item) => CartItemModel.fromJson(item))
                .toList();
          }
          return <CartItemModel>[];
        },
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error bulk updating cart items: $e');
    }
  }

  
}