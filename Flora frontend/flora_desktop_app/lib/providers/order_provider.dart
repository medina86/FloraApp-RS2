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

  // Metoda za dohvaćanje svih narudžbi bez filtera
  static Future<List<OrderModel>> getAllOrders() async {
    try {
      print('Debug - Getting all orders from API...');
      final result = await BaseApiService.get<List<OrderModel>>(
        '/Order',
        (data) {
          print('Debug - API response data: $data');
          final items = data['items'] as List<dynamic>;
          print('Debug - Found ${items.length} orders');
          return items.map((json) => OrderModel.fromJson(json)).toList();
        },
      );
      print('Debug - Successfully retrieved ${result.length} orders');
      return result;
    } catch (e) {
      print('Debug - Error getting all orders: $e');
      rethrow;
    }
  }
  
  // Metoda za dohvaćanje aktivnih narudžbi (Pending, Processed, Delivered)
  static Future<List<OrderModel>> getActiveOrders() async {
    try {
      // Prvo dohvati sve narudžbe
      final allOrders = await getAllOrders();
      
      // Filtriraj samo aktivne narudžbe
      return allOrders.where((order) => 
        order.status == 'Pending' || 
        order.status == 'Processed' || 
        order.status == 'Delivered' ||
        order.status == 'PaymentInitiated'
      ).toList();
    } catch (e) {
      print('Error fetching active orders: $e');
      return [];
    }
  }

  // Metoda za dohvaćanje završenih narudžbi (Completed, Cancelled)
  static Future<List<OrderModel>> getCompletedOrders() async {
    try {
      // Prvo dohvati sve narudžbe
      final allOrders = await getAllOrders();
      
      // Filtriraj samo završene narudžbe
      return allOrders.where((order) => 
        order.status == 'Completed' || 
        order.status == 'Cancelled'
      ).toList();
    } catch (e) {
      print('Error fetching completed orders: $e');
      return [];
    }
  }

  // Metoda za obradu narudžbe (Pending -> Processing)
  static Future<OrderModel> processOrder(int orderId) {
    return BaseApiService.postEmpty<OrderModel>(
      '/Order/$orderId/process',
      (data) => OrderModel.fromJson(data),
    );
  }

  // Metoda za označavanje narudžbe kao spremne za isporuku (Processing -> ReadyForDelivery)
  static Future<OrderModel> markAsReadyForDelivery(int orderId) {
    return BaseApiService.postEmpty<OrderModel>(
      '/Order/$orderId/ready-for-delivery',
      (data) => OrderModel.fromJson(data),
    );
  }

  // Metoda za započinjanje dostave (ReadyForDelivery -> InDelivery)
  static Future<OrderModel> startDelivery(int orderId) {
    return BaseApiService.postEmpty<OrderModel>(
      '/Order/$orderId/start-delivery',
      (data) => OrderModel.fromJson(data),
    );
  }

  // Metoda za isporuku narudžbe (Processed -> Delivered)
  static Future<OrderModel> deliverOrder(int orderId) {
    return BaseApiService.postEmpty<OrderModel>(
      '/Order/$orderId/deliver',
      (data) => OrderModel.fromJson(data),
    );
  }

  // Metoda za završetak narudžbe (Delivered -> Completed)
  static Future<OrderModel> completeOrder(int orderId) {
    return BaseApiService.postEmpty<OrderModel>(
      '/Order/$orderId/complete',
      (data) => OrderModel.fromJson(data),
    );
  }

  // Metoda za dohvaćanje detalja narudžbe po ID-u
  static Future<OrderModel> getOrderById(int orderId) {
    return BaseApiService.get<OrderModel>(
      '/Order/$orderId',
      (data) => OrderModel.fromJson(data),
    );
  }
}
