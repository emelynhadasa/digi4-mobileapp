import 'dart:convert';

import 'package:digi4_mobile/config/constant.dart';
import 'package:digi4_mobile/models/locator_model.dart';
import 'package:digi4_mobile/utils/token.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class LocatorService {
  Future<List<Plants>> getPlants() async {
    try {
      final String? token = await Token.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
      };

      final response = await http.get(
        Uri.parse(Constant.plantUrl),
        headers: headers,
      );

      print('Get plants response code: ${response.statusCode}');
      print('Get plants response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed plants count: ${data.length}');
        for (var p in data) {
          print('Plant: ${p['PlantId']}, ${p['PlantName']}, ${p['Address']}');
        }
        return (data as List).map((item) => Plants.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load plants');
      }
    } catch (e) {
      throw Exception('Failed to load plants: $e');
    }
  }

  Future<void> addPlant(String plantName, String address) async {
    try {
      final String? token = await Token.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
      };

      final body = json.encode({'PlantName': plantName, 'Address': address});

      final response = await http.post(
        Uri.parse(Constant.plantUrl),
        headers: headers,
        body: body,
      );

      print('Add plant response code: ${response.statusCode}');
      print('Add plant response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to add plant');
      }
    } catch (e) {
      throw Exception('Failed to add plant: $e');
    }
  }

  Future<void> editPlant(int plantId, String plantName, String address) async {
    try {
      final String? token = await Token.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
      };

      final body = json.encode({
        'PlantId': plantId,
        'PlantName': plantName,
        'Address': address,
      });

      final response = await http.put(
        Uri.parse('${Constant.plantUrl}/$plantId'),
        headers: headers,
        body: body,
      );

      print('Edit plant response code: ${response.statusCode}');
      print('Edit plant response body: ${response.body}');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to edit plant: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to edit plant: $e');
    }
  }

  Future<List<Cabinet>> getCabinets(String plantId) async {
    try {
      final String? token = await Token.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('${Constant.plantUrl}/$plantId/cabinets'),
        headers: headers,
      );

      print('Get cabinets response code: ${response.statusCode}');
      print('Get cabinets response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List).map((item) => Cabinet.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load cabinets');
      }
    } catch (e) {
      throw Exception('Failed to load cabinets: $e');
    }
  }

  // Future<void> editCabinet(
  //   int cabinetId,
  //   String plantsId,
  //   String cabinetName,
  //   String cabinetType,
  // ) async {
  //   try {
  //     final String? token = await Token.getToken();
  //
  //     final headers = {
  //       ...Constant.header,
  //       'Authorization': 'Bearer $token',
  //       'content-type': 'application/json',
  //     };
  //
  //     final body = json.encode({
  //       'CabinetId': cabinetId,
  //       'PlantsId': plantsId,
  //       'CabinetName': cabinetName,
  //       'CabinetType': cabinetType,
  //     });
  //
  //     final response = await http.put(
  //       Uri.parse('${Constant.cabinetUrl}/$cabinetId'),
  //       headers: headers,
  //       body: body,
  //     );
  //
  //     print('Edit cabinet response code: ${response.statusCode}');
  //     print('Edit cabinet response body: ${response.body}');
  //     if (response.statusCode != 204) {
  //       throw Exception('Failed to edit cabinet');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to edit cabinet: $e');
  //   }
  // }

  Future<void> editCabinet(
      int cabinetId,
      String cabinetName,
      String cabinetType,
      File? imageFile,
      ) async {
    final token = await Token.getToken();
    if (token == null) throw Exception('No auth token');

    // URL tanpa /api/api
    final uri = Uri.parse('${Constant.baseUrl}/locator/cabinets/$cabinetId');
    final request = http.MultipartRequest('PUT', uri);

    // header (tidak perlu set content-type)
    request.headers['Authorization'] = 'Bearer $token';

    // form fields
    request.fields['CabinetId'] = cabinetId.toString();
    request.fields['CabinetName'] = cabinetName;
    request.fields['CabinetType'] = cabinetType;

    // file kalau ada
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    // kirim
    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);

    print('Edit cabinet response: ${resp.statusCode} ${resp.body}');
    if (resp.statusCode != 204) {
      throw Exception('Failed to edit cabinet: ${resp.body}');
    }
  }

  // Future<void> createCabinet(
  //     int plantId,
  //     String cabinetName,
  //     String cabinetType,
  //     int shelfCount,
  //     String labelMode,
  //     List<String>? manualLabelsList,
  //     File? imageFile,
  //     ) async {
  //   try {
  //     final String? token = await Token.getToken();
  //     final uri = Uri.parse(Constant.cabinetUrl);
  //     final request = http.MultipartRequest('POST', uri);
  //
  //     if (token == null) {
  //       throw Exception('Authentication token not found');
  //     }
  //
  //     final headers = {
  //       ...Constant.header,
  //       'Authorization': 'Bearer $token',
  //       'content-type': 'application/json',
  //     };
  //
  //     // Buat map-nya dulu, jangan langsung encode
  //     final Map<String, dynamic> bodyMap = {
  //       'PlantId': plantId,
  //       'CabinetName': cabinetName,
  //       'CabinetType': cabinetType,
  //       'LabelMode': labelMode,
  //       'ShelfCount': shelfCount,
  //     };
  //
  //     if (labelMode == 'manual' && manualLabelsList != null) {
  //       bodyMap['ManualLabels'] = manualLabelsList;
  //     }
  //
  //     if (imageFile != null) {
  //       final image = await http.MultipartFile.fromPath('file', imageFile.path);
  //       request.files.add(image);
  //     }
  //
  //     final response = await http.post(
  //       Uri.parse(Constant.cabinetUrl),
  //       headers: headers,
  //       body: json.encode(bodyMap), // encode baru di sini
  //     );
  //
  //     print('Create cabinet response code: ${response.statusCode}');
  //     print('Create cabinet response body: ${response.body}');
  //
  //     if (response.statusCode != 201) {
  //       throw Exception('Failed to create cabinet');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to create cabinet: $e');
  //   }
  // }

  Future<void> createCabinet(
      int plantId,
      String cabinetName,
      String cabinetType,
      int shelfCount,
      String labelMode,
      List<String>? manualLabelsList,
      File? imageFile,
      ) async {
    try {
      final String? token = await Token.getToken();
      if (token == null) throw Exception('Authentication token not found');

      final uri = Uri.parse('${Constant.baseUrl}/locator/cabinets');
      final request = http.MultipartRequest('POST', uri);

      // Set token, no need to add Content-Type (otomatis multipart)
      request.headers['Authorization'] = 'Bearer $token';

      // Add form fields
      request.fields['PlantId'] = plantId.toString();
      request.fields['CabinetName'] = cabinetName;
      request.fields['CabinetType'] = cabinetType;
      request.fields['ShelfCount'] = shelfCount.toString();
      request.fields['LabelMode'] = labelMode;

      if (labelMode == 'manual' && manualLabelsList != null) {
        request.fields['ManualLabels'] = manualLabelsList.join(',');
      }

      // Add image if provided
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'), // ganti ke png kalau perlu
        ));
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Create cabinet response code: ${response.statusCode}');
      print('Create cabinet response body: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Failed to create cabinet');
      }
    } catch (e) {
      throw Exception('Failed to create cabinet: $e');
    }
  }

  Future<List<Shelf>> getShelves(int cabinetId) async {
    try {
      final String? token = await Token.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('${Constant.cabinetUrl}/$cabinetId/shelves'),
        headers: headers,
      );

      print('Get shelves response code: ${response.statusCode}');
      print('Get shelves response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List).map((item) => Shelf.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load shelves');
      }
    } catch (e) {
      throw Exception('Failed to load shelves: $e');
    }
  }

  Future<void> addShelf(int cabinetId, String shelfLabel) async {
    try {
      final String? token = await Token.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
      };

      final body = json.encode({
        'CabinetId': cabinetId,
        'ShelfLabel': shelfLabel,
      });

      final response = await http.post(
        Uri.parse(Constant.shelfUrl),
        headers: headers,
        body: body,
      );

      print('Add shelf response code: ${response.statusCode}');
      print('Add shelf response body: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Failed to add shelf');
      }
    } catch (e) {
      throw Exception('Failed to add shelf: $e');
    }
  }

  Future<void> editShelf(int shelfId, int cabinetId, String shelfLabel) async {
    try {
      final String? token = await Token.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
      };

      final body = json.encode({'ShelfId': shelfId, 'ShelfLabel': shelfLabel});

      final response = await http.put(
        Uri.parse('${Constant.shelfUrl}/$shelfId'),
        headers: headers,
        body: body,
      );

      print('Edit shelf response code: ${response.statusCode}');
      print('Edit shelf response body: ${response.body}');

      if (response.statusCode != 204) {
        throw Exception('Failed to edit shelf');
      }
    } catch (e) {
      throw Exception('Failed to edit shelf: $e');
    }
  }

  Future<List<Instances>> getInstances(int shelfId) async {
    try {
      final String? token = await Token.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('${Constant.shelfUrl}/$shelfId/instances'),
        headers: headers,
      );

      print('Get instances response code: ${response.statusCode}');
      print('Get instances response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data as List).map((item) => Instances.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load instances');
      }
    } catch (e) {
      throw Exception('Failed to load instances: $e');
    }
  }

  Future<void> moveInstances(int instanceId, int newShelfId) async {
    try {
      final String? token = await Token.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final headers = {
        ...Constant.header,
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
      };

      final body = json.encode({
        'InstanceId': instanceId,
        'NewShelfId': newShelfId,
      });

      final response = await http.post(
        Uri.parse('${Constant.instanceUrl}/$instanceId/move'),
        headers: headers,
        body: body,
      );
      print('Move instance response code: ${response.statusCode}');
      print('Move instance response body: ${response.body}');
      if (response.statusCode != 204) {
        throw Exception('Failed to move instance');
      }
    } catch (e) {}
  }
}
