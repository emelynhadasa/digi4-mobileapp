part of 'instance_logs_bloc.dart';

@immutable
abstract class InstanceLogsState {}

class InstanceLogsInitial extends InstanceLogsState {}

/// Status ketika sedang melakukan request ke API
class InstanceLogsLoading extends InstanceLogsState {}

/// Status ketika data logs berhasil di‐load
class InstanceLogsLoaded extends InstanceLogsState {
  final List<InstanceLog> logs;
  InstanceLogsLoaded({required this.logs});
}

/// Status ketika terjadi error
class InstanceLogsFailure extends InstanceLogsState {
  final String message;
  InstanceLogsFailure({required this.message});
}
