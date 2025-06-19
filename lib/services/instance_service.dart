// lib/services/instance_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:digi4_mobile/config/constant.dart';
import 'package:digi4_mobile/utils/token.dart';         // Pastikan ini path-nya benar
import 'package:digi4_mobile/models/instance_model.dart'; // Model untuk InstanceLog

class InstanceService {
  // 1) Mendapatkan token (jika memerlukan otentikasi)
  Future<String?> _getToken() async {
    // Misalnya kamu punya helper Token.getToken() yang menyimpan di shared preferences
    return await Token.getToken();
  }

  // 2) Fetch logs untuk satu instance (mengembalikan List<InstanceLog>)
  Future<List<InstanceLog>> fetchInstanceLogs(int instanceId) async {
    final token = await _getToken();

    // 3) Siapkan header, gabungkan Constant.header + Authorization
    final headers = {
      ...Constant.header,
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // 4) Bangun URI ke endpoint logs: /api/instances/{id}/logs
    final uri = Uri.parse('${Constant.assetInstanceUrl}/$instanceId/logs');

    // 5) Lakukan HTTP GET
    final response = await http.get(uri, headers: headers);

    // 6) Proses response
    if (response.statusCode == 200) {
      // Jika sukses, parse ke List<dynamic> lalu ke List<InstanceLog>
      final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
      return jsonList
          .map((item) => InstanceLog.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 404) {
      // Jika instance tidak ditemukan (404), kita return list kosong
      return [];
    } else {
      // Status code lain → lempar exception dengan detail
      throw Exception(
        'Failed to load logs: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
