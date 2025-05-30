class InstanceModel {
  final int instanceId;
  final String condition;
  final int qrCodeId;

  InstanceModel({
    required this.instanceId,
    required this.condition,
    required this.qrCodeId,
  });

  factory InstanceModel.fromJson(Map<String, dynamic> json) {
    return InstanceModel(
      instanceId: json['InstanceId'] ?? 0,
      condition: json['Condition'] ?? '',
      qrCodeId: json['QrCodeId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'InstanceId': instanceId,
      'Condition': condition,
      'QrCodeId': qrCodeId,
    };
  }

  // Display name untuk dropdown
  String get instanceDisplay => 'Instance $instanceId (QR: $qrCodeId) - $condition';
}