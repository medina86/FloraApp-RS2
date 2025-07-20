import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/order_model.dart';
import '../models/shipping_address_model.dart';
import '../layouts/constants.dart'; 

class OrderApiService {

  static Future<OrderModel> createOrderFromCart({
    required int userId,
    required int cartId,
    required ShippingAddressModel shippingAddress,
  }) async {
    try {
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
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      print('Order API Response Status Code: ${response.statusCode}');
      print('Order API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return OrderModel.fromJson(data);
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      print('Error in OrderApiService.createOrderFromCart: $e');
      throw Exception('Error creating order: $e');
    }
  }
  static Future<OrderModel> confirmPayPalPayment({
    required int orderId,
    required String paymentId,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/Order/confirm-paypal-payment?orderId=$orderId&paymentId=$paymentId',
      );
      print('Confirm PayPal Payment URL: $url');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('Confirm PayPal Payment Response Status Code: ${response.statusCode}');
      print('Confirm PayPal Payment Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return OrderModel.fromJson(data);
      } else {
        throw Exception('Failed to confirm PayPal payment: ${response.body}');
      }
    } catch (e) {
      print('Error in OrderApiService.confirmPayPalPayment: $e');
      throw Exception('Error confirming PayPal payment: $e');
    }
  }

  static Future<List<OrderModel>> getOrdersByStatus(String status) async {
    try {
      final url = Uri.parse('$baseUrl/Order?Status=$status');
      print('Fetching orders by status: $url');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        return items.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error in OrderApiService.getOrdersByStatus: $e');
      throw Exception('Error fetching orders: $e');
    }
  }

  static Future<OrderModel> processOrder(int orderId) async {
    try {
      final url = Uri.parse('$baseUrl/Order/$orderId/process'); 
      print('Processing order: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return OrderModel.fromJson(data);
      } else {
        throw Exception('Failed to process order: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error in OrderApiService.processOrder: $e');
      throw Exception('Error processing order: $e');
    }
  }

  static Future<OrderModel> deliverOrder(int orderId) async {
    try {
      final url = Uri.parse('$baseUrl/Order/$orderId/deliver'); 
      print('Delivering order: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return OrderModel.fromJson(data);
      } else {
        throw Exception('Failed to deliver order: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error in OrderApiService.deliverOrder: $e');
      throw Exception('Error delivering order: $e');
    }
  }
}
