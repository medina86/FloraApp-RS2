import 'package:flora_desktop_app/providers/base_provider.dart';
import '../models/order_model.dart';
import '../models/shipping_address_model.dart';
import '../models/paged_result.dart';

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
    final endpoint =
        '/Order/confirm-paypal-payment?orderId=$orderId&paymentId=$paymentId';

    return BaseApiService.postEmpty<OrderModel>(
      endpoint,
      (data) => OrderModel.fromJson(data),
    );
  }

  static Future<List<OrderModel>> getOrdersByStatus(String status) async {
    final params = {'Status': status};

    return BaseApiService.getWithParams<List<OrderModel>>('/Order', params, (
      data,
    ) {
      final items = data['items'] as List<dynamic>;
      return items.map((json) => OrderModel.fromJson(json)).toList();
    });
  }

  // Metoda za dohvaćanje svih narudžbi bez filtera
  static Future<List<OrderModel>> getAllOrders() async {
    try {
      print('Debug - Getting all orders from API...');

      // Koristimo params da eksplicitno postavimo RetrieveAll i IncludeTotalCount
      final params = <String, String>{
        'RetrieveAll': 'true',
        'IncludeTotalCount': 'true',
        'PageSize': '1000', // veliki broj za slučaj da RetrieveAll ne radi
      };

      final result = await BaseApiService.getWithParams<List<OrderModel>>(
        '/Order',
        params,
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

  static Future<List<OrderModel>> getActiveOrders() async {
    try {
      final allOrders = await getAllOrders();

      return allOrders
          .where(
            (order) =>
                order.status == 'Pending' ||
                order.status == 'Processed' ||
                order.status == 'Delivered' ||
                order.status == 'PaymentInitiated',
          )
          .toList();
    } catch (e) {
      print('Error fetching active orders: $e');
      return [];
    }
  }

  static Future<List<OrderModel>> getCompletedOrders() async {
    try {
      final allOrders = await getAllOrders();

      return allOrders
          .where(
            (order) =>
                order.status == 'Completed' || order.status == 'Cancelled',
          )
          .toList();
    } catch (e) {
      print('Error fetching completed orders: $e');
      return [];
    }
  }

  // Paginacijske metode
  static Future<PagedResult<OrderModel>> getActiveOrdersPaginated({
    int page = 0,
    int pageSize = 10,
    String? searchQuery,
  }) async {
    try {
      // Dohvati sve aktivne narudžbe koristeći postojeću logiku
      List<OrderModel> allActiveOrders = await getActiveOrders();

      // Primijeni search filter ako postoji
      if (searchQuery != null && searchQuery.isNotEmpty) {
        allActiveOrders = allActiveOrders
            .where(
              (order) =>
                  order.id.toString().contains(searchQuery) ||
                  order.userId.toString().contains(searchQuery) ||
                  order.totalAmount.toString().contains(searchQuery),
            )
            .toList();
      }

      // Izračunaj paginaciju
      final totalCount = allActiveOrders.length;
      final startIndex = page * pageSize;
      final endIndex = (startIndex + pageSize).clamp(0, totalCount);

      final pageItems = startIndex < totalCount
          ? allActiveOrders.sublist(startIndex, endIndex)
          : <OrderModel>[];

      return PagedResult<OrderModel>(items: pageItems, totalCount: totalCount);
    } catch (e) {
      print('Error fetching paginated active orders: $e');
      return PagedResult<OrderModel>(items: [], totalCount: 0);
    }
  }

  static Future<PagedResult<OrderModel>> getCompletedOrdersPaginated({
    int page = 0,
    int pageSize = 10,
    String? searchQuery,
  }) async {
    try {
      // Dohvati sve završene narudžbe koristeći postojeću logiku
      List<OrderModel> allCompletedOrders = await getCompletedOrders();

      // Primijeni search filter ako postoji
      if (searchQuery != null && searchQuery.isNotEmpty) {
        allCompletedOrders = allCompletedOrders
            .where(
              (order) =>
                  order.id.toString().contains(searchQuery) ||
                  order.userId.toString().contains(searchQuery) ||
                  order.totalAmount.toString().contains(searchQuery),
            )
            .toList();
      }

      // Izračunaj paginaciju
      final totalCount = allCompletedOrders.length;
      final startIndex = page * pageSize;
      final endIndex = (startIndex + pageSize).clamp(0, totalCount);

      final pageItems = startIndex < totalCount
          ? allCompletedOrders.sublist(startIndex, endIndex)
          : <OrderModel>[];

      return PagedResult<OrderModel>(items: pageItems, totalCount: totalCount);
    } catch (e) {
      print('Error fetching paginated completed orders: $e');
      return PagedResult<OrderModel>(items: [], totalCount: 0);
    }
  }

  static Future<OrderModel> processOrder(int orderId) {
    return BaseApiService.postEmpty<OrderModel>(
      '/Order/$orderId/process',
      (data) => OrderModel.fromJson(data),
    );
  }

  static Future<OrderModel> markAsReadyForDelivery(int orderId) {
    return BaseApiService.postEmpty<OrderModel>(
      '/Order/$orderId/ready-for-delivery',
      (data) => OrderModel.fromJson(data),
    );
  }

  static Future<OrderModel> startDelivery(int orderId) {
    return BaseApiService.postEmpty<OrderModel>(
      '/Order/$orderId/start-delivery',
      (data) => OrderModel.fromJson(data),
    );
  }

  static Future<OrderModel> deliverOrder(int orderId) {
    return BaseApiService.postEmpty<OrderModel>(
      '/Order/$orderId/deliver',
      (data) => OrderModel.fromJson(data),
    );
  }

  static Future<OrderModel> completeOrder(int orderId) {
    return BaseApiService.postEmpty<OrderModel>(
      '/Order/$orderId/complete',
      (data) => OrderModel.fromJson(data),
    );
  }

  static Future<OrderModel> getOrderById(int orderId) {
    return BaseApiService.get<OrderModel>(
      '/Order/$orderId',
      (data) => OrderModel.fromJson(data),
    );
  }
}
