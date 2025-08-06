import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../layouts/constants.dart';
import '../layouts/admin_main_layout.dart';
import '../models/donation_campaign_model.dart';
import '../providers/auth_provider.dart';
import './donation_details_screen.dart';
import './add_donation_campaign_screen.dart';

class DonationCampaignsScreen extends StatefulWidget {
  const DonationCampaignsScreen({Key? key}) : super(key: key);

  @override
  State<DonationCampaignsScreen> createState() =>
      _DonationCampaignsScreenState();
}

class _DonationCampaignsScreenState extends State<DonationCampaignsScreen> {
  bool _isLoading = true;
  List<DonationCampaign> _allCampaigns = [];
  List<DonationCampaign> _activeCampaigns = [];
  List<DonationCampaign> _pastCampaigns = [];
  bool _showActiveCampaigns = true;

  late AdminMainLayoutState? _adminLayoutState;
  int _lastNavigationValue = 0;

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNavigationListener();
    });
  }

  void _setupNavigationListener() {
    _adminLayoutState = context.findAncestorStateOfType<AdminMainLayoutState>();
    if (_adminLayoutState != null) {
      _adminLayoutState!.navigationChangeNotifier.addListener(
        _onNavigationChanged,
      );
      _lastNavigationValue = _adminLayoutState!.navigationChangeNotifier.value;
    }
  }

  void _onNavigationChanged() {
    if (!mounted) return;
    if (_adminLayoutState != null &&
        _adminLayoutState!.navigationChangeNotifier.value !=
            _lastNavigationValue) {
      _lastNavigationValue = _adminLayoutState!.navigationChangeNotifier.value;

      _fetchCampaigns();
    }
  }

  @override
  void dispose() {
    if (_adminLayoutState != null) {
      _adminLayoutState!.navigationChangeNotifier.removeListener(
        _onNavigationChanged,
      );
    }
    super.dispose();
  }

  void _filterCampaigns() {
    final now = DateTime.now();
    _activeCampaigns = _allCampaigns
        .where((campaign) => campaign.endDate.isAfter(now))
        .toList();
    _pastCampaigns = _allCampaigns
        .where((campaign) => campaign.endDate.isBefore(now))
        .toList();
  }

  Future<void> _fetchCampaigns() async {
    if (!mounted) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/DonationCampaign'),
        headers: AuthProvider.getHeaders(),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('items')) {
          setState(() {
            _allCampaigns = (data['items'] as List)
                .map((item) => DonationCampaign.fromJson(item))
                .toList();
            _filterCampaigns();
            _isLoading = false;
          });
        }
      } else {
        print('Failed to load campaigns: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        print('Error loading campaigns: $e');
      }
    }
  }

  Widget _buildCampaignCard(DonationCampaign campaign) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          final adminLayoutState = context
              .findAncestorStateOfType<AdminMainLayoutState>();
          if (adminLayoutState != null) {
            adminLayoutState.setContent(
              DonationDetailsScreen(campaign: campaign),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: campaign.imageUrl != null
                  ? Image.network(
                      campaign.imageUrl!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 160,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 50),
                      ),
                    )
                  : Container(
                      height: 160,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 50),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.title,
                      style: const TextStyle(
                        fontSize: 16, // Smaller font size
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4), // Reduced spacing
                    Expanded(
                      child: Text(
                        campaign.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          height: 1.2,
                          fontSize: 13, 
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'End date: ${DateFormat('dd.MM.yyyy').format(campaign.endDate)}',
                          style: TextStyle(color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 4),
                        if (campaign.endDate.isBefore(DateTime.now()))
                          const Icon(Icons.history, size: 14, color: Colors.red)
                        else
                          const Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4), 
                    Text(
                      '${campaign.totalAmount.toStringAsFixed(2)} KM',
                      style: const TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Donations',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                _showActiveCampaigns
                    ? 'Active campaigns'
                    : 'Previous campaigns',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
              const Spacer(),
              if (_showActiveCampaigns)
                ElevatedButton.icon(
                  onPressed: () async {
                    final adminLayoutState = context
                        .findAncestorStateOfType<AdminMainLayoutState>();
                    if (adminLayoutState != null) {
                      // Show add campaign screen
                      adminLayoutState.setContent(
                        const AddDonationCampaignScreen(),
                      );
                      await Future.delayed(const Duration(seconds: 2));
                      if (mounted) {
                        _fetchCampaigns();
                      }
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('ADD NEW'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _showActiveCampaigns = !_showActiveCampaigns;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(
                    color: _showActiveCampaigns
                        ? Colors.grey[300]!
                        : Colors.pink,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  backgroundColor: _showActiveCampaigns
                      ? null
                      : Colors.pink.withOpacity(0.1),
                ),
                child: Text(_showActiveCampaigns ? 'PREVIOUS' : 'ACTIVE'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.pink))
          else
            Expanded(
              child: ListView(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 24.0,
                          mainAxisSpacing: 24.0,
                          childAspectRatio:
                              0.9, // Adjust this value to give more height
                        ),
                    itemCount: _showActiveCampaigns
                        ? _activeCampaigns.length
                        : _pastCampaigns.length,
                    itemBuilder: (context, index) => _buildCampaignCard(
                      _showActiveCampaigns
                          ? _activeCampaigns[index]
                          : _pastCampaigns[index],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
