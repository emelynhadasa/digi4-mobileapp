import 'dart:convert';
import 'package:digi4_mobile/models/instance_model.dart';
import 'package:digi4_mobile/utils/token.dart';
import 'package:http/http.dart' as http;
import 'package:digi4_mobile/config/constant.dart';
import 'package:digi4_mobile/models/repair_request_model.dart';

class RepairService {
  Future<List<RepairRequestModel>> getRepairRequests() async {
    try {
      String? token = await Token.getToken();

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
      };

      final response = await http.get(
        Uri.parse(Constant.repairRequestUrl),
        headers: headers,
      );

      print('response code : ${response.statusCode}');
      print('response body : ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => RepairRequestModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load repair requests');
      }
    } catch (e) {
      throw Exception('Failed to load repair requests: $e');
    }
  }

  Future<List<InstanceModel>> getInstancesByAssetId(int assetId) async {
    try {
      String? token = await Token.getToken();

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('${Constant.repairRequestInstancesUrl}?assetId=$assetId'),
        headers: headers,
      );

      print('Get instances response code: ${response.statusCode}');
      print('Get instances response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => InstanceModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load instances');
      }
    } catch (e) {
      throw Exception('Failed to load instances: $e');
    }
  }

  Future<Map<String, dynamic>> createRepairRequest({
    required int instanceId,
    required String remarks,
    String? repairImageBase64,
  }) async {
    try {
      String? token = await Token.getToken();

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
      };

      final body = {
        'InstanceId': instanceId,
        'Remarks': remarks,
        if (repairImageBase64 != null && repairImageBase64.isNotEmpty)
          'RepairImageBase64': repairImageBase64,
      };

      print('Creating repair request with body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse(Constant.repairRequestUrl),
        headers: headers,
        body: json.encode(body),
      );

      print('Create repair response code: ${response.statusCode}');
      print('Create repair response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to create repair request',
        );
      }
    } catch (e) {
      throw Exception('Failed to create repair request: $e');
    }
  }

  Future<Map<String, dynamic>> startRepairRequest(int repairRequestId) async {
    try {
      String? token = await Token.getToken();

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
      };

      final response = await http.post(
        Uri.parse('${Constant.baseUrl}/repair-requests/$repairRequestId/start'),
        headers: headers,
      );

      print('Start repair response code: ${response.statusCode}');
      print('Start repair response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to start repair request',
        );
      }
    } catch (e) {
      throw Exception('Failed to start repair request: $e');
    }
  }

  Future<Map<String, dynamic>> markRepairAsUnfixable(
    int repairRequestId,
  ) async {
    try {
      String? token = await Token.getToken();

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
      };

      final response = await http.post(
        Uri.parse(
          '${Constant.baseUrl}/repair-requests/$repairRequestId/unfixable',
        ),
        headers: headers,
      );

      print('Mark unfixable response code: ${response.statusCode}');
      print('Mark unfixable response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to mark repair as unfixable',
        );
      }
    } catch (e) {
      throw Exception('Failed to mark repair as unfixable: $e');
    }
  }

  Future<Map<String, dynamic>> finishRepairRequest(int repairRequestId) async {
    try {
      String? token = await Token.getToken();

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
      };

      final response = await http.post(
        Uri.parse(
          '${Constant.baseUrl}/repair-requests/$repairRequestId/finish',
        ),
        headers: headers,
      );

      print('Finish repair response code: ${response.statusCode}');
      print('Finish repair response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to finish repair request',
        );
      }
    } catch (e) {
      throw Exception('Failed to finish repair request: $e');
    }
  }
}
