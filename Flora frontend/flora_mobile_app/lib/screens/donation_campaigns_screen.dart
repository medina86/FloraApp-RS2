import 'package:flutter/material.dart';
import 'package:flora_mobile_app/models/donation_campaign.dart';
import 'package:flora_mobile_app/providers/donation_api.dart';
import 'package:flora_mobile_app/screens/donation_screen.dart';
import 'package:intl/intl.dart';
import 'package:flora_mobile_app/helpers/image_loader.dart';

class DonationCampaignsScreen extends StatefulWidget {
  final int userId;
  final VoidCallback? onBack;
  final bool fromHomeScreen;

  const DonationCampaignsScreen({
    Key? key,
    required this.userId,
    this.onBack,
    this.fromHomeScreen = false,
  }) : super(key: key);

  @override
  State<DonationCampaignsScreen> createState() =>
      _DonationCampaignsScreenState();
}

class _DonationCampaignsScreenState extends State<DonationCampaignsScreen> {
  List<DonationCampaign> _campaigns = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  String _getRemainingTime(DateTime endDate) {
    final now = DateTime.now();
    final remaining = endDate.difference(now);

    if (remaining.inDays > 0) {
      return '${remaining.inDays} days remaining';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours} hours remaining';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes} minutes remaining';
    } else {
      return 'Ending soon';
    }
  }

  Future<void> _loadCampaigns() async {
    try {
      final allCampaigns = await DonationApiService.getActiveCampaigns();
      final now = DateTime.now();

      final activeCampaigns = allCampaigns.where((campaign) {
        return campaign.endDate.isAfter(now);
      }).toList();

      setState(() {
        _campaigns = activeCampaigns;
        _isLoading = false;
      });

      if (activeCampaigns.isEmpty && mounted) {
        setState(() {
          _errorMessage = 'No active donation campaigns at the moment.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load campaigns: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 170, 46, 92),
          ),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Donations',
          style: TextStyle(
            color: Color.fromARGB(255, 170, 46, 92),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 170, 46, 92),
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadCampaigns,
              color: const Color.fromARGB(255, 170, 46, 92),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active campaigns',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._campaigns.map(
                        (campaign) => _buildCampaignCard(campaign),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCampaignCard(DonationCampaign campaign) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DonationScreen(
                campaign: campaign,
                userId: widget.userId,
                fromHomeScreen: widget.fromHomeScreen,
                onBack: () => Navigator.pop(context),
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (campaign.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: ImageLoader.loadImage(
                  url: campaign.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 170, 46, 92),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    campaign.description,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End date: ${DateFormat('dd.M.yyyy').format(campaign.endDate)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getRemainingTime(campaign.endDate),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 170, 46, 92),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DonationScreen(
                                campaign: campaign,
                                userId: widget.userId,
                                fromHomeScreen: widget.fromHomeScreen,
                                onBack: () => Navigator.pop(context),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            143,
                            199,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Donate'),
                      ),
                    ],
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
