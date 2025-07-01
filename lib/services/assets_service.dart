import 'dart:convert';
import 'dart:io';
import 'package:digi4_mobile/config/constant.dart';
import 'package:digi4_mobile/models/assets_model.dart';
import 'package:http/http.dart' as http;
import 'package:digi4_mobile/utils/token.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class AssetsService {
  Future<Map<String, dynamic>> createAsset({
    required Map<String, dynamic> assetData,
    String? imagePath,
    String? documentPath,
  }) async {
    try {
      // Dapatkan token
      String? token = await Token.getToken();

      // Buat multipart request untuk mendukung upload file
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Constant.assetUrl),
      );

      request.headers.addAll({
        ...Constant.header,
        'Authorization': 'Bearer $token',
        // 'Content-Type': 'multipart/form-data',
      });

      final assetJson = jsonEncode(assetData);
      request.fields['asset'] = assetJson;

      // Tambahkan file gambar jika tersedia
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          final fileName = path.basename(file.path);
          final mimeType = _getMimeType(fileName);

          request.files.add(
            http.MultipartFile(
              'image',
              file.readAsBytes().asStream(),
              await file.length(),
              filename: fileName,
              contentType: mimeType,
            ),
          );
        }
      }

      // Kirim request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Create Asset response code: ${response.statusCode}');
      print('Create Asset response body: ${response.body}');

      // Process response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData;
      } else {
        throw Exception(
          'Failed to create asset: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error creating asset: $e');
    }
  }

  /// Method untuk mendapatkan MIME type berdasarkan ekstensi file
  MediaType _getMimeType(String fileName) {
    final ext = path.extension(fileName).toLowerCase();

    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      case '.pdf':
        return MediaType('application', 'pdf');
      case '.doc':
        return MediaType('application', 'msword');
      case '.docx':
        return MediaType(
          'application',
          'vnd.openxmlformats-officedocument.wordprocessingml.document',
        );
      case '.xls':
        return MediaType('application', 'vnd.ms-excel');
      case '.xlsx':
        return MediaType(
          'application',
          'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  Future<List<AssetsModel>> getAssets() async {
    try {
      String? token = await Token.getToken();
      final headers = {...Constant.header, 'Authorization': 'Bearer $token'};
      final response = await http.get(
        Uri.parse(Constant.assetUrl),
        headers: headers,
      );
      print('Get Assets response code: ${response.statusCode}');
      print('Get Assets response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData
            .map((asset) => AssetsModel.fromJson(asset))
            .toList();
      } else {
        throw Exception('Failed to fetch assets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching assets: $e');
    }
  }

  Future<AssetsModel> getAssetById(int assetId) async {
    try {
      String? token = await Token.getToken();
      final headers = {...Constant.header, 'Authorization': 'Bearer $token'};
      final response = await http.get(
        Uri.parse('${Constant.assetUrl}/$assetId'),
        headers: headers,
      );
      print('Get Asset by ID response code: ${response.statusCode}');
      print('Get Asset by ID response body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return AssetsModel.fromJson(responseData);
      } else {
        throw Exception('Failed to fetch asset by ID: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching asset by ID: $e');
    }
  }

  Future<void> updateAsset({
    required int assetId,
    required Map<String, dynamic> assetData,
    String? imagePath,
  }) async {
    final token = await Token.getToken();

    // Kalau ada gambar, pakai MultipartRequest
    if (imagePath != null && imagePath.isNotEmpty) {
      final uri = Uri.parse('${Constant.baseUrl}/assets/$assetId');
      final request = http.MultipartRequest('PUT', uri)
        ..headers.addAll({
          ...Constant.header,
          'Authorization': 'Bearer $token',
          // jangan atur Content-Type; MultipartRequest otomatis mengisi
        });

      // lampirkan field JSON
      request.fields['asset'] = jsonEncode(assetData);

      // lampirkan file gambar
      final file = File(imagePath);
      final fileName = path.basename(file.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          file.path,
          filename: fileName,
        ),
      );

      final streamed = await request.send();
      final resp     = await http.Response.fromStream(streamed);
      if (resp.statusCode != 204) {
        throw Exception('Failed updating asset (with image): '
            '${resp.statusCode} / ${resp.body}');
      }
    } else {
      // fallback JSON-only
      final resp = await http.put(
        Uri.parse('${Constant.baseUrl}/assets/$assetId'),
        headers: {
          ...Constant.header,
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(assetData),
      );
      if (resp.statusCode != 204) {
        throw Exception('Failed updating asset: '
            '${resp.statusCode} / ${resp.body}');
      }
    }
  }

  // Future<void> updateAsset({
  //   required int assetId,
  //   required Map<String, dynamic> assetData,
  // }) async {
  //   try {
  //     // Dapatkan token
  //     String? token = await Token.getToken();
  //
  //     final headers = <String, String>{
  //       ...Constant.header,
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     };
  //
  //     // Kirim data sebagai application/json
  //     final response = await http.put(
  //       Uri.parse('${Constant.baseUrl}/assets/$assetId'),
  //       //headers: Constant.header,
  //       headers: headers,
  //       body: jsonEncode(assetData),
  //     );
  //
  //     print('Update Asset URL: ${Constant.baseUrl}/api/assets/$assetId');
  //     print('Update Asset Headers: ${Constant.header}');
  //     print('Update Asset Body: ${jsonEncode(assetData)}');
  //     print('Update Asset response code: ${response.statusCode}');
  //     print('Update Asset response body: ${response.body}');
  //
  //     if (response.statusCode == 204) {
  //       return;
  //     } else {
  //       throw Exception(
  //         'Failed to update asset: ${response.statusCode} - ${response.body}',
  //       );
  //     }
  //   } catch (e) {
  //     throw Exception('Error updating asset: $e');
  //   }
  // }

  Future<void> uploadAssetImage({
    required int assetId,
    required String imagePath,
  }) async {
    try {
      String? token = await Token.getToken();

      // Buat multipart request khusus untuk upload gambar
      final request = http.MultipartRequest(
        'POST', // Biasanya POST untuk upload
        Uri.parse('${Constant.baseUrl}/api/assets/$assetId/image'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      final file = File(imagePath);
      final fileName = path.basename(file.path);

      request.files.add(
        http.MultipartFile(
          'image', // Sesuaikan dengan nama field yang diharapkan API
          file.readAsBytes().asStream(),
          await file.length(),
          filename: fileName,
          contentType: _getMimeType(fileName),
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Upload Image response code: ${response.statusCode}');
      print('Upload Image response body: $responseBody');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to upload image: ${response.statusCode} - $responseBody',
        );
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  Future<void> deleteAsset({required int assetId}) async {
    try {
      // Dapatkan token
      String? token = await Token.getToken();

      final headers = {...Constant.header, 'Authorization': 'Bearer $token'};

      // Kirim DELETE request
      final response = await http.delete(
        Uri.parse('${Constant.baseUrl}/assets/$assetId'),
        headers: headers,
      );

      print('Delete Asset URL: ${Constant.baseUrl}/api/assets/$assetId');
      print('Delete Asset Headers: $headers');
      print('Delete Asset response code: ${response.statusCode}');
      print('Delete Asset response body: ${response.body}');

      // Check response status
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Asset not found');
      } else {
        throw Exception(
          'Failed to delete asset: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error deleting asset: $e');
      throw Exception('Error deleting asset: $e');
    }
  }

  Future<List<AssetInstances>> searchAssets(String id) async {
    try {
      String? token = await Token.getToken();
      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('${Constant.assetUrl}/$id/instances'),
        headers: headers,
      );

      print('response code: ${response.statusCode}');
      print('response body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData
            .map((instance) => AssetInstances.fromJson(instance))
            .toList();
      } else if (response.statusCode == 404) {
        throw Exception('Asset not found');
      } else {
        throw Exception(
          'Failed to search assets: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error searching assets: $e');
    }
  }

  Future<void> createAssetInstance(Map<String, dynamic> instanceData) async {
    try {
      String? token = await Token.getToken();

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse(Constant.assetInstanceUrl),
        headers: headers,
        body: jsonEncode(instanceData),
      );

      print('Create Asset Instance response code: ${response.statusCode}');
      print('Create Asset Instance response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to create asset instance: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error creating asset instance: $e');
    }
  }

  Future<void> editAssetInstance({
    required int instanceId,
    required Map<String, dynamic> instanceData,
  }) async {
    try {
      String? token = await Token.getToken();

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.put(
        Uri.parse('${Constant.assetInstanceUrl}/$instanceId'),
        headers: headers,
        body: jsonEncode(instanceData),
      );

      print('Update Asset Instance response code: ${response.statusCode}');
      print('Update Asset Instance response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to update asset instance: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error updating asset instance: $e');
    }
  }

  Future<void> deleteAssetInstance(int instanceId) async {
    try {
      String? token = await Token.getToken();

      final headers = {...Constant.header, 'Authorization': 'Bearer $token'};

      final response = await http.delete(
        Uri.parse('${Constant.assetInstanceUrl}/$instanceId'),
        headers: headers,
      );

      print('Delete Asset Instance response code: ${response.statusCode}');
      print('Delete Asset Instance response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete asset instance: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error deleting asset instance: $e');
    }
  }

  Future<void> checkoutInstances(int id, Map<String, dynamic> jsonBody) async {
    try {
      String? token = await Token.getToken();

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse('${Constant.assetInstanceUrl}/$id/checkout'),
        headers: headers,
        body: jsonEncode(jsonBody),
      );

      print('Checkout Instances response code: ${response.statusCode}');
      print('Checkout Instances response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to checkout instances: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error checking out instances: $e');
    }
  }

  Future<void> checkinInstances(int id, Map<String, dynamic> jsonBody) async {
    try {
      String? token = await Token.getToken();

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse('${Constant.assetInstanceUrl}/$id/checkin'),
        headers: headers,
        body: jsonEncode(jsonBody),
      );

      print('Checkin Instances response code: ${response.statusCode}');
      print('Checkin Instances response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to checkin instances: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error checking in instances: $e');
    }
  }

  Future<void> markAsFound(int instanceId) async {
    try {
      String? token = await Token.getToken();

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse('${Constant.assetInstanceUrl}/$instanceId/mark-found'),
        headers: headers,
      );

      print('Mark as Found response code: ${response.statusCode}');
      print('Mark as Found response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to mark instance as found: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error marking instance as found: $e');
    }
  }

  Future<BulkResponse> getBulkInstance(String tab) async {
    try {
      String? token = await Token.getToken();

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('${Constant.bulkInstanceUrl}/instances/?tab=$tab'),
        headers: headers,
      );

      print(
        'Get Bulk Instance URL: ${Constant.bulkInstanceUrl}/instances/?tab=$tab',
      );
      print('Get Bulk Instance response code: ${response.statusCode}');
      print('Get Bulk Instance response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        print('Response data type: ${responseData.runtimeType}');
        print('Response data: $responseData');

        // PERBAIKAN: Handle both Map and List response formats
        if (responseData is Map<String, dynamic>) {
          // If response is Map (standard format)
          if (responseData.containsKey('data')) {
            return BulkResponse.fromJson(responseData);
          } else {
            // If Map but no 'data' key, treat whole response as data
            return BulkResponse(
              data: responseData.containsKey('instances')
                  ? (responseData['instances'] as List?)
                            ?.map((item) => BulkItems.fromJson(item))
                            .toList() ??
                        []
                  : [],
              message: responseData['message'] ?? 'Success',
              success: responseData['success'] ?? true,
            );
          }
        } else if (responseData is List) {
          // PERBAIKAN: If response is direct List
          print(
            'Parsing direct List response with ${responseData.length} items',
          );

          final bulkItemsList = responseData.map((item) {
            print('Processing item: $item');
            return BulkItems.fromJson(item as Map<String, dynamic>);
          }).toList();

          return BulkResponse(
            data: bulkItemsList,
            message: 'Success',
            success: true,
          );
        } else {
          throw Exception(
            'Unexpected response format: ${responseData.runtimeType}',
          );
        }
      } else if (response.statusCode == 404) {
        // Return empty data instead of throwing exception
        return BulkResponse(
          data: [],
          message: 'No instances found for $tab',
          success: true,
        );
      } else {
        throw Exception(
          'Failed to get bulk instance: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error getting bulk instance: $e');
      throw Exception('Error getting bulk instance: $e');
    }
  }

  // PERBAIKAN: Update bulkCheckin method dengan better error handling
  Future<Map<String, dynamic>> bulkCheckin(
    Map<String, dynamic> jsonBody,
  ) async {
    try {
      String? token = await Token.getToken();

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // PERBAIKAN: Handle new checkin format with Items and Condition
      Map<String, dynamic> requestBody;

      if (jsonBody.containsKey('Items')) {
        // New checkin format: Items with conditions
        requestBody = {
          'Items': jsonBody['Items'],
          'Remarks': jsonBody['Remarks'],
        };
      } else {
        // Legacy format: Convert to new format if needed
        requestBody = {
          'instanceIds': jsonBody['InstanceIds'],
          'destination': jsonBody['Destination'],
          'remarks': jsonBody['Remarks'],
        };
      }

      print('Bulk Checkin URL: ${Constant.bulkInstanceUrl}/checkin');
      print('Bulk Checkin Headers: $headers');
      print('Original body: ${jsonEncode(jsonBody)}');
      print('Formatted body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('${Constant.bulkInstanceUrl}/checkin'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('Bulk Checkin response code: ${response.statusCode}');
      print('Bulk Checkin response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          return {
            'success': true,
            'message':
                responseData['message'] ??
                'Bulk checkin completed successfully',
            'data': responseData,
          };
        } catch (e) {
          return {
            'success': true,
            'message': 'Bulk checkin completed successfully',
          };
        }
      } else {
        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          errorMessage =
              errorData['Message'] ??
              errorData['message'] ??
              errorData['error'] ??
              response.body;
        } catch (e) {
          errorMessage = response.body.isNotEmpty
              ? response.body
              : 'Unknown error occurred';
        }

        throw Exception(
          'Failed to bulk checkin: ${response.statusCode} - $errorMessage',
        );
      }
    } catch (e) {
      print('Error bulk checkin: $e');
      throw Exception('Error bulk checkin: $e');
    }
  }

  // PERBAIKAN: Update bulkCheckout method dengan better error handling
  Future<Map<String, dynamic>> bulkCheckout(
    Map<String, dynamic> jsonBody,
  ) async {
    try {
      String? token = await Token.getToken();

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      print('Bulk Checkout URL: ${Constant.bulkInstanceUrl}/checkout');
      print('Bulk Checkout Headers: $headers');
      print('Bulk Checkout Body: ${jsonEncode(jsonBody)}');

      final response = await http.post(
        Uri.parse('${Constant.bulkInstanceUrl}/checkout'),
        headers: headers,
        body: jsonEncode(jsonBody),
      );

      print('Bulk Checkout response code: ${response.statusCode}');
      print('Bulk Checkout response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          return responseData;
        } catch (e) {
          // If response body is not JSON, return success message
          return {
            'success': true,
            'message': 'Bulk checkout completed successfully',
          };
        }
      } else {
        final errorMessage = response.body.isNotEmpty
            ? response.body
            : 'Unknown error occurred';
        throw Exception(
          'Failed to bulk checkout: ${response.statusCode} - $errorMessage',
        );
      }
    } catch (e) {
      print('Error bulk checkout: $e');
      throw Exception('Error bulk checkout: $e');
    }
  }

  // TAMBAHAN: Method untuk validasi request body sebelum dikirim
  bool _validateBulkRequest(Map<String, dynamic> jsonBody) {
    if (!jsonBody.containsKey('InstanceIds') ||
        jsonBody['InstanceIds'] == null) {
      return false;
    }

    if (jsonBody['InstanceIds'] is! List ||
        (jsonBody['InstanceIds'] as List).isEmpty) {
      return false;
    }

    if (!jsonBody.containsKey('Destination') ||
        jsonBody['Destination'] == null ||
        (jsonBody['Destination'] as String).trim().isEmpty) {
      return false;
    }

    return true;
  }

  // TAMBAHAN: Method untuk debugging request format
  void _debugBulkRequest(Map<String, dynamic> jsonBody) {
    print('=== BULK REQUEST DEBUG ===');
    print('InstanceIds: ${jsonBody['InstanceIds']}');
    print('InstanceIds type: ${jsonBody['InstanceIds'].runtimeType}');
    print('InstanceIds length: ${(jsonBody['InstanceIds'] as List).length}');
    print('Destination: ${jsonBody['Destination']}');
    print('Remarks: ${jsonBody['Remarks']}');
    print('Full request: ${jsonEncode(jsonBody)}');
    print('==========================');
  }
}
