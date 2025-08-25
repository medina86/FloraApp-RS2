import 'package:flora_desktop_app/providers/base_provider.dart';
import '../models/donation_model.dart';

class DonationApiService {
  static Future<List<Donation>> getAllDonations() async {
    return await BaseApiService.get<List<Donation>>(
      '/Donation',
      (data) {
        if (data is Map<String, dynamic>) {
          final list = data['items'] ?? data['result'] ?? data['data'] ?? [];
          return (list as List)
              .map((item) => Donation.fromJson(item))
              .toList();
        } else if (data is List) {
          return data.map((item) => Donation.fromJson(item)).toList();
        }
        return <Donation>[];
      },
    );
  }

  static Future<List<Donation>> getDonationsByCampaign(int campaignId) async {
    return await BaseApiService.getWithParams<List<Donation>>(
      '/Donation',
      {'campaignId': campaignId.toString()},
      (data) {
        if (data is Map<String, dynamic>) {
          final list = data['items'] ?? data['result'] ?? data['data'] ?? [];
          return (list as List)
              .map((item) => Donation.fromJson(item))
              .toList();
        } else if (data is List) {
          return data.map((item) => Donation.fromJson(item)).toList();
        }
        return <Donation>[];
      },
    );
  }

  static Future<Donation> createDonation(Donation donation) async {
    return await BaseApiService.post<Donation>(
      '/Donation',
      donation.toJson(),
      (data) => Donation.fromJson(data),
    );
  }

  static Future<Donation> updateDonation(int id, Donation donation) async {
    return await BaseApiService.put<Donation>(
      '/Donation/$id',
      donation.toJson(),
      (data) => Donation.fromJson(data),
    );
  }

  static Future<bool> deleteDonation(int id) async {
    return await BaseApiService.delete('/Donation/$id');
  }
}
