import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:digi4_mobile/models/instance_model.dart';
import '../../services/instance_service.dart';

part 'instance_logs_event.dart';
part 'package:digi4_mobile/blocs/instance/instance_logs_state.dart';

class InstanceLogsBloc extends Bloc<InstanceLogsEvent, InstanceLogsState> {
  final InstanceService _instanceService;

  InstanceLogsBloc(this._instanceService) : super(InstanceLogsInitial()) {
    on<InstanceLogsRequested>(_onLogsRequested);
  }

  Future<void> _onLogsRequested(
      InstanceLogsRequested event,
      Emitter<InstanceLogsState> emit,
      ) async {
    emit(InstanceLogsLoading());
    try {
      // Memanggil service untuk fetch logs
      final logs = await _instanceService.fetchInstanceLogs(event.instanceId);
      emit(InstanceLogsLoaded(logs: logs));
    } catch (e) {
      emit(InstanceLogsFailure(message: e.toString()));
    }
  }
}
