import 'dart:convert';

class AuthProvider {
  static String? username;
  static String? password;

  static Map<String, String> getHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (username != null && password != null) {
      final credentials = base64Encode(utf8.encode('$username:$password'));
      headers['Authorization'] = 'Basic $credentials';
    }

    return headers;
  }
}
