import 'package:flora_mobile_app/models/favorite_product.dart';
import 'package:flora_mobile_app/providers/base_provider.dart';

class FavoriteApiService {
  static Future<List<FavoriteProduct>> getFavoritesByUser(int userId) async {
    final params = {'UserId': userId};
    
    return BaseApiService.getWithParams('/favorite', params, (data) {
      final Map<String, dynamic> jsonResponse = data as Map<String, dynamic>;
      final List<dynamic> items = jsonResponse['items'] ?? [];

      return items.map((json) {
        try {
          return FavoriteProduct.fromJson(json);
        } catch (e) {
          rethrow;
        }
      }).toList();
    });
  }

  static Future<List<int>> getFavoriteProductIds(int userId) async {
    return BaseApiService.get('/favorite/details/user/$userId', (data) {
      final List<dynamic> ids = data as List<dynamic>;
      return ids.map((id) => id as int).toList();
    });
  }

  static Future<bool> addToFavorites(int userId, int productId) async {
    try {
      await BaseApiService.post('/favorite', {'userId': userId, 'productId': productId}, (data) => data);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> removeFromFavoritesByFavoriteId(int favoriteId) async {
    return BaseApiService.delete('/Favorite/$favoriteId');
  }
}