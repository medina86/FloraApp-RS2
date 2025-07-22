import 'package:flora_desktop_app/providers/base_provider.dart';
import '../models/order_model.dart';
import '../models/shipping_address_model.dart';

class OrderApiService {

  static Future<OrderModel> createOrderFromCart({
    required int userId,
    required int cartId,
    required ShippingAddressModel shippingAddress,
  }) {
    final body = {
      'userId': userId,
      'cartId': cartId,
      'shippingAddress': shippingAddress.toJson(),
    };

    return BaseApiService.post<OrderModel>(
      '/Order/createFromCart',
      body,
      (data) => OrderModel.fromJson(data),
    );
  }

  static Future<OrderModel> confirmPayPalPayment({
    required int orderId,
    required String paymentId,
  }) {
    final endpoint = '/Order/confirm-paypal-payment?orderId=$orderId&paymentId=$paymentId';

    return BaseApiService.postEmpty<OrderModel>(
      endpoint,
      (data) => OrderModel.fromJson(data),
    );
  }

  static Future<List<OrderModel>> getOrdersByStatus(String status) async {
    final params = {'Status': status};

    return BaseApiService.getWithParams<List<OrderModel>>(
      '/Order',
      params,
      (data) {
        final items = data['items'] as List<dynamic>;
        return items.map((json) => OrderModel.fromJson(json)).toList();
      },
    );
  }

  static Future<OrderModel> processOrder(int orderId) {
    return BaseApiService.postEmpty<OrderModel>(
      '/Order/$orderId/process',
      (data) => OrderModel.fromJson(data),
    );
  }

  static Future<OrderModel> deliverOrder(int orderId) {
    return BaseApiService.postEmpty<OrderModel>(
      '/Order/$orderId/deliver',
      (data) => OrderModel.fromJson(data),
    );
  }
}
