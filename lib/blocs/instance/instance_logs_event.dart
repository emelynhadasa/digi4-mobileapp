part of 'instance_logs_bloc.dart';

@immutable
abstract class InstanceLogsEvent {}

/// Akan dipanggil ketika kita ingin load logs untuk sebuah instance tertentu
class InstanceLogsRequested extends InstanceLogsEvent {
  final int instanceId;
  InstanceLogsRequested({required this.instanceId});
}