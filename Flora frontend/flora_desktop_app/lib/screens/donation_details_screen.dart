import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../layouts/constants.dart';
import '../layouts/admin_main_layout.dart';
import '../models/donation_campaign_model.dart';
import '../models/donation_model.dart';
import '../providers/auth_provider.dart';
import './donation_campaigns_screen.dart';

class DonationDetailsScreen extends StatefulWidget {
  final DonationCampaign campaign;

  const DonationDetailsScreen({Key? key, required this.campaign})
    : super(key: key);

  @override
  State<DonationDetailsScreen> createState() => _DonationDetailsScreenState();
}

class _DonationDetailsScreenState extends State<DonationDetailsScreen> {
  bool _isLoading = true;
  List<Donation> _donations = [];

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  Future<void> _fetchDonations() async {
    if (!mounted) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Donation?campaignId=${widget.campaign.id}'),
        headers: AuthProvider.getHeaders(),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('items')) {
          setState(() {
            _donations = (data['items'] as List)
                .map((item) => Donation.fromJson(item))
                .toList();
            _isLoading = false;
          });
        }
      } else {
        print('Failed to load donations: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        print('Error loading donations: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminLayoutState = context
        .findAncestorStateOfType<AdminMainLayoutState>();

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  if (adminLayoutState != null) {
                    adminLayoutState.setSelectedIndex(
                      3,
                    ); // This will show the DonationCampaignsScreen

                    // Give the navigation time to update
                    await Future.delayed(const Duration(milliseconds: 300));
                  }
                },
                tooltip: 'Back to campaigns',
                style: IconButton.styleFrom(foregroundColor: Colors.grey[700]),
              ),
              const SizedBox(width: 16),
              const Text(
                'Campaign Details',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.campaign.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.campaign.imageUrl!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 200,
                                height: 200,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image, size: 50),
                              ),
                        ),
                      ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.campaign.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.campaign.description,
                            style: TextStyle(
                              color: Colors.grey[800],
                              height: 1.5,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'End date: ${DateFormat('dd.MM.yyyy').format(widget.campaign.endDate)}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total amount',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.campaign.totalAmount.toStringAsFixed(2)} KM',
                        style: const TextStyle(
                          color: Colors.pink,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Donations List',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _fetchDonations,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.pink))
          else
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF666666),
                    ),
                    dataTextStyle: TextStyle(color: Colors.grey[800]),
                    horizontalMargin: 24,
                    columns: const [
                      DataColumn(label: Text('Donor')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Purpose')),
                      DataColumn(label: Text('Date')),
                    ],
                    rows: _donations.map((donation) {
                      return DataRow(
                        cells: [
                          DataCell(Text(donation.donorName)),
                          DataCell(Text(donation.email)),
                          DataCell(
                            Text(
                              '${donation.amount.toStringAsFixed(2)} KM',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(Text(donation.purpose)),
                          DataCell(
                            Text(
                              DateFormat('dd.MM.yyyy').format(donation.date),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
