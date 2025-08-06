import 'dart:convert';

class AuthProvider {
  static String? username;
  static String? password;
  static int? roleId;
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
  
  // Provjera je li korisnik admin - može biti bazirana na roleId ili listi roles
  static bool get isAdmin {
    // Provjera po roleId
    if (roleId == 1) return true;
    
    return roles.any((role) => role['id'] == 1);
  }

  static void logout() {
    username = null;
    password = null;
    roleId = null;
    roles = [];
  }

  static void setCredentials(String user, String pass) {
    username = user;
    password = pass;
  }
  
  // Metod za postavljanje svih podataka o korisniku
  static void setUserData(String user, String pass, int? role) {
    username = user;
    password = pass;
    roleId = role;
  }
  
  // Dodatni metod za postavljanje uloga korisnika
  static void setRoles(List<Map<String, dynamic>> userRoles) {
    roles = userRoles;
  }
}
