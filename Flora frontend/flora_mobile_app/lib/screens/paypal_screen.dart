import 'package:flora_mobile_app/models/order.dart';
import 'package:flora_mobile_app/models/shipping_model.dart';
import 'package:flutter/material.dart';
import 'package:flora_mobile_app/providers/order_api.dart';
import 'package:flora_mobile_app/screens/order_confirmation_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayPalPaymentScreen extends StatefulWidget {
  // Originalni konstruktor koji prima OrderModel
  final OrderModel? order;
  
  // Novi konstruktor koji prima podatke potrebne za novi tok plaćanja
  final int? userId;
  final int? cartId;
  final ShippingAddressModel? shippingAddress;
  final String? approvalUrl;
  final String? paymentId;
  final double? totalAmount;
  final bool isNewFlow;

  const PayPalPaymentScreen({
    super.key, 
    this.order,
    this.userId,
    this.cartId,
    this.shippingAddress,
    this.approvalUrl,
    this.paymentId,
    this.totalAmount,
  }) : isNewFlow = order == null;

  @override
  State<PayPalPaymentScreen> createState() => _PayPalPaymentScreenState();
}

class _PayPalPaymentScreenState extends State<PayPalPaymentScreen> {
  bool _isLoading = true;
  String? _paymentStatus;
  String? _approvalUrl;
  String? _paymentId;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    if (widget.isNewFlow) {
      _setupPayPalWebViewForNewFlow();
    } else {
      _initiatePayment();
    }
  }

  // Originalna metoda za stari tok plaćanja
  Future<void> _initiatePayment() async {
    try {
      print('--- PayPal Payment Initiation ---');
      print('  Order ID: ${widget.order!.id}');
      print('  Amount: ${widget.order!.totalAmount}');

      final payPalResponse = await OrderApiService.initiatePayPalPayment(
        orderId: widget.order!.id,
        amount: widget.order!.totalAmount,
        currency: 'USD',
        returnUrl: 'floraapp://paypal/success', // App će uhvatiti ovo
        cancelUrl: 'floraapp://paypal/cancel',
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
      print('Error initiating PayPal payment: $e');
      setState(() {
        _paymentStatus = 'failed';
        _isLoading = false;
      });
      _showPaymentResultDialog(
        'Payment Error',
        'Could not initiate PayPal payment: $e',
      );
    }
  }

  // Nova metoda za novi tok plaćanja
  void _setupPayPalWebViewForNewFlow() {
    setState(() {
      _approvalUrl = widget.approvalUrl;
      _paymentId = widget.paymentId;
    });

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
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_approvalUrl!));
  }

  bool _handleNavigation(String url) {
    if (url.startsWith('floraapp://paypal/success')) {
      print('PayPal success detected!');
      
      // Ekstraktiramo PayerID iz URL-a
      Uri uri = Uri.parse(url);
      String? payerId = uri.queryParameters['PayerID'];
      
      if (payerId != null) {
        if (widget.isNewFlow) {
          _confirmPaymentNewFlow(payerId);
        } else {
          _confirmPayment();
        }
      } else {
        _showPaymentResultDialog(
          'Payment Error',
          'Could not extract PayerID from the response.',
        );
      }
      return true;
    } else if (url.startsWith('floraapp://paypal/cancel')) {
      print('PayPal cancel detected!');
      _showPaymentResultDialog(
        'Payment Cancelled',
        'You cancelled the PayPal payment.',
      );
      return true;
    }
    return false;
  }

  // Originalna metoda za stari tok plaćanja
  Future<void> _confirmPayment() async {
    if (_paymentId == null) {
      _showPaymentResultDialog(
        'Payment Error',
        'Payment ID not available. Please try again.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final confirmedOrder = await OrderApiService.confirmPayPalPayment(
        orderId: widget.order!.id,
        paymentId: _paymentId!,
      );

      setState(() {
        _paymentStatus = 'success';
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                OrderConfirmationScreen(order: confirmedOrder),
          ),
        );
      }
    } catch (e) {
      print('Error confirming payment: $e');
      setState(() {
        _paymentStatus = 'failed';
      });
      _showPaymentResultDialog(
        'Payment Confirmation Failed',
        'Could not confirm your payment: $e',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Nova metoda za novi tok plaćanja
  Future<void> _confirmPaymentNewFlow(String payerId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Koristimo REST API za potvrdu PayPal plaćanja i kreiranje narudžbe
      final confirmedOrder = await OrderApiService.confirmPayPalPaymentAndCreateOrderRest(
        userId: widget.userId!,
        cartId: widget.cartId!,
        shippingAddress: widget.shippingAddress!,
        orderId: _paymentId!, // Koristimo paymentId kao orderId
      );

      setState(() {
        _paymentStatus = 'success';
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OrderConfirmationScreen(order: confirmedOrder),
          ),
        );
      }
    } catch (e) {
      print('Error confirming payment: $e');
      setState(() {
        _paymentStatus = 'failed';
      });
      _showPaymentResultDialog(
        'Payment Confirmation Failed',
        'Could not confirm your payment: $e',
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
          'PayPal Payment',
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
                  color: Colors.blue[50],
                  child: Row(
                    children: [
                      const Icon(Icons.security, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Secure PayPal Payment - ${widget.isNewFlow ? widget.totalAmount!.toStringAsFixed(2) : widget.order!.totalAmount.toStringAsFixed(2)} KM',
                          style: const TextStyle(
                            color: Colors.blue,
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
                    child: const Text('Back to Cart'),
                  ),
                ],
              ),
            ),
    );
  }
}