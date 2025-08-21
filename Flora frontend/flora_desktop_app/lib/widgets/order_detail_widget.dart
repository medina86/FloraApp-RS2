import 'package:flora_desktop_app/models/order_detail_model.dart';
import 'package:flora_desktop_app/models/custom_bouquet_model.dart';
import 'package:flora_desktop_app/providers/auth_provider.dart';
import 'package:flora_desktop_app/layouts/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart'; // Koristimo OrderItemModel

class OrderDetailProductCard extends StatefulWidget {
  final OrderDetailModel item;

  const OrderDetailProductCard({super.key, required this.item});

  @override
  State<OrderDetailProductCard> createState() => _OrderDetailProductCardState();
}

class _OrderDetailProductCardState extends State<OrderDetailProductCard> {
  CustomBouquetModel? _bouquetDetails;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.isCustomBouquet && widget.item.customBouquetId != null) {
      _loadBouquetDetails();
    }
  }

  Future<void> _loadBouquetDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
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
        throw Exception('Failed to load bouquet details');
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
    // Provjeri je li ovo custom bouquet
    if (widget.item.isCustomBouquet) {
      return _buildCustomBouquetCard();
    } else {
      return _buildRegularProductCard();
    }
  }

  Widget _buildCustomBouquetCard() {
    return Container(
      width: 280, // Šira kartica za custom bouquet
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 170, 46, 92),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 170, 46, 92).withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header s ikonicom
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: const Color.fromARGB(255, 170, 46, 92),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.item.productName ?? 'Custom Bouquet',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 170, 46, 92),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Loading state ili prikaz komponenti
          if (_isLoading) ...[
            const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 170, 46, 92),
              ),
            ),
          ] else if (_bouquetDetails != null) ...[
            // Prikaz boje buketa
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getColorFromName(_bouquetDetails!.color),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 0.5),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Color: ${_bouquetDetails!.color}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Komponente buketa
            const Text(
              'Components:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            ..._bouquetDetails!.items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.fiber_manual_record,
                          size: 8,
                          color: Color.fromARGB(255, 170, 46, 92),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.productName}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ] else if (widget.item.specialInstructions != null) ...[
            const Text(
              'Details:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.item.specialInstructions!,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            const Text(
              'No details available',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const Spacer(),

          // Količina i cijena
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qty: ${widget.item.quantity}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                '${widget.item.priceAtPurchase.toStringAsFixed(2)} KM',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 170, 46, 92),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegularProductCard() {
    final imageUrl = widget.item.productImageUrl?.isNotEmpty == true
        ? widget.item.productImageUrl!
        : 'https://via.placeholder.com/120x120/FFB6C1/FFFFFF?text=No+Image';

    return Container(
      width: 200, // Fiksna širina za karticu proizvoda
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 120,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: double.infinity,
                  height: 120,
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
          const SizedBox(height: 10),
          Text(
            widget.item.productName ?? 'Unknown Product',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Quantity: ${widget.item.quantity}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          // Show card message indicator if exists
          if (widget.item.cardMessage != null && widget.item.cardMessage!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.card_giftcard,
                  size: 14,
                  color: Color.fromARGB(255, 170, 46, 92),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Has card message',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Color.fromARGB(255, 170, 46, 92),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          // Show special instructions indicator if exists
          if (widget.item.specialInstructions != null && 
              widget.item.specialInstructions!.isNotEmpty && 
              !widget.item.isCustomBouquet) ...[
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Has special instructions',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Text(
            '${widget.item.priceAtPurchase.toStringAsFixed(2)} KM',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 170, 46, 92),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
      case 'crvena':
        return Colors.red;
      case 'pink':
      case 'roza':
        return Colors.pink;
      case 'white':
      case 'bijela':
        return Colors.white;
      case 'yellow':
      case 'žuta':
        return Colors.yellow;
      case 'purple':
      case 'ljubičasta':
        return Colors.purple;
      case 'blue':
      case 'plava':
        return Colors.blue;
      case 'orange':
      case 'narandžasta':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
