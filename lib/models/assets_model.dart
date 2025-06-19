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
  final int instanceId;
  final int assetId;
  final int qrCodeId;
  final String encodedData;
  final String qrCodeImageBase64;  // kita ubah menjadi String (fallback '')
  final int? shelfId;              // boleh null
  final String location;
  final String condition;          // fallback ''
  final String status;             // fallback ''
  final DateTime? warrantyExpiryDate; // bisa null
  final int? lifetime;             // bisa null
  final String serialNumber;       // fallback ''
  final String? lastCheckedOutByKpk; // boleh null
  final bool hasBeenCheckedIn;     // fallback false
  final String? checkedOutByName;  // boleh null
  final DateTime? lastCheckedOutDate; // bisa null
  final String? repairRequestStatus;  // boleh null
  final String? repairRequestedByName; // boleh null
  final dynamic asset;             // tetap dynamic, sesuai kebutuhan
  final int? quantity;
  final int? restockThreshold;
  final int? shelfLife;

  AssetInstances({
    required this.instanceId,
    required this.assetId,
    required this.qrCodeId,
    required this.encodedData,
    required this.qrCodeImageBase64,
    this.shelfId,
    required this.location,
    required this.condition,
    required this.status,
    this.warrantyExpiryDate,
    this.lifetime,
    required this.serialNumber,
    this.lastCheckedOutByKpk,
    required this.hasBeenCheckedIn,
    this.checkedOutByName,
    this.lastCheckedOutDate,
    this.repairRequestStatus,
    this.repairRequestedByName,
    this.asset,
    this.quantity,
    this.restockThreshold,
    this.shelfLife,
  });

  factory AssetInstances.fromJson(Map<String, dynamic> json) {
    // Debug-print untuk memastikan isi JSON
    print('[DEBUG AssetInstances.fromJson] json = $json');

    // Parse DateTime jika field tidak null dan valid
    DateTime? parseDate(String? value) {
      if (value == null || value.isEmpty) return null;
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }

    return AssetInstances(
      instanceId: json['InstanceId'] as int? ?? 0,
      assetId: json['AssetId'] as int? ?? 0,
      qrCodeId: json['QrCodeId'] as int? ?? 0,
      encodedData: (json['EncodedData'] as String?) ?? '',
      qrCodeImageBase64: (json['QrCodeImageBase64'] as String?) ?? '',
      shelfId: json['ShelfId'] as int?, // tetap null jika JSON-nya null
      location: (json['Location'] as String?) ?? '',
      condition: (json['Condition'] as String?) ?? '',
      status: (json['Status'] as String?) ?? '',
      warrantyExpiryDate: parseDate(json['WarrantyExpiryDate'] as String?),
      lifetime: json['Lifetime'] as int?,
      serialNumber: (json['SerialNumber'] as String?) ?? '',
      lastCheckedOutByKpk: (json['LastCheckedOutByKpk'] as String?),
      hasBeenCheckedIn: json['HasBeenCheckedIn'] as bool? ?? false,
      checkedOutByName: (json['CheckedOutByName'] as String?),
      lastCheckedOutDate: parseDate(json['LastCheckedOutDate'] as String?),
      repairRequestStatus: (json['RepairRequestStatus'] as String?),
      repairRequestedByName: (json['RepairRequestedByName'] as String?),
      asset: json['Asset'],
      quantity: json['Quantity'] as int?,
      restockThreshold: json['RestockThreshold'] as int?,
      shelfLife: json['ShelfLife'] as int?,
    );
  }
}

// to pass from instance detail page to repair request
class SimpleAssetInstanceModel {
  final int assetId;
  final String assetName;
  final int instanceId;
  final int qrCodeId;
  final String condition;

  SimpleAssetInstanceModel({
    required this.assetId,
    required this.assetName,
    required this.instanceId,
    required this.qrCodeId,
    required this.condition,
  });
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
