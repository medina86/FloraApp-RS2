import 'package:flutter/material.dart';

class FlowerQuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final bool isUpdating;

  const FlowerQuantityControl({
    super.key,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    this.isUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: isUpdating ? null : onDecrease,
              child: Container(
                width: 32,
                height: 32,
                child: const Icon(Icons.remove, size: 16, color: Colors.grey),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$quantity',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: isUpdating ? null : onIncrease,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 170, 46, 92),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
