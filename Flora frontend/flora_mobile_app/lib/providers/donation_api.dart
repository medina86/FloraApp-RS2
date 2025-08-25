import 'package:flora_mobile_app/models/donation.dart';
import 'package:flora_mobile_app/models/donation_campaign.dart';
import 'package:flora_mobile_app/models/paypal_donation_model.dart';
import 'package:flora_mobile_app/providers/base_provider.dart';

class DonationApiService {
  static Future<List<DonationCampaign>> getActiveCampaigns() async {
    return await BaseApiService.get('/DonationCampaign', (data) {
      if (data is Map<String, dynamic>) {
        final list = data['items'] ?? data['result'] ?? data['data'] ?? [];
        return (list as List)
            .map((item) => DonationCampaign.fromJson(item))
            .toList();
      } else if (data is List) {
        return data.map((item) => DonationCampaign.fromJson(item)).toList();
      }
      return <DonationCampaign>[];
    });
  }

  static Future<DonationCampaign> getCampaignById(int id) async {
    return await BaseApiService.get<DonationCampaign>(
      '/DonationCampaign/$id',
      (data) => DonationCampaign.fromJson(data),
    );
  }

  static Future<Donation> makeDonation(Donation donation) async {
    return await BaseApiService.post<Donation>(
      '/Donation',
      donation.toJson(),
      (data) => Donation.fromJson(data),
    );
  }

  static Future<List<Donation>> getUserDonations(int userId) async {
    return await BaseApiService.get<List<Donation>>(
      '/Donation/user/$userId',
      (data) => (data as List).map((item) => Donation.fromJson(item)).toList(),
    );
  }

  static Future<Donation> updateDonation(int id, Donation donation) async {
    return await BaseApiService.put<Donation>(
      '/Donation/$id',
      donation.toJson(),
      (data) => Donation.fromJson(data),
    );
  }

  // PayPal donacijske metode
  static Future<PayPalDonationResponse> initiatePayPalDonation({
    required int campaignId,
    required int userId,
    required double amount,
    required String returnUrl,
    required String cancelUrl,
    String status = 'Pending',
    String? transactionId,
  }) async {
    final request = PayPalDonationRequest(
      userId: userId,
      campaignId: campaignId,
      amount: amount,
      returnUrl: returnUrl,
      cancelUrl: cancelUrl,
      status: status,
      transactionId: transactionId,
    );

    return await BaseApiService.post<PayPalDonationResponse>(
      '/Donation/initiate-paypal',
      request.toJson(),
      (data) => PayPalDonationResponse.fromJson(data),
    );
  }

  static Future<Donation> confirmPayPalDonation({
    required int donationId,
    required String paymentId,
    String? status,
  }) async {
    // Detaljniji logging za debugging
    print(
      'Calling confirmPayPalDonation with donationId=$donationId, paymentId=$paymentId',
    );

    // Probajmo drugi pristup - eksplicitno uključi parametre i u URL i u body
    try {
      // Pokušaj 1: Koristimo query parametre
      final endpoint =
          '/Donation/confirm-paypal?donationId=$donationId&paymentId=$paymentId';
      print('Attempt 1: Using endpoint URL: $endpoint');

      return await BaseApiService.post<Donation>(endpoint, {
        'donationId': donationId,
        'paymentId': paymentId,
        'status': status ?? 'Completed',
      }, (data) => Donation.fromJson(data));
    } catch (e) {
      print('First attempt failed: $e');

      // Pokušaj 2: Koristimo samo body
      final endpoint = '/Donation/confirm-paypal';
      print('Attempt 2: Using endpoint URL: $endpoint');

      return await BaseApiService.post<Donation>(endpoint, {
        'donationId': donationId,
        'paymentId': paymentId,
        'status': status ?? 'Completed',
      }, (data) => Donation.fromJson(data));
    }
  }

  // Nova metoda - kao kod narudžbi (2-step process)
  static Future<PayPalDonationResponse2> initiatePayPalDonation2({
    required int donationId,
    required double amount,
    required String currency,
    required String returnUrl,
    required String cancelUrl,
  }) async {
    final request = {
      'donationId': donationId,
      'amount': amount,
      'currency': currency,
      'returnUrl': returnUrl,
      'cancelUrl': cancelUrl,
    };

    return await BaseApiService.post<PayPalDonationResponse2>(
      '/Donation/initiatePayPalDonation',
      request,
      (data) => PayPalDonationResponse2.fromJson(data),
    );
  }

  static Future<Donation> confirmPayPalDonation2({
    required int donationId,
    required String paymentId,
  }) async {
    final endpoint =
        '/Donation/confirm-paypal-donation?donationId=$donationId&paymentId=$paymentId';

    return await BaseApiService.post<Donation>(
      endpoint,
      {},
      (data) => Donation.fromJson(data),
    );
  }
}
