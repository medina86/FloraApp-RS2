import 'package:flora_mobile_app/models/donation.dart';
import 'package:flora_mobile_app/models/donation_campaign.dart';
import 'package:flora_mobile_app/providers/base_provider.dart';

class DonationApiService {
  static Future<List<DonationCampaign>> getActiveCampaigns() async {
    return await BaseApiService.get(
      '/DonationCampaign',
      (data) {
        if (data is Map<String, dynamic>) {
          final list = data['items'] ?? data['result'] ?? data['data'] ?? [];
          return (list as List)
              .map((item) => DonationCampaign.fromJson(item))
              .toList();
        } else if (data is List) {
          return data.map((item) => DonationCampaign.fromJson(item)).toList();
        }
        return <DonationCampaign>[];
      },
    );
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
      (data) => (data as List)
          .map((item) => Donation.fromJson(item))
          .toList(),
    );
  }
}
