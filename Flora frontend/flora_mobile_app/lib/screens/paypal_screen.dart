import 'package:flora_mobile_app/models/order.dart';
import 'package:flutter/material.dart';
import 'package:flora_mobile_app/providers/order_api.dart';
import 'package:flora_mobile_app/layouts/main_layout.dart';
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/screens/order_confirmation_screen.dart';

class PayPalPaymentScreen extends StatefulWidget {
  final OrderModel order;

  const PayPalPaymentScreen({super.key, required this.order});

  @override
  State<PayPalPaymentScreen> createState() => _PayPalPaymentScreenState();
}

class _PayPalPaymentScreenState extends State<PayPalPaymentScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = true;
  String? _paymentStatus;
  String? _simulatedPaymentId; // Čuvamo simulirani paymentId
  
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
      final String returnUrl = '${baseUrl}/Order/confirm-paypal-payment'; 
      final String cancelUrl = '${baseUrl}/Order/cancelPayment'; 

      print('--- PayPal Payment Initiation (Flutter UI) ---');
      print('  Order ID: ${widget.order.id}');
      print('  Amount: ${widget.order.totalAmount}');
      print('  Return URL sent to backend: $returnUrl');
      print('  Cancel URL sent to backend: $cancelUrl');

      final payPalResponse = await OrderApiService.initiatePayPalPayment(
        orderId: widget.order.id,
        amount: widget.order.totalAmount,
        currency: 'USD',
        returnUrl: returnUrl,
        cancelUrl: cancelUrl,
      );

      print('Received PayPal response from backend:');
      print('  Approval URL (contains params): ${payPalResponse.approvalUrl}');
      print('  Payment ID (simulated): ${payPalResponse.paymentId}');
      print('---------------------------------');

      // Parsiramo orderId i paymentId iz approvalUrl-a
      final uri = Uri.parse(payPalResponse.approvalUrl);
      final receivedOrderId = uri.queryParameters['orderId'];
      final receivedPaymentId = uri.queryParameters['paymentId'];

      if (receivedOrderId != null && receivedPaymentId != null) {
        setState(() {
          _simulatedPaymentId = receivedPaymentId; // Sačuvaj paymentId
          _isLoading = false; // UI je spreman
        });
      } else {
        throw Exception('Missing order or payment ID from backend response.');
      }

    } catch (e) {
      print('Error initiating PayPal payment: $e');
      setState(() {
        _paymentStatus = 'failed';
        _isLoading = false;
      });
      _showPaymentResultDialog('Payment Error', 'Could not initiate PayPal payment: $e');
    }
  }

  Future<void> _confirmPayment() async {
    if (_simulatedPaymentId == null) {
      _showPaymentResultDialog('Payment Error', 'Payment ID not available. Please try again.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulacija kašnjenja za "Log In"
      await Future.delayed(const Duration(seconds: 2)); 

      final confirmedOrder = await OrderApiService.confirmPayPalPayment(
        orderId: widget.order.id,
        paymentId: _simulatedPaymentId!,
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
      print('Error confirming payment on backend: $e');
      setState(() {
        _paymentStatus = 'failed';
      });
      _showPaymentResultDialog('Payment Confirmation Failed', 'Could not confirm your payment with the server: $e');
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
                  Navigator.of(context).pop(); // Vrati se nazad na checkout
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
          icon: const Icon(Icons.menu, color: Color.fromARGB(255, 170, 46, 92)),
          onPressed: () {},
        ),
        title: const Text(
          'Flora',
          style: TextStyle(
            color: Color.fromARGB(255, 170, 46, 92),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
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
                  const Text(
                    'Cart >> Check out >> Payment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 170, 46, 92),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pay with PayPal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.order.totalAmount.toStringAsFixed(2)} KM',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    'Cost',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  Center(
                    child: Image.network(
                      'https://www.paypalobjects.com/digitalassets/c/website/marketing/na/us/logos-and-badges/pp_cc_mark_74x46.jpg', // PayPal logo URL
                      height: 50,
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
                          const SnackBar(content: Text('Forgot password functionality not implemented.')),
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
                      onPressed: _isLoading ? null : _confirmPayment, // "Log In" dugme pokreće potvrdu
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 112, 186), // PayPal plava
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
                      onPressed: _isLoading ? null : _confirmPayment, // "DONE" dugme takođe pokreće potvrdu
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 102, 204), // Pink boja
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
                              'DONE',
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 170, 46, 92),
        selectedItemColor: const Color.fromARGB(255, 255, 210, 233),
        unselectedItemColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        currentIndex: 3, // Pretpostavljamo da je ovo tab za korpu
        onTap: (index) {
          // Implementiraj navigaciju za donji bar ako je potrebno
          // Trenutno, samo se vraća na prethodni ekran ako se klikne na Cart tab
          if (index == 3) { // Ako je Cart tab
            MainLayout.of(context)?.openCartTab();
            Navigator.of(context).pop(); // Vrati se sa Checkout ekrana
          } else {
            // Implementiraj navigaciju za ostale tabove
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigation to tab $index not implemented.')),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Shop"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }
}
