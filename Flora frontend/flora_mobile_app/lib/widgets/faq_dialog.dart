import 'package:flutter/material.dart';

class FAQDialog extends StatelessWidget {
  const FAQDialog({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showDialog(context: context, builder: (context) => const FAQDialog());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Frequently Asked Questions"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: const [
            _FAQItem(
              question: "How can I place an order?",
              answer: "You can browse our products, add them to your cart, and proceed to checkout. You'll need to create an account first.",
            ),
            _FAQItem(
              question: "What are your delivery options?",
              answer: "We offer delivery within Sarajevo and surrounding areas. Delivery times are typically 2-4 hours during business hours.",
            ),
            _FAQItem(
              question: "How do I care for my flowers?",
              answer: "Keep flowers in fresh, cool water. Change the water every 2-3 days and trim the stems at an angle. Keep away from direct sunlight and heat sources.",
            ),
            _FAQItem(
              question: "Can I customize my bouquet?",
              answer: "Yes! We offer custom bouquet services. You can choose your preferred flowers, colors, and arrangement style through our app.",
            ),
            _FAQItem(
              question: "Do you offer event decorations?",
              answer: "Yes, we provide decoration services for weddings, birthdays, corporate events, and other special occasions. Contact us for a consultation.",
            ),
            _FAQItem(
              question: "What if I'm not satisfied with my order?",
              answer: "We guarantee fresh, quality flowers. If you're not satisfied, please contact us within 24 hours of delivery for a replacement or refund.",
            ),
            _FAQItem(
              question: "How can I track my order?",
              answer: "Once your order is placed, you can track its status in the 'My Orders' section of your account.",
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.question,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFFE91E63),
              ),
            ),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: const Color(0xFFE91E63),
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: TextStyle(
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
