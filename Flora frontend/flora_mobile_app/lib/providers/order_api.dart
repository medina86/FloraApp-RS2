import 'dart:convert';
import 'package:flora_mobile_app/models/order.dart';
import 'package:flora_mobile_app/models/paypal_model.dart';
import 'package:flora_mobile_app/models/shipping_model.dart';
import 'package:flora_mobile_app/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import '../layouts/constants.dart';

class OrderApiService {
  
  static void _handleResponse(http.Response response, String operation) {
    print('$operation Response Status Code: ${response.statusCode}');
    print('$operation Response Body: ${response.body}');
    
    if (response.statusCode == 401) {
      AuthProvider.logout();
      throw UnauthorizedException('Session expired. Please login again.');
    } else if (response.statusCode != 200) {
      throw ApiException('$operation failed: ${response.body}', response.statusCode);
    }
  }

  static Future<OrderModel> createOrderFromCart({
    required int userId,
    required int cartId,
    required ShippingAddressModel shippingAddress,
  }) async {
    try {
      if (!AuthProvider.isAuthenticated) {
        throw UnauthorizedException('Please login first.');
      }

      final requestBody = json.encode({
        'userId': userId,
        'cartId': cartId,
        'shippingAddress': shippingAddress.toJson(),
      });
      
      final url = Uri.parse('$baseUrl/Order/createFromCart');
      print('Order API Request URL (from OrderApiService): $url');
      print('Order API Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: AuthProvider.getHeaders(),
        body: requestBody,
      );

      _handleResponse(response, 'Create Order');
      
      final data = json.decode(response.body);
      return OrderModel.fromJson(data);
    } catch (e) {
      print('Error in OrderApiService.createOrderFromCart: $e');
      rethrow; 
      
    }
  }

  static Future<PayPalPaymentResponse> initiatePayPalPayment({
    required int orderId,
    required double amount,
    required String currency,
    required String returnUrl,
    required String cancelUrl,
  }) async {
    try {
      if (!AuthProvider.isAuthenticated) {
        throw UnauthorizedException('Please login first.');
      }

      final requestBody = json.encode({
        'orderId': orderId,
        'amount': amount,
        'currency': currency,
        'returnUrl': returnUrl,
        'cancelUrl': cancelUrl,
      });

      final url = Uri.parse('$baseUrl/Order/initiatePayPalPayment');
      print('PayPal Payment Request URL: $url');
      print('PayPal Payment Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: AuthProvider.getHeaders(),
        body: requestBody,
      );

      _handleResponse(response, 'Initiate PayPal Payment');
      
      final data = json.decode(response.body);
      return PayPalPaymentResponse.fromJson(data);
    } catch (e) {
      print('Error in OrderApiService.initiatePayPalPayment: $e');
      rethrow;
    }
  }

  static Future<OrderModel> confirmPayPalPayment({
    required int orderId,
    required String paymentId,
  }) async {
    try {
      if (!AuthProvider.isAuthenticated) {
        throw UnauthorizedException('Please login first.');
      }

      final url = Uri.parse(
        '$baseUrl/Order/confirm-paypal-payment?orderId=$orderId&paymentId=$paymentId',
      );
      print('Confirm PayPal Payment URL: $url');

      final response = await http.post(
        url,
        headers: AuthProvider.getHeaders(),
      );

      _handleResponse(response, 'Confirm PayPal Payment');
      
      final data = json.decode(response.body);
      return OrderModel.fromJson(data);
    } catch (e) {
      print('Error in OrderApiService.confirmPayPalPayment: $e');
      rethrow;
    }
  }

  static Future<List<OrderModel>> getOrdersByStatus(String status) async {
    try {
      if (!AuthProvider.isAuthenticated) {
        throw UnauthorizedException('Please login first.');
      }

      final url = Uri.parse('$baseUrl/Order?Status=$status');
      print('Fetching orders by status: $url');
      
      final response = await http.get(
        url,
        headers: AuthProvider.getHeaders(),
      );

      _handleResponse(response, 'Get Orders by Status');
      
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> items = data['items'] ?? [];
      return items.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      print('Error in OrderApiService.getOrdersByStatus: $e');
      rethrow;
    }
  }

  static Future<List<OrderModel>> getOrdersByUserId(int userId) async {
    try {
      if (!AuthProvider.isAuthenticated) {
        throw UnauthorizedException('Please login first.');
      }

      final url = Uri.parse('$baseUrl/Order?UserId=$userId');
      print('Fetching orders by user ID: $url');
      
      final response = await http.get(
        url,
        headers: AuthProvider.getHeaders(),
      );

      _handleResponse(response, 'Get Orders by User ID');
      
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> items = data['items'] ?? [];
      return items.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      print('Error in OrderApiService.getOrdersByUserId: $e');
      rethrow;
    }
  }

  static Future<OrderModel> processOrder(int orderId) async {
    try {
      if (!AuthProvider.isAuthenticated) {
        throw UnauthorizedException('Please login first.');
      }

      final url = Uri.parse('$baseUrl/Order/$orderId/process');
      print('Processing order: $url');
      
      final response = await http.post(
        url,
        headers: AuthProvider.getHeaders(),
      );

      _handleResponse(response, 'Process Order');
      
      final data = json.decode(response.body);
      return OrderModel.fromJson(data);
    } catch (e) {
      print('Error in OrderApiService.processOrder: $e');
      rethrow;
    }
  }

  static Future<OrderModel> deliverOrder(int orderId) async {
    try {
      if (!AuthProvider.isAuthenticated) {
        throw UnauthorizedException('Please login first.');
      }

      final url = Uri.parse('$baseUrl/Order/$orderId/deliver');
      print('Delivering order: $url');
      
      final response = await http.post(
        url,
        headers: AuthProvider.getHeaders(),
      );

      _handleResponse(response, 'Deliver Order');
      
      final data = json.decode(response.body);
      return OrderModel.fromJson(data);
    } catch (e) {
      print('Error in OrderApiService.deliverOrder: $e');
      rethrow;
    }
  }

  static Future<OrderModel> completeOrder(int orderId) async {
    try {
      if (!AuthProvider.isAuthenticated) {
        throw UnauthorizedException('Please login first.');
      }

      final url = Uri.parse('$baseUrl/Order/$orderId/complete');
      print('Completing order: $url');
      
      final response = await http.post(
        url,
        headers: AuthProvider.getHeaders(),
      );

      _handleResponse(response, 'Complete Order');
      
      final data = json.decode(response.body);
      return OrderModel.fromJson(data);
    } catch (e) {
      print('Error in OrderApiService.completeOrder: $e');
      rethrow;
    }
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