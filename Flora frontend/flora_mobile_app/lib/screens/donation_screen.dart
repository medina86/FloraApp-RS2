import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flora_mobile_app/models/donation.dart';
import 'package:flora_mobile_app/models/donation_campaign.dart';
import 'package:flora_mobile_app/providers/donation_api.dart';
import 'package:flora_mobile_app/providers/auth_provider.dart';

class DonationScreen extends StatefulWidget {
  final DonationCampaign campaign;
  final int userId;
  final VoidCallback? onBack;
  final bool fromHomeScreen;

  const DonationScreen({
    Key? key,
    required this.campaign,
    required this.userId,
    this.onBack,
    this.fromHomeScreen = false,
  }) : super(key: key);

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isProcessing = false;

  void _handlePredefinedAmount(double amount) {
    setState(() {
      _amountController.text = amount.toString();
    });
  }

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final user = AuthProvider.getUser();
      if (user == null) {
        throw Exception('User not logged in');
      }

      final donation = Donation(
        donorName: user.firstName + ' ' + user.lastName,
        email: user.email,
        amount: double.parse(_amountController.text),
        purpose: widget.campaign.title,
        campaignId: widget.campaign.id,
      );

      await DonationApiService.makeDonation(donation);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your donation!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process donation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
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
        title: Text(
          widget.campaign.title,
          style: const TextStyle(
            color: Color.fromARGB(255, 170, 46, 92),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.campaign.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.campaign.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  widget.campaign.description,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Select the amount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildAmountButton(10),
                      const SizedBox(width: 8),
                      _buildAmountButton(20),
                      const SizedBox(width: 8),
                      _buildAmountButton(50),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Or insert yours:',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Enter amount (KM)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 170, 46, 92),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _submitDonation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 143, 199),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'DONATE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountButton(double amount) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: () => _handlePredefinedAmount(amount),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 143, 199),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(
          '$amount KM',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
