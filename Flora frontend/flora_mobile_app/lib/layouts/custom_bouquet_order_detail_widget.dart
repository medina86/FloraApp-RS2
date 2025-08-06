import 'package:flutter/material.dart';
import 'package:flora_mobile_app/models/order_detail.dart';
import 'package:flora_mobile_app/models/custom_bouquet_model.dart';
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flora_mobile_app/providers/auth_provider.dart';
import 'package:flora_mobile_app/helpers/image_loader.dart';

class CustomBouquetOrderDetailWidget extends StatefulWidget {
  final OrderDetailModel orderDetail;

  const CustomBouquetOrderDetailWidget({super.key, required this.orderDetail});

  @override
  State<CustomBouquetOrderDetailWidget> createState() =>
      _CustomBouquetOrderDetailWidgetState();
}

class _CustomBouquetOrderDetailWidgetState
    extends State<CustomBouquetOrderDetailWidget> {
  bool _isExpanded = false;
  bool _isLoading = false;
  CustomBouquetModel? _bouquetDetails;

  @override
  void initState() {
    super.initState();
    if (widget.orderDetail.customBouquetId != null) {
      _loadBouquetDetails();
    }
  }

  Future<void> _loadBouquetDetails() async {
    if (widget.orderDetail.customBouquetId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        '$baseUrl/CustomBouquet/${widget.orderDetail.customBouquetId}',
      );
      final response = await http.get(url, headers: AuthProvider.getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _bouquetDetails = CustomBouquetModel.fromJson(data);
          _isLoading = false;
        });
      } else {
        throw Exception(
          'Failed to load bouquet details: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading custom bouquet details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.orderDetail.productImageUrl?.isNotEmpty == true
        ? widget.orderDetail.productImageUrl!
        : 'https://via.placeholder.com/80x80/FFB6C1/FFFFFF?text=Custom+Bouquet';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color.fromARGB(255, 255, 210, 233),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ImageLoader.loadImage(
                          url: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Special marker za custom buket
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 170, 46, 92),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Custom Bouquet",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Color.fromARGB(255, 170, 46, 92),
                            ),
                            onPressed: () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                          ),
                        ],
                      ),
                      if (_bouquetDetails != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.color_lens,
                              size: 16,
                              color: Color.fromARGB(255, 170, 46, 92),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Color: ${_bouquetDetails?.color}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      Text(
                        'Quantity: ${widget.orderDetail.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(widget.orderDetail.priceAtPurchase * widget.orderDetail.quantity).toStringAsFixed(2)} KM',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 170, 46, 92),
                  ),
                ),
              ],
            ),
            // Expanded view with details
            if (_isExpanded)
              _isLoading
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color.fromARGB(255, 170, 46, 92),
                      ),
                    )
                  : _bouquetDetails == null
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      child: const Text('No details available'),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          const Text(
                            'Bouquet Contents:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ..._bouquetDetails!.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.fiber_manual_record,
                                    size: 8,
                                    color: Color.fromARGB(255, 170, 46, 92),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${item.quantity}x ${item.productName}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (widget.orderDetail.specialInstructions != null &&
                              widget
                                  .orderDetail
                                  .specialInstructions!
                                  .isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Special Instructions: ${widget.orderDetail.specialInstructions}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          if (widget.orderDetail.cardMessage != null &&
                              widget.orderDetail.cardMessage!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Card Message: ${widget.orderDetail.cardMessage}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}
