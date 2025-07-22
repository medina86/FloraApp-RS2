import 'dart:convert';
import 'package:flora_desktop_app/layouts/constants.dart';
import 'package:http/http.dart' as http;
import 'auth_provider.dart';

abstract class BaseApiService {

  static Map<String, String> get _headers {
    final headers = <String, String>{'Content-Type': 'application/json'};
    
    if (AuthProvider.isAuthenticated) {
      headers.addAll(AuthProvider.getHeaders());
    }
    
    return headers;
  }

  static void _handleResponse(http.Response response, String operation) {
    if (response.statusCode == 401) {
      AuthProvider.logout();
      throw UnauthorizedException('Session expired. Please login again.');
    } else if (response.statusCode >= 400) {
      throw ApiException(
        '$operation failed: ${response.body}',
        response.statusCode,
      );
    }
  }

  static Future<T> get<T>(String endpoint, T Function(dynamic) parser) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      
      _handleResponse(response, 'GET $endpoint');
      
      final data = json.decode(response.body);
      return parser(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<T> post<T>(
    String endpoint, 
    Map<String, dynamic> body, 
    T Function(dynamic) parser
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(body),
      );
      
      _handleResponse(response, 'POST $endpoint');
      
      if (response.body.isEmpty) {
        return parser(null);
      }
      
      final data = json.decode(response.body);
      return parser(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<T> postEmpty<T>(
    String endpoint, 
    T Function(dynamic) parser
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      
      _handleResponse(response, 'POST $endpoint');
      
      if (response.body.isEmpty) {
        return parser(null);
      }
      
      final data = json.decode(response.body);
      return parser(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<T> put<T>(
    String endpoint, 
    Map<String, dynamic> body, 
    T Function(dynamic) parser
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(body),
      );
      
      _handleResponse(response, 'PUT $endpoint');
      
      final data = json.decode(response.body);
      return parser(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  static Future<T> deleteWithResponse<T>(
    String endpoint, 
    T Function(dynamic) parser
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      
      _handleResponse(response, 'DELETE $endpoint');
      
      if (response.body.isEmpty) {
        return parser(null);
      }
      
      final data = json.decode(response.body);
      return parser(data);
    } catch (e) {
      rethrow;
    }
  }

  static String buildQueryString(Map<String, dynamic> params) {
    if (params.isEmpty) return '';
    
    final queryParams = params.entries.map((e) {
      return '${Uri.encodeComponent(e.key.toString())}=${Uri.encodeComponent(e.value.toString())}';
    }).join('&');
    
    return '?$queryParams';
  }

  static Future<T> getWithParams<T>(
    String endpoint, 
    Map<String, dynamic> params,
    T Function(dynamic) parser
  ) async {
    final queryString = buildQueryString(params);
    return get('$endpoint$queryString', parser);
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}