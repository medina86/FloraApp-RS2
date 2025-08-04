import 'dart:convert';
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class ImageApiService {
  static Future<String> getImageById(String imageId) async {
    try {
      final url = Uri.parse('$baseUrl/images/$imageId');
      developer.log('Fetching image via API: $url');

      final response = await http.get(url, headers: AuthProvider.getHeaders());

      if (response.statusCode == 200) {
        developer.log('Image successfully retrieved from API');

        return response.body;
      } else {
        developer.log('Failed to get image: ${response.statusCode}');
        return 'https://placehold.co/400x200?text=Error+Loading+Image';
      }
    } catch (e) {
      developer.log('Error getting image: $e');
      return 'https://placehold.co/400x200?text=Error+Loading+Image';
    }
  }

  /// Za budući razvoj: metoda za dodavanje slike
  static Future<String?> uploadImage(
    List<int> imageBytes,
    String filename,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/images/upload'),
      );

      request.headers.addAll(AuthProvider.getHeaders());

      request.files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: filename),
      );

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseString)['url'];
      } else {
        developer.log('Failed to upload image: $responseString');
        return null;
      }
    } catch (e) {
      developer.log('Error uploading image: $e');
      return null;
    }
  }
}
