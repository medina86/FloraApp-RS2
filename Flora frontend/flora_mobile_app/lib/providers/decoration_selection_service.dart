import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/models/decoration_selection.dart';
import 'package:flora_mobile_app/providers/auth_provider.dart';

class DecorationSelectionService {
  static Future<DecorationSelection> selectDecoration({
    required int decorationRequestId,
    required int decorationSuggestionId,
    required int userId,
    String? comments,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/DecorationSelection'),
        headers: {
          ...AuthProvider.getHeaders(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'decorationRequestId': decorationRequestId,
          'decorationSuggestionId': decorationSuggestionId,
          'userId': userId,
          'comments': comments,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return DecorationSelection.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to select decoration: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error selecting decoration: $e');
    }
  }

  static Future<DecorationSelection?> getSelectionByRequestId(
    int requestId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/DecorationSelection/byRequest/$requestId'),
        headers: AuthProvider.getHeaders(),
      );

      if (response.statusCode == 200) {
        return DecorationSelection.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null; // No selection found
      } else {
        throw Exception('Failed to get selection: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting decoration selection: $e');
    }
  }
}
