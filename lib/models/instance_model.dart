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

class InstanceLog {
  final String name;
  final String transactionName;    // contoh: "Checkout" atau "/" (untuk consumable bisa pakai "Purpose")
  final String details;            // "Used 5 rolls" atau "Return to shelf 3"
  final String remarks;
  final DateTime transactionDate;

  InstanceLog({
    required this.name,
    required this.transactionName,
    required this.details,
    required this.remarks,
    required this.transactionDate,
  });

  factory InstanceLog.fromJson(Map<String, dynamic> json) {
    // Kasus consumable: JSON memiliki key "Purpose" dan "QuantityConsumed"
    if (json.containsKey('QuantityConsumed') && json.containsKey('Purpose')) {
      final purpose = (json['Purpose'] as String?) ?? '';
      final qty = (json['QuantityConsumed'] as int? ?? 0);
      return InstanceLog(
        name: (json['Name'] as String?) ?? '',
        transactionName: 'ConsumableTxn', // bisa custom atau kosong
        details: '$purpose ($qty)',        // Contoh: "Used rolls (5)"
        remarks: (json['Remarks'] as String?) ?? '',
        transactionDate: DateTime.parse(
          (json['TransactionDate'] as String?) ?? DateTime.now().toIso8601String(),
        ),
      );
    }
    // Kasus reusable: JSON punya "TransactionName" dan "Details"
    return InstanceLog(
      name: (json['Name'] as String?) ?? '',
      transactionName: (json['TransactionName'] as String?) ?? '',
      details: (json['Details'] as String?) ?? '',
      remarks: (json['Remarks'] as String?) ?? '',
      transactionDate: DateTime.parse(
        (json['TransactionDate'] as String?) ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
