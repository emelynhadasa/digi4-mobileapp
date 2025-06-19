import 'package:digi4_mobile/config/constant.dart';

class RepairRequestModel {
  int     repairRequestId;
  int     instanceId;
  String  kpk;
  String  remarks;
  dynamic repairReqImage;
  String  status;
  String  submittedByName;
  DateTime updatedAt;
  String  instanceDisplay;
  dynamic repairImageBase64;

  RepairRequestModel({
    required this.repairRequestId,
    required this.instanceId,
    required this.kpk,
    required this.remarks,
    required this.repairReqImage,
    required this.status,
    required this.submittedByName,
    required this.updatedAt,
    required this.instanceDisplay,
    required this.repairImageBase64,
  });

  factory RepairRequestModel.fromJson(Map<String, dynamic> json) {
    return RepairRequestModel(
      repairRequestId:    json['RepairRequestId'],
      instanceId:         json['InstanceId'],
      kpk:                json['Kpk'],
      remarks:            json['Remarks'],
      repairReqImage:     json['RepairReqImage'],    // nama file, bisa null
      status:             json['Status'],
      submittedByName:    json['SubmittedByName'],
      updatedAt:          DateTime.parse(json['UpdatedAt']),
      instanceDisplay:    json['InstanceDisplay'],
      repairImageBase64:  json['RepairImageBase64'] ?? '', // bisa empty string
    );
  }

  /// Getter yang mengembalikan URL penuh ke folder RequestImg kalau ada file‐name
  String? get imageUrl {
    if (repairReqImage != null && repairReqImage.toString().isNotEmpty) {
      return '${Constant.baseImageUrl}/RequestImg/${repairReqImage.toString()}';
    }
    return null;
  }

  /// boolean untuk memeriksa apakah ada data base64 yang dapat ditampilkan
  bool get hasBase64 {
    final raw = repairImageBase64;
    return raw != null && raw.toString().isNotEmpty;
  }
}
