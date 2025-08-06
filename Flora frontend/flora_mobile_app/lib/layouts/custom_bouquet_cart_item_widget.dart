import 'package:flutter/material.dart';
import 'package:flora_mobile_app/models/cart_model.dart';
import 'package:flora_mobile_app/models/custom_bouquet_model.dart';
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flora_mobile_app/providers/auth_provider.dart';

class CustomBouquetCartItemWidget extends StatefulWidget {
  final CartItemModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;
  final bool isUpdating;
  final VoidCallback? onTap;

  const CustomBouquetCartItemWidget({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    required this.isUpdating,
    this.onTap,
  });

  @override
  State<CustomBouquetCartItemWidget> createState() =>
      _CustomBouquetCartItemWidgetState();
}

class _CustomBouquetCartItemWidgetState
    extends State<CustomBouquetCartItemWidget> {
  bool _isExpanded = false;
  bool _isLoading = false;
  CustomBouquetModel? _bouquetDetails;

  @override
  void initState() {
    super.initState();
    // Load the bouquet details if this is a custom bouquet
    if (widget.item.customBouquetId != null) {
      _loadBouquetDetails();
    }
  }

  Future<void> _loadBouquetDetails() async {
    if (widget.item.customBouquetId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Load bouquet details from API
      final url = Uri.parse(
        '$baseUrl/CustomBouquet/${widget.item.customBouquetId}',
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
    final imageUrl = widget.item.imageUrl?.isNotEmpty == true
        ? widget.item.imageUrl!
        : 'https://via.placeholder.com/80x80/FFB6C1/FFFFFF?text=Custom+Bouquet';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color.fromARGB(255, 255, 210, 233),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color.fromARGB(255, 170, 46, 92),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
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
                          Expanded(
                            child: Text(
                              "Custom Bouquet",
                              style: const TextStyle(
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
                      Row(
                        children: [
                          const Icon(
                            Icons.color_lens,
                            size: 16,
                            color: Color.fromARGB(255, 170, 46, 92),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Color: ${_bouquetDetails?.color ?? 'Loading...'}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.item.price.toStringAsFixed(2)} KM',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 170, 46, 92),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Quantity Controls
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: widget.isUpdating ? null : widget.onDecrease,
                          child: Container(
                            width: 32,
                            height: 32,
                            child: const Icon(
                              Icons.remove,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${widget.item.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: widget.isUpdating ? null : widget.onIncrease,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 170, 46, 92),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: widget.isUpdating ? null : widget.onRemove,
                    child: Container(
                      width: 40,
                      height: 40,
                      child: widget.isUpdating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color.fromARGB(255, 170, 46, 92),
                              ),
                            )
                          : const Icon(
                              Icons.delete,
                              color: Color.fromARGB(255, 170, 46, 92),
                            ),
                    ),
                  ),
                ),
              ],
            ),

            // Expanded view with bouquet details
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
                          if (widget.item.specialInstructions != null &&
                              widget.item.specialInstructions!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Special Instructions: ${widget.item.specialInstructions}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          if (widget.item.cardMessage != null &&
                              widget.item.cardMessage!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Card Message: ${widget.item.cardMessage}',
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
