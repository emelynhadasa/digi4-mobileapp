part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardState {}

final class DashboardInitial extends DashboardState {}

class DashboardSuccess extends DashboardState {
  final DashboardModel dashboardModel;

  DashboardSuccess({required this.dashboardModel});
}

class DashboardLoading extends DashboardState {
  final String message;
  DashboardLoading({this.message = 'Loading...'});
}

class DashboardFailure extends DashboardState {
  final String message;
  DashboardFailure({this.message = 'Failed to load dashboard'});
}
