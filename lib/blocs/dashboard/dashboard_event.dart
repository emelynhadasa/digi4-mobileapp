part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardEvent {}

class DashboardRequested extends DashboardEvent {}

class DashboardReloadRequested extends DashboardEvent{}
