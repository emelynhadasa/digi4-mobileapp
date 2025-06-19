import 'package:shared_preferences/shared_preferences.dart';

class Token {
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> clearToken() async { // diganti dari removeToken
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
