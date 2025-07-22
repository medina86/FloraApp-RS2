import 'package:flutter/material.dart';

class FAQDialog extends StatelessWidget {
  const FAQDialog({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showDialog(context: context, builder: (context) => const FAQDialog());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("FAQ"),
      content: const Text(
        "Here you can find answers to frequently asked questions.",
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
