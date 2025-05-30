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

  Cabinet({
    required this.cabinetId,
    required this.cabinetName,
    required this.cabinetType,
  });

  factory Cabinet.fromJson(Map<String, dynamic> json) {
    return Cabinet(
      cabinetId: json['CabinetId'],
      cabinetName: json['CabinetName'],
      cabinetType: json['CabinetType'],
    );
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
