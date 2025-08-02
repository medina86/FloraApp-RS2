import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../layouts/constants.dart';
import '../layouts/admin_main_layout.dart';
import '../models/donation_campaign_model.dart';
import '../models/donation_model.dart';
import '../providers/auth_provider.dart';

class AddDonationScreen extends StatefulWidget {
  final DonationCampaign? campaign;

  const AddDonationScreen({Key? key, this.campaign}) : super(key: key);

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<DonationCampaign> _campaigns = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  DonationCampaign? _selectedCampaign;

  @override
  void initState() {
    super.initState();
    _selectedCampaign = widget.campaign;
    if (_selectedCampaign == null) {
      _fetchCampaigns();
    }
  }

  Future<void> _fetchCampaigns() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/DonationCampaign'),
        headers: AuthProvider.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('items')) {
          setState(() {
            _campaigns = (data['items'] as List)
                .map((item) => DonationCampaign.fromJson(item))
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error loading campaigns: $e');
    }
  }

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Donation'),
        headers: {
          ...AuthProvider.getHeaders(),
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'donorName': _nameController.text,
          'email': _emailController.text,
          'amount': double.parse(_amountController.text),
          'purpose': _purposeController.text,
          'campaignId': _selectedCampaign!.id,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Donation submitted successfully')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('Failed to submit donation');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting donation: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Make a Donation',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.campaign == null) ...[
                      DropdownButtonFormField<DonationCampaign>(
                        value: _selectedCampaign,
                        decoration: const InputDecoration(
                          labelText: 'Campaign',
                          border: OutlineInputBorder(),
                        ),
                        items: _campaigns.map((campaign) {
                          return DropdownMenuItem(
                            value: campaign,
                            child: Text(campaign.title),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCampaign = value);
                        },
                        validator: (value) {
                          if (value == null) return 'Please select a campaign';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount (KM)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Amount must be greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _purposeController,
                      decoration: const InputDecoration(
                        labelText: 'Purpose',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the purpose of your donation';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitDonation,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Submit Donation'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _amountController.dispose();
    _purposeController.dispose();
    super.dispose();
  }
}
