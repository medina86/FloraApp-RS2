import 'dart:convert';
import '../models/user_model.dart';

class AuthProvider {
  static String? username;
  static String? password;
  static UserModel? _currentUser;

  static Map<String, String> getHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (username != null && password != null) {
      final credentials = base64Encode(utf8.encode('$username:$password'));
      headers['Authorization'] = 'Basic $credentials';
    }

    return headers;
  }

  static bool get isAuthenticated => username != null && password != null;

  static void logout() {
    username = null;
    password = null;
    _currentUser = null;
  }

  static void setCredentials(String user, String pass) {
    username = user;
    password = pass;
  }

  static UserModel? getUser() {
    return _currentUser;
  }

  static void setUser(UserModel user) {
    _currentUser = user;
  }
}
