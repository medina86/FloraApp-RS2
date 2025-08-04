import 'package:flutter/material.dart';
import 'package:flora_mobile_app/models/donation_campaign.dart';
import 'package:flora_mobile_app/providers/donation_api.dart';
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/screens/donation_confirmation_screen.dart';

class PayPalDonationScreen extends StatefulWidget {
  final DonationCampaign campaign;
  final int userId;
  final double amount;

  const PayPalDonationScreen({
    Key? key,
    required this.campaign,
    required this.userId,
    required this.amount,
  }) : super(key: key);

  @override
  State<PayPalDonationScreen> createState() => _PayPalDonationScreenState();
}

class _PayPalDonationScreenState extends State<PayPalDonationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = true;
  String? _paymentStatus;
  String? _simulatedPaymentId;
  int? _donationId;

  @override
  void initState() {
    super.initState();
    _initiatePayment();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _initiatePayment() async {
    try {
      final String returnUrl = '${baseUrl}/Donation/confirm-paypal';
      final String cancelUrl = '${baseUrl}/Donation/cancelPayment';

      print('--- PayPal Donation Initiation (Flutter UI) ---');
      print('  Campaign ID: ${widget.campaign.id}');
      print('  User ID: ${widget.userId}');
      print('  Amount: ${widget.amount}');
      print('  Return URL sent to backend: $returnUrl');
      print('  Cancel URL sent to backend: $cancelUrl');

      final payPalResponse = await DonationApiService.initiatePayPalDonation(
        campaignId: widget.campaign.id,
        userId: widget.userId,
        amount: widget.amount,
        returnUrl: returnUrl,
        cancelUrl: cancelUrl,
      );

      final uri = Uri.parse(payPalResponse.paymentUrl);
      final receivedDonationId = uri.queryParameters['donationId'];
      final receivedPaymentId = uri.queryParameters['paymentId'];

      if (receivedDonationId != null && receivedPaymentId != null) {
        setState(() {
          _donationId = int.parse(receivedDonationId);
          _simulatedPaymentId = receivedPaymentId;
          _isLoading = false;
        });
      } else {
        throw Exception(
          'Missing donation or payment ID from backend response.',
        );
      }
    } catch (e) {
      print('Error initiating PayPal donation: $e');
      setState(() {
        _paymentStatus = 'failed';
        _isLoading = false;
      });
      _showPaymentResultDialog(
        'Payment Error',
        'Could not initiate PayPal donation: $e',
      );
    }
  }

  Future<void> _confirmPayment() async {
    if (_donationId == null || _simulatedPaymentId == null) {
      _showPaymentResultDialog(
        'Payment Error',
        'Donation or Payment ID not available. Please try again.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      // Ispišimo parametre za debugiranje
      print(
        'Sending confirmation: donationId=$_donationId, paymentId=$_simulatedPaymentId',
      );

      final confirmedDonation = await DonationApiService.confirmPayPalDonation(
        donationId: _donationId!,
        paymentId: _simulatedPaymentId!,
        status: 'Completed',
      );

      setState(() {
        _paymentStatus = 'success';
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DonationConfirmationScreen(
              campaign: widget.campaign,
              amount: widget.amount,
              userId: widget.userId,
              donationId: _donationId!,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error confirming donation on backend: $e');
      setState(() {
        _paymentStatus = 'failed';
        _isLoading = false;
      });
      _showPaymentResultDialog(
        'Payment Confirmation Failed',
        'Could not confirm your donation with the server: $e',
      );
    }
  }

  void _showPaymentResultDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (_paymentStatus != 'success') {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Donate with PayPal',
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Donation to: ${widget.campaign.title}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 170, 46, 92),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Donate with PayPal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.amount.toStringAsFixed(2)} KM',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    'Donation Amount',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  Center(
                    child: Image.network(
                      'https://via.placeholder.com/150x50/003087/FFFFFF?text=PayPal+Logo',
                      height: 50,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 50,
                          width: 150,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Text(
                              'PayPal Logo',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Pay with PayPal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email or mobile number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Forgot password functionality not implemented.',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot your password?',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _confirmPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 112, 186),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _confirmPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          255,
                          102,
                          204,
                        ),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'DONATE NOW',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
