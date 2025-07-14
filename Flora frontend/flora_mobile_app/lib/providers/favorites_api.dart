import 'dart:convert';
import 'package:flora_mobile_app/models/favorite_product.dart';
import 'package:http/http.dart' as http;
import 'package:flora_mobile_app/layouts/constants.dart';

class FavoriteApiService {
  static Future<List<FavoriteProduct>> getFavoritesByUser(int userId) async {
    try {
      final url = '$baseUrl/favorite?UserId=$userId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> items = jsonResponse['items'] ?? [];

        return items.map((json) {
          try {
            return FavoriteProduct.fromJson(json);
          } catch (e) {
            rethrow;
          }
        }).toList();
      } else {
        throw Exception('Failed to load favorites: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<int>> getFavoriteProductIds(int userId) async {
    try {
      final url = '$baseUrl/favorite/details/user/$userId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> ids = json.decode(response.body);
        return ids.map((id) => id as int).toList();
      } else {
        throw Exception('Failed to load favorite IDs: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> addToFavorites(int userId, int productId) async {
    try {
      final url = '$baseUrl/favorite';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'productId': productId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> removeFromFavoritesByFavoriteId(int favoriteId) async {
    try {
      final url = '$baseUrl/Favorite/$favoriteId';
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 202) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
