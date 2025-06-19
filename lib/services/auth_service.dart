import 'dart:convert';

import 'package:digi4_mobile/config/constant.dart';
import 'package:digi4_mobile/models/user_model.dart';
import 'package:digi4_mobile/utils/token.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Constant.loginUrl),
        body: {'Email': email, 'Password': password},
        headers: Constant.header,
      );

      print('response code : ${response.statusCode}');
      print('response body : ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        await Token.setToken(responseData['token']);
        return UserModel.fromJson(responseData);
      } else {
        throw Exception('Failed to login, check your email and password');
      }
    } catch (e) {
      throw Exception('Failed to login : $e');
    }
  }

  Future<void> register(
    String email,
    String password,
    String confirmPassword,
    String name,
    String kpk,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(Constant.registerUrl),
        body: {
          'Email': email,
          'Password': password,
          'ConfirmPassword': confirmPassword,
          'Name': name,
          'Kpk': kpk,
        },
        headers: Constant.header,
      );
      print('response code : ${response.statusCode}');
      print('response body : ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('user')) {
          return;
        } else {
          throw Exception('Failed to register ');
        }
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        throw Exception(
          'Failed to register : ${responseData['ModelState']['model.Password']}',
        );
      }
    } catch (e) {
      throw Exception('Failed to register : $e');
    }
  }

  Future<void> logout() async {
    final token = await Token.getToken();
    final headers = {
      ...Constant.header,
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse('${Constant.baseUrl}/logoff'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Logout failed: ${response.statusCode}');
    }
    // Kalau perlu, hapus token dari storage setelah logout berhasil
    await Token.clearToken();
  }
}
