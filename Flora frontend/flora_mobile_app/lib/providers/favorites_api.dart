import 'dart:convert';
import 'package:flora_mobile_app/models/favorite_product.dart';
import 'package:http/http.dart' as http;
import 'package:flora_mobile_app/layouts/constants.dart';

class FavoriteApiService {
  static Future<List<FavoriteProduct>> getFavoritesByUser(int userId) async {
    try {
      final url = '$baseUrl/favorite?UserId=$userId';
      print('🔍 Fetching favorites from: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('📡 Status: ${response.statusCode}');
      print('📄 Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> items = jsonResponse['items'] ?? [];
        
        print('✅ Found ${items.length} favorite products');
        
        return items.map((json) {
          try {
            return FavoriteProduct.fromJson(json);
          } catch (e) {
            print('❌ Error parsing favorite: $e');
            print('🔍 Problematic JSON: $json');
            rethrow;
          }
        }).toList();
      } else {
        throw Exception('Failed to load favorites: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Exception in getFavoritesByUser: $e');
      rethrow;
    }
  }
  static Future<List<int>> getFavoriteProductIds(int userId) async {
    try {
      final url = '$baseUrl/favorite/details/user/$userId';
      print('🔍 Fetching favorite IDs from: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('📡 Status: ${response.statusCode}');
      print('📄 Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> ids = json.decode(response.body);
        return ids.map((id) => id as int).toList();
      } else {
        throw Exception('Failed to load favorite IDs: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Exception in getFavoriteProductIds: $e');
      rethrow;
    }
  }

  static Future<bool> addToFavorites(int userId, int productId) async {
    try {
      final url = '$baseUrl/favorite';
      print('➕ Adding to favorites: User $userId, Product $productId');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'productId': productId,
        }),
      );
      
      print('📡 Add favorite status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Successfully added to favorites');
        return true;
      } else {
        print('❌ Failed to add to favorites: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Exception in addToFavorites: $e');
      return false;
    }
  }
static Future<bool> removeFromFavoritesByFavoriteId(int favoriteId) async {
    try {
      final url = '$baseUrl/Favorite/$favoriteId';
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 202) {
        print('✅ Successfully removed from favorites');
        return true;
      } else {
        print('❌ Failed to remove from favorites: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Exception in removeFromFavoritesByFavoriteId: $e');
      return false;
    }
  }
}
