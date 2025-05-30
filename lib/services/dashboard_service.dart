import 'dart:convert';

import 'package:digi4_mobile/config/constant.dart';
import 'package:digi4_mobile/models/dashboard_model.dart';
import 'package:digi4_mobile/utils/token.dart';
import 'package:http/http.dart' as http;

class DashboardService {
  Future<DashboardModel> getDashboard() async {
    try {
      String? token = await Token.getToken();

      final headers = {...Constant.header, 'Authorization': 'Bearer $token'};

      final response = await http.get(
        Uri.parse(Constant.dashboardUrl),
        headers: headers,
      );
      print('response code : ${response.statusCode}');
      print('response body : ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return DashboardModel.fromJson(responseData);
      } else {
        throw Exception('Failed to load dashboard');
      }
    } catch (e) {
      throw Exception('Failed to load dashboard : $e');
    }
  }
}
