import 'package:flora_mobile_app/models/donation.dart';
import 'package:flora_mobile_app/models/donation_campaign.dart';
import 'package:flutter/material.dart';
import 'package:flora_mobile_app/providers/donation_api.dart';
import 'package:flora_mobile_app/screens/donation_confirmation_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  bool _isLoading = true;
  String? _paymentStatus;
  String? _approvalUrl;
  String? _paymentId;
  int? _donationId;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _initiatePayment();
  }

  Future<void> _initiatePayment() async {
    try {
      print('--- PayPal Donation Initiation (WebView) ---');
      print('  Campaign ID: ${widget.campaign.id}');
      print('  User ID: ${widget.userId}');
      print('  Amount: ${widget.amount}');

      // Prvo kreiraj donaciju
      final donationResponse = await DonationApiService.makeDonation(
        Donation(
          donorName: 'PayPal Donor',
          email: 'donor@example.com',
          amount: widget.amount,
          purpose: 'Donation to ${widget.campaign.title}',
          campaignId: widget.campaign.id,
          userId: widget.userId,
          status: 'Pending',
        ),
      );

      _donationId = donationResponse.id;
      print('  Created donation ID: $_donationId');

      // Zatim inicijalizuj PayPal sa donation ID
      final payPalResponse = await DonationApiService.initiatePayPalDonation2(
        donationId: _donationId!,
        amount: widget.amount,
        currency: 'USD',
        returnUrl: 'floraapp://paypal/donation/success',
        cancelUrl: 'floraapp://paypal/donation/cancel',
      );

      print('Received PayPal response:');
      print('  Approval URL: ${payPalResponse.approvalUrl}');
      print('  Payment ID: ${payPalResponse.paymentId}');

      setState(() {
        _approvalUrl = payPalResponse.approvalUrl;
        _paymentId = payPalResponse.paymentId;
        _isLoading = false;
      });

      // Setup WebView controller
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              print('Page started loading: $url');
              _handleNavigation(url);
            },
            onNavigationRequest: (NavigationRequest request) {
              print('Navigation request: ${request.url}');
              if (_handleNavigation(request.url)) {
                return NavigationDecision.prevent; // Sprečava navigaciju
              }
              return NavigationDecision.navigate; // Dozvoli navigaciju
            },
          ),
        )
        ..loadRequest(Uri.parse(_approvalUrl!));
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

  bool _handleNavigation(String url) {
    if (url.startsWith('floraapp://paypal/donation/success')) {
      print('PayPal donation success detected!');
      _confirmPayment();
      return true; // Prevent WebView navigation
    } else if (url.startsWith('floraapp://paypal/donation/cancel')) {
      print('PayPal donation cancel detected!');
      _showPaymentResultDialog(
        'Donation Cancelled',
        'You cancelled the PayPal donation.',
      );
      return true; // Prevent WebView navigation
    }
    return false; // Allow WebView navigation
  }

  Future<void> _confirmPayment() async {
    if (_paymentId == null || _donationId == null) {
      _showPaymentResultDialog(
        'Payment Error',
        'Payment ID or Donation ID not available. Please try again.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await DonationApiService.confirmPayPalDonation2(
        donationId: _donationId!,
        paymentId: _paymentId!,
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
      print('Error confirming donation: $e');
      setState(() {
        _paymentStatus = 'failed';
      });
      _showPaymentResultDialog(
        'Payment Confirmation Failed',
        'Could not confirm your donation: $e',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'PayPal Donation',
          style: TextStyle(
            color: Color.fromARGB(255, 170, 46, 92),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color.fromARGB(255, 170, 46, 92),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading PayPal...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : _approvalUrl != null
          ? Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.green[50],
                  child: Row(
                    children: [
                      const Icon(Icons.security, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Secure PayPal Donation - ${widget.amount.toStringAsFixed(2)} USD to ${widget.campaign.title}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: WebViewWidget(controller: _webViewController)),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load PayPal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please try again later',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 170, 46, 92),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Back to Donations'),
                  ),
                ],
              ),
            ),
    );
  }
}
