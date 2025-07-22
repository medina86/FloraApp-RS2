import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flora_mobile_app/layouts/constants.dart';
import 'package:flora_mobile_app/models/user_model.dart';
import 'package:flora_mobile_app/providers/auth_provider.dart';
import 'package:flora_mobile_app/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Load user by ID (async method)
  Future<UserModel?> loadUser(int userId) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final user = await BaseApiService.get(
        '/Users/$userId', 
        (data) => UserModel.fromJson(data)
      );
      
      _currentUser = user;
      return user;
    } catch (e) {
      _setError('Failed to load user: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Get user by ID (sync method - returns current cached user)
  UserModel? getUserById(int userId) {
    return _currentUser?.id == userId ? _currentUser : null;
  }

  // Upload profile image
  Future<String?> uploadProfileImage(int userId, String imagePath) async {
    try {
      _setLoading(true);
      _setError(null);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/Users/$userId/upload-image'),
      );

      // Add auth headers if authenticated
      if (AuthProvider.isAuthenticated) {
        request.headers.addAll(AuthProvider.getHeaders());
      }

      // Add image file
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      final response = await request.send();

      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final data = json.decode(res.body);
        final imageUrl = data['imageUrl'] as String;
        
        // Update current user's image if it exists
        if (_currentUser != null) {
          // Assuming UserModel has an imageUrl property
          _currentUser = _currentUser!.copyWith(profileImageUrl: imageUrl);
          notifyListeners();
        }
        
        return imageUrl;
      } else {
        throw ApiException('Image upload failed', response.statusCode);
      }
    } catch (e) {
      _setError('Failed to upload image: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update user data
  void updateUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  // Clear user data
  void clearUser() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  // Refresh current user
  Future<void> refreshCurrentUser() async {
    if (_currentUser?.id != null) {
      await loadUser(_currentUser!.id);
    }
  }
}