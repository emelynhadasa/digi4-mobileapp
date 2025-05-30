class AssetsModel {
  int assetId;
  String assetName;
  String brand;
  String specs;
  DateTime createdAt;
  int assetCategoryId;
  String imageFileName;

  AssetsModel({
    required this.assetId,
    required this.assetName,
    required this.brand,
    required this.specs,
    required this.createdAt,
    required this.assetCategoryId,
    required this.imageFileName,
  });

  factory AssetsModel.fromJson(Map<String, dynamic> json) {
    String createdAt = '';
    if (json['CreatedAt'] != null) {
      if (json['CreatedAt'] is String) {
        createdAt = json['CreatedAt'];
      } else {
        // Coba parse sebagai DateTime jika perlu
        try {
          final dateTime = DateTime.parse(json['CreatedAt'].toString());
          createdAt =
              "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
        } catch (e) {
          createdAt = 'Invalid date';
        }
      }
    }
    return AssetsModel(
      assetId: json['AssetId'],
      assetName: json['AssetName'],
      brand: json['Brand'],
      specs: json['Specs'],
      createdAt: DateTime.parse(json['CreatedAt']),
      assetCategoryId: json['AssetCategoryId'],
      imageFileName: json['ImageFileName'] ?? '',
    );
  }
}

class AssetInstances {
  int instanceId;
  int assetId;
  int qrCodeId;
  String encodedData;
  dynamic qrCodeImageBase64;
  dynamic shelfId;
  String location;
  String condition;
  String status;
  DateTime warrantyExpiryDate;
  int lifetime;
  String serialNumber;
  dynamic lastCheckedOutByKpk;
  bool hasBeenCheckedIn;
  dynamic checkedOutByName;
  DateTime lastCheckedOutDate;
  dynamic repairRequestStatus;
  dynamic repairRequestedByName;
  dynamic asset;

  AssetInstances({
    required this.instanceId,
    required this.assetId,
    required this.qrCodeId,
    required this.encodedData,
    required this.qrCodeImageBase64,
    required this.shelfId,
    required this.location,
    required this.condition,
    required this.status,
    required this.warrantyExpiryDate,
    required this.lifetime,
    required this.serialNumber,
    required this.lastCheckedOutByKpk,
    required this.hasBeenCheckedIn,
    required this.checkedOutByName,
    required this.lastCheckedOutDate,
    required this.repairRequestStatus,
    required this.repairRequestedByName,
    required this.asset,
  });

  factory AssetInstances.fromJson(Map<String, dynamic> json) {
    return AssetInstances(
      instanceId: json['InstanceId'],
      assetId: json['AssetId'],
      qrCodeId: json['QrCodeId'],
      encodedData: json['EncodedData'],
      qrCodeImageBase64: json['QrCodeImageBase64'],
      shelfId: json['ShelfId'],
      location: json['Location'],
      condition: json['Condition'],
      status: json['Status'],
      warrantyExpiryDate: DateTime.parse(json['WarrantyExpiryDate']),
      lifetime: json['Lifetime'],
      serialNumber: json['SerialNumber'],
      lastCheckedOutByKpk: json['LastCheckedOutByKpk'],
      hasBeenCheckedIn: json['HasBeenCheckedIn'],
      checkedOutByName: json['CheckedOutByName'],
      lastCheckedOutDate: DateTime.parse(json['LastCheckedOutDate']),
      repairRequestStatus: json['RepairRequestStatus'],
      repairRequestedByName: json['RepairRequestedByName'],
      asset: json['Asset'], // Assuming asset is a nested object
    );
  }
}

class BulkResponse {
  List<BulkItems>? data;
  String? message;
  bool? success;

  BulkResponse({this.data, this.message, this.success});

  factory BulkResponse.fromJson(Map<String, dynamic> json) {
    print('Parsing BulkResponse from JSON: $json'); // Debug log

    List<BulkItems>? dataList;

    try {
      if (json['data'] != null) {
        if (json['data'] is List) {
          dataList = (json['data'] as List)
              .map((x) => BulkItems.fromJson(x as Map<String, dynamic>))
              .toList();
        } else {
          print(
            'Warning: data field is not a List, type: ${json['data'].runtimeType}',
          );
        }
      }
    } catch (e) {
      print('Error parsing BulkResponse data: $e');
      dataList = [];
    }

    return BulkResponse(
      data: dataList,
      message: json['message']?.toString(),
      success: json['success'] ?? true,
    );
  }
}

class BulkItems {
  int? instanceId;
  String? assetName;
  String? location;
  String? condition;
  String? status;
  String? serialNumber;
  String? brand;
  String? plant;
  int? assetId;
  String? qrCodeUrl;
  bool? isSelected; // For UI selection state

  BulkItems({
    this.instanceId,
    this.assetName,
    this.location,
    this.condition,
    this.status,
    this.serialNumber,
    this.brand,
    this.plant,
    this.assetId,
    this.qrCodeUrl,
    this.isSelected = false,
  });

  factory BulkItems.fromJson(Map<String, dynamic> json) {
    print('Parsing BulkItem from JSON: $json'); // Debug log

    return BulkItems(
      // PERBAIKAN: Handle multiple possible key formats
      instanceId: _parseIntValue(json, ['InstanceId', 'instanceId', 'id']),
      assetName: _parseStringValue(json, ['AssetName', 'assetName', 'name']),
      location: _parseStringValue(json, ['Location', 'location']),
      condition: _parseStringValue(json, ['Condition', 'condition']),
      status: _parseStringValue(json, ['Status', 'status']),
      serialNumber: _parseStringValue(json, [
        'SerialNumber',
        'serialNumber',
        'serial_number',
      ]),
      brand: _parseStringValue(json, ['Brand', 'brand']),
      plant: _parseStringValue(json, ['Plant', 'plant']),
      assetId: _parseIntValue(json, ['AssetId', 'assetId', 'asset_id']),
      qrCodeUrl: _parseStringValue(json, [
        'QrCodeUrl',
        'qrCodeUrl',
        'qr_code_url',
      ]),
      isSelected: false,
    );
  }

  // Helper method untuk parsing int values dengan multiple keys
  static int? _parseIntValue(Map<String, dynamic> json, List<String> keys) {
    for (String key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        if (json[key] is int) {
          return json[key];
        } else if (json[key] is String) {
          return int.tryParse(json[key]);
        }
      }
    }
    return null;
  }

  // Helper method untuk parsing string values dengan multiple keys
  static String? _parseStringValue(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (String key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        return json[key].toString();
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'InstanceId': instanceId,
      'AssetName': assetName,
      'Location': location,
      'Condition': condition,
      'Status': status,
      'SerialNumber': serialNumber,
      'Brand': brand,
      'Plant': plant,
      'AssetId': assetId,
      'QrCodeUrl': qrCodeUrl,
    };
  }

  // Helper method untuk create copy with selection state
  BulkItems copyWith({bool? isSelected}) {
    return BulkItems(
      instanceId: instanceId,
      assetName: assetName,
      location: location,
      condition: condition,
      status: status,
      serialNumber: serialNumber,
      brand: brand,
      plant: plant,
      assetId: assetId,
      qrCodeUrl: qrCodeUrl,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

// TAMBAHAN: Model untuk Bulk Request Body
class BulkOperationRequest {
  List<int> instanceIds;
  String destination;
  String remarks;

  BulkOperationRequest({
    required this.instanceIds,
    required this.destination,
    required this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'InstanceIds': instanceIds,
      'Destination': destination,
      'Remarks': remarks,
    };
  }
}
