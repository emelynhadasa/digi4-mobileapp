import 'package:digi4_mobile/config/constant.dart';

class Plants {
  int plantId;
  String plantName;
  String address;

  Plants({
    required this.plantId,
    required this.plantName,
    required this.address,
  });

  factory Plants.fromJson(Map<String, dynamic> json) {
    return Plants(
      plantId: json['PlantId'],
      plantName: json['PlantName'],
      address: json['Address'],
    );
  }
}

class Cabinet {
  int cabinetId;
  String cabinetName;
  String cabinetType;
  dynamic cabinetImage;
  dynamic cabinetImageBase64;

  Cabinet({
    required this.cabinetId,
    required this.cabinetName,
    required this.cabinetType,
    this.cabinetImage,
    this.cabinetImageBase64,
  });

  factory Cabinet.fromJson(Map<String, dynamic> json) {
    final String? image = json['CabinetImage'];
    return Cabinet(
      cabinetId: json['CabinetId'],
      cabinetName: json['CabinetName'],
      cabinetType: json['CabinetType'],
      cabinetImage: image != null ? '${Constant.baseAddressUrl}$image' : null,
      cabinetImageBase64:  json['CabinetImageBase64'] ?? '',
    );
  }

  /// Getter yang mengembalikan URL penuh ke folder RequestImg kalau ada file‐name
  String? get imageUrl {
    if (cabinetImage != null && cabinetImage.toString().isNotEmpty) {
      return '${Constant.baseAddressUrl}${cabinetImage.toString()}';
    }
    return null;
  }

  /// boolean untuk memeriksa apakah ada data base64 yang dapat ditampilkan
  bool get hasBase64 {
    final raw = cabinetImageBase64;
    return raw != null && raw.toString().isNotEmpty;
  }
}

class Shelf {
  int shelfId;
  String shelfLabel;

  Shelf({required this.shelfId, required this.shelfLabel});

  factory Shelf.fromJson(Map<String, dynamic> json) {
    return Shelf(shelfId: json['ShelfId'], shelfLabel: json['ShelfLabel']);
  }
}

class Instances {
  int instanceId;
  String assetName;
  String brand;
  String specs;
  int currentShelfId;

  Instances({
    required this.instanceId,
    required this.assetName,
    required this.brand,
    required this.specs,
    required this.currentShelfId,
  });

  factory Instances.fromJson(Map<String, dynamic> json) {
    return Instances(
      instanceId: json['InstanceId'],
      assetName: json['AssetName'],
      brand: json['Brand'],
      specs: json['Specs'],
      currentShelfId: json['CurrentShelfId'],
    );
  }
}
