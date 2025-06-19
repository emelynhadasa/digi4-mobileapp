import 'package:bloc/bloc.dart';
import 'package:digi4_mobile/models/dashboard_model.dart';
import 'package:digi4_mobile/services/dashboard_service.dart';
import 'package:meta/meta.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardService _dashboardService = DashboardService();
  DashboardBloc() : super(DashboardInitial()) {
    on<DashboardRequested>(_handleDashboardRequested);
    on<DashboardReloadRequested>(_handleDashboardReloadRequested);
  }
  Future<void> _handleDashboardRequested(
    DashboardRequested event,
    Emitter<DashboardState> emit,
  ) async {
    await _fetchDashboardData(emit);
  }

  Future<void> _handleDashboardReloadRequested(
    DashboardReloadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading(message: 'Reloading data...'));
    await _fetchDashboardData(emit);
  }

  Future<void> _fetchDashboardData(Emitter<DashboardState> emit) async {
    try {
      emit(DashboardLoading());
      final dashboardData = await _dashboardService.getDashboard();
      emit(DashboardSuccess(dashboardModel: dashboardData));
    } catch (e) {
      emit(DashboardFailure(message: e.toString()));
    }
  }
}

