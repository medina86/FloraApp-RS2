import 'dart:convert';

class AuthProvider {
  static String? username;
  static String? password;
  static int? roleId;
  static int? userId;
  static List<Map<String, dynamic>> roles = [];

  static Map<String, String> getHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (username != null && password != null) {
      final credentials = base64Encode(utf8.encode('$username:$password'));
      headers['Authorization'] = 'Basic $credentials';
      print('Debug - Auth Headers: ${headers['Authorization']}');
    } else {
      print('Debug - No credentials set in AuthProvider');
    }

    return headers;
  }

  static bool get isAuthenticated => username != null && password != null;

  static bool get isAdmin {
    if (roleId == 1) return true;

    return roles.any((role) => role['id'] == 1);
  }

  static void logout() {
    username = null;
    password = null;
    roleId = null;
    userId = null;
    roles = [];
  }

  static void setCredentials(String user, String pass) {
    username = user;
    password = pass;
  }

  static void setUserData(String user, String pass, int? role, int? id) {
    username = user;
    password = pass;
    roleId = role;
    userId = id;
  }

  static void setRoles(List<Map<String, dynamic>> userRoles) {
    roles = userRoles;
  }
}
