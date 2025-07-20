import 'package:flora_mobile_app/models/order_detail.dart';
import 'package:flora_mobile_app/models/shipping_model.dart';

class OrderModel {
  final int id;
  final int userId;
  final DateTime orderDate;
  final double totalAmount;
  final String? status;
  final ShippingAddressModel shippingAddress;
  final List<OrderDetailModel> orderDetails;

  OrderModel({
    required this.id,
    required this.userId,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.orderDetails,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var orderDetailsList = json['orderDetails'] as List;
    List<OrderDetailModel> orderDetails = orderDetailsList
        .map((i) => OrderDetailModel.fromJson(i))
        .toList();

    return OrderModel(
      id: json['id'],
      userId: json['userId'],
      orderDate: DateTime.parse(json['orderDate']),
      totalAmount: json['totalAmount']?.toDouble(),
      status: json['status'],
      shippingAddress: ShippingAddressModel.fromJson(json['shippingAddress']),
      orderDetails: orderDetails,
    );
  }
}