part of 'repair_request_bloc.dart';

@immutable
sealed class RepairRequestState {}

final class RepairRequestInitial extends RepairRequestState {}

class RepairRequestLoading extends RepairRequestState {}

class RepairRequestLoaded extends RepairRequestState {
  final List<RepairRequestModel> repairRequests;

  RepairRequestLoaded({required this.repairRequests});
}

class RepairRequestLoadFailure extends RepairRequestState {
  final String message;

  RepairRequestLoadFailure({required this.message});
}

class RepairRequestCreateLoading extends RepairRequestState {}

class RepairRequestCreateSuccess extends RepairRequestState {
  final String message;

  RepairRequestCreateSuccess({required this.message});
}

class RepairRequestCreateFailure extends RepairRequestState {
  final String message;

  RepairRequestCreateFailure({required this.message});
}

class RepairRequestUpdateSuccess extends RepairRequestState {
  final String message;

  RepairRequestUpdateSuccess({required this.message});
}

class RepairRequestUpdateFailure extends RepairRequestState {
  final String message;

  RepairRequestUpdateFailure({required this.message});
}

class RepairRequestDeleteSuccess extends RepairRequestState {
  final String message;

  RepairRequestDeleteSuccess({required this.message});
}

class RepairRequestDeleteFailure extends RepairRequestState {
  final String message;

  RepairRequestDeleteFailure({required this.message});
}
