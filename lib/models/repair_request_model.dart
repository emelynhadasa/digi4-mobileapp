class RepairRequestModel {
  int repairRequestId;
  int instanceId;
  String kpk;
  String remarks;
  dynamic repairReqImage;
  String status;
  String submittedByName;
  DateTime updatedAt;
  String instanceDisplay;
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
      repairRequestId: json['RepairRequestId'],
      instanceId: json['InstanceId'],
      kpk: json['Kpk'],
      remarks: json['Remarks'],
      repairReqImage: json['RepairReqImage'],
      status: json['Status'],
      submittedByName: json['SubmittedByName'],
      updatedAt: DateTime.parse(json['UpdatedAt']),
      instanceDisplay: json['InstanceDisplay'],
      repairImageBase64: json['RepairImageBase64'] ?? '', // Handle null case
    );
  }
}
