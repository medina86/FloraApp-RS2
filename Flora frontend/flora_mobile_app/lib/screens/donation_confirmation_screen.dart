import 'package:flutter/material.dart';
import 'package:flora_mobile_app/models/donation_campaign.dart';
import 'package:flora_mobile_app/layouts/main_layout.dart';
import 'dart:math';

class DonationConfirmationScreen extends StatelessWidget {
  final DonationCampaign campaign;
  final double amount;
  final int userId;
  final int donationId;

  const DonationConfirmationScreen({
    Key? key,
    required this.campaign,
    required this.amount,
    required this.userId,
    required this.donationId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String donationIdDisplay = donationId
        .toString()
        .substring(0, min(donationId.toString().length, 8))
        .toUpperCase();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 30),
              const Text(
                'Thank You for Your Donation!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 170, 46, 92),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Your donation #$donationIdDisplay has been successfully processed.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              Text(
                'Donation Amount: ${amount.toStringAsFixed(2)} KM',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Campaign: ${campaign.title}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
