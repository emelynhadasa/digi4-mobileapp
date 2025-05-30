part of 'assets_bloc.dart';

@immutable
sealed class AssetsState {}

final class AssetsInitial extends AssetsState {}

class AssetCreateLoading extends AssetsState {}

class AssetCreateSuccess extends AssetsState {
  final dynamic assetId;

  AssetCreateSuccess({required this.assetId});
}

class AssetCreateFailure extends AssetsState {
  final String message;

  AssetCreateFailure({required this.message});
}

// Get assets states
class AssetsLoading extends AssetsState {}

class AssetsLoaded extends AssetsState {
  final List<dynamic> assets;

  AssetsLoaded({required this.assets});
}

class AssetsLoadFailure extends AssetsState {
  final String message;

  AssetsLoadFailure({required this.message});
}

class AssetsLoadByIdSuccess extends AssetsState {
  final AssetsModel asset;

  AssetsLoadByIdSuccess({required this.asset});
}

class AssetsLoadByIdFailure extends AssetsState {
  final String message;

  AssetsLoadByIdFailure({required this.message});
}

class AssetsLoadByIdLoading extends AssetsState {
  final String message;

  AssetsLoadByIdLoading({this.message = 'Loading...'});
}

class AssetsUpdatedSuccess extends AssetsState {
  final String message;

  AssetsUpdatedSuccess({required this.message});
}

class AssetsUpdatedFailure extends AssetsState {
  final String message;

  AssetsUpdatedFailure({required this.message});
}

class AssetsUpdatedLoading extends AssetsState {
  final String message;

  AssetsUpdatedLoading({this.message = 'Loading...'});
}

// Di assets_state.dart (part of 'assets_bloc.dart')
class AssetsDeleteLoading extends AssetsState {}

class AssetsDeleteSuccess extends AssetsState {
  final String message;

  AssetsDeleteSuccess({required this.message});
}

class AssetsDeleteFailure extends AssetsState {
  final String message;

  AssetsDeleteFailure({required this.message});
}

class AssetsInstancesLoading extends AssetsState {}

class AssetsInstancesLoaded extends AssetsState {
  final List<AssetInstances> instances;

  AssetsInstancesLoaded({required this.instances});
}

class AssetsInstancesLoadFailure extends AssetsState {
  final String message;

  AssetsInstancesLoadFailure({required this.message});
}

class AssetsInstanceEditLoading extends AssetsState {
  final String message;

  AssetsInstanceEditLoading({this.message = 'Loading...'});
}

class AssetsInstanceEditSuccess extends AssetsState {
  final String message;

  AssetsInstanceEditSuccess({required this.message});
}

class AssetsInstanceEditFailure extends AssetsState {
  final String message;

  AssetsInstanceEditFailure({required this.message});
}

class AssetsInstanceDeleteLoading extends AssetsState {
  final String message;

  AssetsInstanceDeleteLoading({this.message = 'Loading...'});
}

class AssetsInstanceDeleteSuccess extends AssetsState {
  final String message;

  AssetsInstanceDeleteSuccess({required this.message});
}

class AssetsInstanceDeleteFailure extends AssetsState {
  final String message;

  AssetsInstanceDeleteFailure({required this.message});
}

class ChekcoutInstanceLoading extends AssetsState {
  final String message;

  ChekcoutInstanceLoading({this.message = 'Loading...'});
}

class ChekcoutInstanceSuccess extends AssetsState {
  final String message;

  ChekcoutInstanceSuccess({required this.message});
}

class ChekcoutInstanceFailure extends AssetsState {
  final String message;

  ChekcoutInstanceFailure({required this.message});
}

class CheckinInstanceLoading extends AssetsState {
  final String message;

  CheckinInstanceLoading({this.message = 'Loading...'});
}

class CheckinInstanceSuccess extends AssetsState {
  final String message;

  CheckinInstanceSuccess({required this.message});
}

class CheckinInstanceFailure extends AssetsState {
  final String message;

  CheckinInstanceFailure({required this.message});
}

class AssetsMarkFoundLoading extends AssetsState {
  final String? message;

  AssetsMarkFoundLoading({this.message});
}

class AssetsMarkFoundSuccess extends AssetsState {
  final String message;

  AssetsMarkFoundSuccess(this.message);
}

final class AssetsBulkLoading extends AssetsState {
  final String? message;
  AssetsBulkLoading({this.message});
}

final class AssetsBulkLoadedSuccess extends AssetsState {
  final List<BulkResponse> assets;
  AssetsBulkLoadedSuccess({required this.assets});
}

final class AssetsBulkLoadedFailure extends AssetsState {
  final String message;
  AssetsBulkLoadedFailure({required this.message});
}

// Bulk Checkin States
final class AssetsBulkCheckinLoading extends AssetsState {
  final String? message;
  AssetsBulkCheckinLoading({this.message});
}

final class AssetsBulkCheckinSuccess extends AssetsState {
  final String message;
  AssetsBulkCheckinSuccess({required this.message});
}

final class AssetsBulkCheckinFailure extends AssetsState {
  final String message;
  AssetsBulkCheckinFailure({required this.message});
}

// Bulk Checkout States
final class AssetsBulkCheckoutLoading extends AssetsState {
  final String? message;
  AssetsBulkCheckoutLoading({this.message});
}

final class AssetsBulkCheckoutSuccess extends AssetsState {
  final String message;
  AssetsBulkCheckoutSuccess({required this.message});
}

final class AssetsBulkCheckoutFailure extends AssetsState {
  final String message;
  AssetsBulkCheckoutFailure({required this.message});
}
