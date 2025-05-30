import 'package:bloc/bloc.dart';
import 'package:digi4_mobile/models/repair_request_model.dart';
import 'package:digi4_mobile/services/repair_service.dart';
import 'package:meta/meta.dart';

part 'repair_request_event.dart';
part 'repair_request_state.dart';

class RepairRequestBloc extends Bloc<RepairRequestEvent, RepairRequestState> {
  final RepairService _repairRequestService = RepairService();
  RepairRequestBloc() : super(RepairRequestInitial()) {
    on<RepairRequestsRequested>(_handleRepairRequestsRequested);
    on<RepairRequestCreateRequested>(_handleRepairRequestCreateRequested);
  }

  Future<void> _handleRepairRequestsRequested(
    RepairRequestsRequested event,
    Emitter<RepairRequestState> emit,
  ) async {
    try {
      print('BLoC: Starting to load repair requests...');
      emit(RepairRequestLoading());

      final repairRequests = await _repairRequestService.getRepairRequests();

      print(
        'BLoC: Successfully loaded ${repairRequests.length} repair requests',
      );
      emit(RepairRequestLoaded(repairRequests: repairRequests));
    } catch (e) {
      print('BLoC: Failed to load repair requests - $e');
      emit(RepairRequestLoadFailure(message: e.toString()));
    }
  }

  Future<void> _handleRepairRequestCreateRequested(
    RepairRequestCreateRequested event,
    Emitter<RepairRequestState> emit,
  ) async {
    try {
      print('BLoC: Starting to create repair request...');
      emit(RepairRequestCreateLoading());

      final response = await _repairRequestService.createRepairRequest(
        instanceId: event.instanceId,
        remarks: event.remarks,
        repairImageBase64: event.repairImageBase64,
      );

      print('BLoC: Successfully created repair request');
      emit(
        RepairRequestCreateSuccess(
          message: 'Repair request created successfully',
        ),
      );
    } catch (e) {
      print('BLoC: Failed to create repair request - $e');
      emit(RepairRequestCreateFailure(message: e.toString()));
    }
  }
}
