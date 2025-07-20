import 'dart:convert';
import 'package:flora_mobile_app/models/order.dart';
import 'package:flora_mobile_app/models/paypal_model.dart';
import 'package:flora_mobile_app/models/shipping_model.dart';
import 'package:flora_mobile_app/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
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

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return OrderModel.fromJson(data);
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
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
      final requestBody = json.encode({
        'orderId': orderId,
        'amount': amount,
        'currency': currency,
        'returnUrl': returnUrl,
        'cancelUrl': cancelUrl,
      });

      final url = Uri.parse('$baseUrl/Order/initiatePayPalPayment');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PayPalPaymentResponse.fromJson(data);
      } else {
        throw Exception('Failed to initiate PayPal payment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error initiating PayPal payment: $e');
    }
  }

  static Future<List<OrderModel>> getOrdersByUserId(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/Order?UserId=$userId');
      print('Fetching orders by user ID: $url');
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        return items.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load orders for user: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('Error in OrderApiService.getOrdersByUserId: $e');
      throw Exception('Error fetching orders for user: $e');
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

      final response = await http.post(url, headers: AuthProvider.getHeaders());

      print(
        'Confirm PayPal Payment Response Status Code: ${response.statusCode}',
      );
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
}
