part of 'repair_request_bloc.dart';

@immutable
sealed class RepairRequestEvent {}

class RepairRequestsRequested extends RepairRequestEvent {}

class RepairRequestCreateRequested extends RepairRequestEvent {
  final int instanceId;
  final String remarks;
  final String? repairImageBase64;

  RepairRequestCreateRequested({
    required this.instanceId,
    required this.remarks,
    this.repairImageBase64,
  });
}

class RepairRequestUpdateRequested extends RepairRequestEvent {
  final int repairRequestId;
  final Map<String, dynamic> repairData;

  RepairRequestUpdateRequested({
    required this.repairRequestId,
    required this.repairData,
  });
}

class RepairRequestDeleteRequested extends RepairRequestEvent {
  final int repairRequestId;

  RepairRequestDeleteRequested({required this.repairRequestId});
}
