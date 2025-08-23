import 'package:flora_mobile_app/models/order.dart';
import 'package:flora_mobile_app/models/paypal_model.dart';
import 'package:flora_mobile_app/models/shipping_model.dart';
import 'package:flora_mobile_app/providers/base_provider.dart';


class OrderApiService {
  static Future<OrderModel> createOrderFromCart({
    required int userId,
    required int cartId,
    required ShippingAddressModel shippingAddress,
  }) async {
    final body = {
      'userId': userId,
      'cartId': cartId,
      'shippingAddress': shippingAddress.toJson(),
    };

    return BaseApiService.post('/Order/createFromCart', body, (data) => OrderModel.fromJson(data));
  }

  static Future<PayPalPaymentResponse> initiatePayPalPayment({
    required int orderId,
    required double amount,
    required String currency,
    required String returnUrl,
    required String cancelUrl,
  }) async {
    final body = {
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'returnUrl': returnUrl,
      'cancelUrl': cancelUrl,
    };

    return BaseApiService.post('/Order/initiatePayPalPayment', body, (data) => PayPalPaymentResponse.fromJson(data));
  }

  static Future<OrderModel> confirmPayPalPayment({
    required int orderId,
    required String paymentId,
  }) async {
    return BaseApiService.postEmpty('/Order/confirm-paypal-payment?orderId=$orderId&paymentId=$paymentId', (data) => OrderModel.fromJson(data));
  }

  // Nova metoda za inicijalizaciju PayPal plaćanja bez kreiranja narudžbe
  static Future<PayPalPaymentResponse> initiatePayPalPaymentFromCart({
    required int userId,
    required int cartId,
    required ShippingAddressModel shippingAddress,
    required double amount,
    required String currency,
    required String returnUrl,
    required String cancelUrl,
  }) async {
    final body = {
      'userId': userId,
      'cartId': cartId,
      'shippingAddress': shippingAddress.toJson(),
      'amount': amount,
      'currency': currency,
      'returnUrl': returnUrl,
      'cancelUrl': cancelUrl,
    };

    return BaseApiService.post('/Order/initiatePayPalPaymentWithoutOrder', body, (data) => PayPalPaymentResponse.fromJson(data));
  }

  // Nova metoda za potvrdu PayPal plaćanja i kreiranje narudžbe
  static Future<OrderModel> confirmPayPalPaymentAndCreateOrder({
    required int userId,
    required int cartId,
    required ShippingAddressModel shippingAddress,
    required String paymentId,
    required String payerId,
  }) async {
    final queryParams = 'userId=$userId&cartId=$cartId&paymentId=$paymentId&payerId=$payerId';
    final body = shippingAddress.toJson();

    return BaseApiService.post(
      '/Order/confirm-paypal-payment-and-create-order?$queryParams', 
      body, 
      (data) => OrderModel.fromJson(data)
    );
  }
  
  // Nova metoda za inicijalizaciju PayPal plaćanja koristeći REST API
  static Future<PayPalPaymentResponse> initiatePayPalPaymentFromCartRest({
    required int userId,
    required int cartId,
    required ShippingAddressModel shippingAddress,
    required double amount,
    required String currency,
    required String returnUrl,
    required String cancelUrl,
  }) async {
    final body = {
      'userId': userId,
      'cartId': cartId,
      'shippingAddress': shippingAddress.toJson(),
      'amount': amount,
      'currency': currency,
      'returnUrl': returnUrl,
      'cancelUrl': cancelUrl,
    };

    return BaseApiService.post('/Order/initiatePayPalPaymentRest', body, (data) => PayPalPaymentResponse.fromJson(data));
  }

  // Nova metoda za potvrdu PayPal plaćanja i kreiranje narudžbe koristeći REST API
  static Future<OrderModel> confirmPayPalPaymentAndCreateOrderRest({
    required int userId,
    required int cartId,
    required ShippingAddressModel shippingAddress,
    required String orderId,
  }) async {
    final queryParams = 'userId=$userId&cartId=$cartId&orderId=$orderId';
    final body = shippingAddress.toJson();

    return BaseApiService.post(
      '/Order/confirm-paypal-payment-and-create-order-rest?$queryParams', 
      body, 
      (data) => OrderModel.fromJson(data)
    );
  }

  static Future<List<OrderModel>> getOrdersByStatus(String status) async {
    final params = {'Status': status};

    return BaseApiService.getWithParams('/Order', params, (data) {
      final Map<String, dynamic> jsonResponse = data as Map<String, dynamic>;
      final List<dynamic> items = jsonResponse['items'] ?? [];
      return items.map((json) => OrderModel.fromJson(json)).toList();
    });
  }

 static Future<List<OrderModel>> getOrdersByUserId(int userId, {bool retrieveAll = true, bool includeTotalCount = true}) async {
  final params = {
    'UserId': userId,
    'RetrieveAll': 'true', 
    'IncludeTotalCount': true,
  };

if (retrieveAll) {
  params['RetrieveAll'] = 'true'; 
}
if (includeTotalCount) {
  params['IncludeTotalCount'] = 'true'; 
}


  return BaseApiService.getWithParams('/Order', params, (data) {
    final Map<String, dynamic> jsonResponse = data as Map<String, dynamic>;
    final List<dynamic> items = jsonResponse['items'] ?? [];
    return items.map((json) => OrderModel.fromJson(json)).toList();
  });
}

  static Future<OrderModel> processOrder(int orderId) async {
    return BaseApiService.postEmpty('/Order/$orderId/process', (data) => OrderModel.fromJson(data));
  }

  static Future<OrderModel> deliverOrder(int orderId) async {
    return BaseApiService.postEmpty('/Order/$orderId/deliver', (data) => OrderModel.fromJson(data));
  }

  static Future<OrderModel> completeOrder(int orderId) async {
    return BaseApiService.postEmpty('/Order/$orderId/complete', (data) => OrderModel.fromJson(data));
  }
}