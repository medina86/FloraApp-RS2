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

  // Pretpostavljamo da postoji ProductController na backendu za dohvaćanje proizvoda
  static Future<List<Product>> getAvailableFlowers() async {
    try {
      final url = Uri.parse('$baseUrl/Product'); // Prilagodi URL ako je drugačiji
      print('Fetching available flowers from: $url');

     

      final response = await http.get(
        url,
        headers:AuthProvider.getHeaders(), 
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items']; // Pretpostavljamo da je lista proizvoda pod 'items'
        return items.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load available flowers: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error in CustomBouquetApiService.getAvailableFlowers: $e');
      throw Exception('Error fetching available flowers: $e');
    }
  }
}
