// home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final int userId;
  const HomeScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PRVI POGLED
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Image.asset("assets/images/flowers.jpg", fit: BoxFit.cover),
                const SizedBox(height: 10),
                const Text(
                  "Pink Elegance",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA53583),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA53583),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text("Shop now"),
                ),
              ],
            ),
          ),

          const Divider(),

          // DRUGI POGLED – dummy
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Browse by Category",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA53583),
                  ),
                ),
                SizedBox(height: 10),
                // Dodaj ovdje horizontalni list, grid itd. kasnije
                Text("Ovde ide prikaz kategorija..."),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
