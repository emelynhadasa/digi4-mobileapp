part of 'assets_bloc.dart';

@immutable
sealed class AssetsEvent {}

class AssetCreateRequested extends AssetsEvent {
  final Map<String, dynamic> assetData;
  final String? imagePath;
  final String? documentPath;

  AssetCreateRequested({
    required this.assetData,
    this.imagePath,
    this.documentPath,
  });
}

class AssetsRequested extends AssetsEvent {}

class AssetsLoadByIdRequested extends AssetsEvent {
  final int assetId;

  AssetsLoadByIdRequested({required this.assetId});
}

class AssetUpdateRequested extends AssetsEvent {
  final int assetId;
  final Map<String, dynamic> assetData;
  final String? imagePath;

  AssetUpdateRequested({
    required this.assetId,
    required this.assetData,
    this.imagePath,
  });
}

class AssetDeleteRequested extends AssetsEvent {
  final int assetId;

  AssetDeleteRequested({required this.assetId});
}

class AssetInstanceLoaded extends AssetsEvent {
  final int assetId;

  AssetInstanceLoaded({required this.assetId});
}

class AssetInstanceCreateRequested extends AssetsEvent {
  final Map<String, dynamic> instanceData;

  AssetInstanceCreateRequested({required this.instanceData});
}

class AssetInstanceUpdateRequested extends AssetsEvent {
  final int instanceId;
  final Map<String, dynamic> instanceData;

  AssetInstanceUpdateRequested({
    required this.instanceId,
    required this.instanceData,
  });
}

class AssetInstanceDeleteRequested extends AssetsEvent {
  final int instanceId;

  AssetInstanceDeleteRequested({required this.instanceId});
}

class InstanceCheckoutRequested extends AssetsEvent {
  final int instanceId;
  final Map<String, dynamic> jsonBody;

  InstanceCheckoutRequested({required this.instanceId, required this.jsonBody});
}

class InstanceCheckinRequested extends AssetsEvent {
  final int instanceId;
  final Map<String, dynamic> jsonBody;

  InstanceCheckinRequested({required this.instanceId, required this.jsonBody});
}

class InstanceMarkFoundRequested extends AssetsEvent {
  final int instanceId;

  InstanceMarkFoundRequested({required this.instanceId});

  @override
  List<Object> get props => [instanceId];
}

class AssetBulkInstancesLoaded extends AssetsEvent {
  final String tab;

  AssetBulkInstancesLoaded({required this.tab});

  @override
  List<Object> get props => [tab];
}

class AssetBulkCheckin extends AssetsEvent {
  final Map<String, dynamic> jsonBody;

  AssetBulkCheckin({required this.jsonBody});

  @override
  List<Object> get props => [jsonBody];
}

class AssetBulkCheckout extends AssetsEvent {
  final Map<String, dynamic> jsonBody;

  AssetBulkCheckout({required this.jsonBody});

  @override
  List<Object> get props => [jsonBody];
}
