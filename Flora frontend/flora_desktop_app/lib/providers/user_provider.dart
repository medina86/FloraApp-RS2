import 'package:flora_desktop_app/models/user_model.dart';
import 'package:flora_desktop_app/providers/base_provider.dart';

class UserApiService {
  // Dohvaća korisnika po ID-u
  static Future<UserModel> getUserById(int userId) async {
    try {
      print('API call: Fetching user with ID $userId');
      final user = await BaseApiService.get<UserModel>('/Users/$userId', (
        data,
      ) {
        print('API response for user $userId: $data');
        return UserModel.fromJson(data);
      });
      print('API success: Retrieved user ${user.firstName} ${user.lastName}');
      return user;
    } catch (e) {
      print('API error fetching user by ID $userId: $e');
      rethrow;
    }
  }

  static Future<UserModel> createAdminUser({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'username': username,
        'password': password,
        'phoneNumber': phoneNumber,
        'roleIds': [1], // Admin role ID
      };

      final user = await BaseApiService.post<UserModel>('/Users', requestBody, (
        data,
      ) {
        return UserModel.fromJson(data);
      });

      return user;
    } catch (e) {
      print('Error creating admin user: $e');
      rethrow;
    }
  }

  // Dohvaća sve korisnike
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final result = await BaseApiService.get<List<UserModel>>('/Users', (
        data,
      ) {
        final items = data['items'] as List<dynamic>;
        return items.map((json) => UserModel.fromJson(json)).toList();
      });
      return result;
    } catch (e) {
      print('Error fetching all users: $e');
      throw e;
    }
  }
  
}
