import 'package:bloc/bloc.dart';
import 'package:digi4_mobile/models/assets_model.dart';
import 'package:digi4_mobile/services/assets_service.dart';
import 'package:meta/meta.dart';

part 'assets_event.dart';
part 'assets_state.dart';

class AssetsBloc extends Bloc<AssetsEvent, AssetsState> {
  final AssetsService _assetsService = AssetsService();
  AssetsBloc() : super(AssetsInitial()) {
    on<AssetCreateRequested>(_handleAssetCreateRequested);
    on<AssetsRequested>(_handleAssetsRequested);
    on<AssetsLoadByIdRequested>(_handleAssetsLoadByIdRequested);
    on<AssetUpdateRequested>(_handleAssetUpdateRequested);
    on<AssetDeleteRequested>(_handleAssetDeleteRequested);
    on<AssetInstanceLoaded>(_handleAssetInstanceLoaded);
    on<AssetInstanceCreateRequested>(_handleAssetInstanceCreateRequested);
    on<AssetInstanceUpdateRequested>(_handleAssetInstanceUpdateRequested);
    on<AssetInstanceDeleteRequested>(_handleAssetInstanceDeleteRequested);
    on<InstanceCheckoutRequested>(_handleInstanceCheckoutRequested);
    on<InstanceCheckinRequested>(_handleInstanceCheckinRequested);
    on<InstanceMarkFoundRequested>(_handleInstanceMarkFoundRequested);
    on<AssetBulkInstancesLoaded>(_handleAssetBulkInstancesLoaded);
    on<AssetBulkCheckin>(_handleAssetBulkCheckin);
    on<AssetBulkCheckout>(_handleAssetBulkCheckout);
  }

  Future<void> _handleAssetCreateRequested(
    AssetCreateRequested event,
    Emitter<AssetsState> emit,
  ) async {
    try {
      emit(AssetCreateLoading());

      final response = await _assetsService.createAsset(
        assetData: event.assetData,
        imagePath: event.imagePath,
        documentPath: event.documentPath,
      );

      emit(AssetCreateSuccess(assetId: response['id']));
    } catch (e) {
      emit(AssetCreateFailure(message: e.toString()));
    }
  }

  Future<void> _handleAssetsRequested(
    AssetsRequested event,
    Emitter<AssetsState> emit,
  ) async {
    try {
      emit(AssetsLoading());

      final assets = await _assetsService.getAssets();

      emit(AssetsLoaded(assets: assets));
    } catch (e) {
      emit(AssetsLoadFailure(message: e.toString()));
    }
  }

  Future<void> _handleAssetsLoadByIdRequested(
    AssetsLoadByIdRequested event,
    Emitter<AssetsState> emit,
  ) async {
    try {
      emit(AssetsLoadByIdLoading());

      final asset = await _assetsService.getAssetById(event.assetId);
      emit(AssetsLoadByIdSuccess(asset: asset));
    } catch (e) {
      emit(AssetsLoadByIdFailure(message: e.toString()));
    }
  }

  Future<void> _handleAssetUpdateRequested(
    AssetUpdateRequested event,
    Emitter<AssetsState> emit,
  ) async {
    try {
      emit(AssetsLoadByIdLoading(message: 'Updating asset...'));

      await _assetsService.updateAsset(
        assetId: event.assetId,
        assetData: event.assetData,
        imagePath: event.imagePath,
      );

      try {
        final assets = await _assetsService.getAssets();
        emit(AssetsLoaded(assets: assets));
      } catch (e) {
        // Jika gagal reload, tetap emit success
        print('Failed to reload assets after update: $e');
      }

      emit(AssetsUpdatedSuccess(message: 'Asset updated successfully'));
    } catch (e) {
      emit(AssetsLoadByIdFailure(message: e.toString()));
    }
  }

  Future<void> _handleAssetDeleteRequested(
    AssetDeleteRequested event,
    Emitter<AssetsState> emit,
  ) async {
    try {
      emit(AssetsDeleteLoading());

      await _assetsService.deleteAsset(assetId: event.assetId);

      emit(AssetsDeleteSuccess(message: 'Asset deleted successfully'));

      // Auto-reload assets list setelah delete
      try {
        final assets = await _assetsService.getAssets();
        emit(AssetsLoaded(assets: assets));
      } catch (e) {
        print('Failed to reload assets after delete: $e');
      }
    } catch (e) {
      emit(AssetsDeleteFailure(message: e.toString()));
    }
  }

  Future<void> _handleAssetInstanceLoaded(
    AssetInstanceLoaded event,
    Emitter<AssetsState> emit,
  ) async {
    try {
      emit(AssetsLoadByIdLoading(message: 'Loading asset instances...'));

      final assetInstances = await _assetsService.searchAssets(
        event.assetId.toString(),
      );
      emit(AssetsInstancesLoaded(instances: assetInstances));
    } catch (e) {
      emit(AssetsLoadByIdFailure(message: e.toString()));
    }
  }

  Future<void> _handleAssetInstanceCreateRequested(
    AssetInstanceCreateRequested event,
    Emitter<AssetsState> emit,
  ) async {
    try {
      emit(AssetsLoadByIdLoading(message: 'Creating asset instance...'));

      await _assetsService.createAssetInstance(event.instanceData);

      // Auto-reload instances list setelah create
      try {
        final assetInstances = await _assetsService.searchAssets(
          event.instanceData['assetId'].toString(),
        );
        emit(AssetsInstancesLoaded(instances: assetInstances));
      } catch (e) {
        print('Failed to reload asset instances after create: $e');
      }

      emit(
        AssetsUpdatedSuccess(message: 'Asset instance created successfully'),
      );
    } catch (e) {
      emit(AssetsLoadByIdFailure(message: e.toString()));
    }
  }

  Future<void> _handleAssetInstanceUpdateRequested(
    AssetInstanceUpdateRequested event,
    Emitter<AssetsState> emit,
  ) async {
    try {
      emit(AssetsLoadByIdLoading(message: 'Updating asset instance...'));

      await _assetsService.editAssetInstance(
        instanceId: event.instanceId,
        instanceData: event.instanceData,
      );

      // Auto-reload instances list setelah update
      try {
        final assetInstances = await _assetsService.searchAssets(
          event.instanceData['assetId'].toString(),
        );
        emit(AssetsInstancesLoaded(instances: assetInstances));
      } catch (e) {
        print('Failed to reload asset instances after update: $e');
      }

      emit(
        AssetsUpdatedSuccess(message: 'Asset instance updated successfully'),
      );
    } catch (e) {
      emit(AssetsLoadByIdFailure(message: e.toString()));
    }
  }

  Future<void> _handleAssetInstanceDeleteRequested(
    AssetInstanceDeleteRequested event,
    Emitter<AssetsState> emit,
  ) async {
    try {
      emit(AssetsLoadByIdLoading(message: 'Deleting asset instance...'));

      await _assetsService.deleteAssetInstance(event.instanceId);

      emit(
        AssetsUpdatedSuccess(message: 'Asset instance deleted successfully'),
      );
    } catch (e) {
      emit(AssetsLoadByIdFailure(message: e.toString()));
    }
  }

  Future<void> _handleInstanceCheckoutRequested(
    InstanceCheckoutRequested event,
    Emitter<AssetsState> emit,
  ) async {
    try {
      emit(AssetsLoadByIdLoading(message: 'Checking out instance...'));

      await _assetsService.checkoutInstances(event.instanceId, event.jsonBody);

      emit(AssetsUpdatedSuccess(message: 'Instance checked out successfully'));
    } catch (e) {
      emit(AssetsLoadByIdFailure(message: e.toString()));
    }
  }

  Future<void> _handleInstanceCheckinRequested(
    InstanceCheckinRequested event,
    Emitter<AssetsState> emit,
  ) async {
    try {
      emit(AssetsLoadByIdLoading(message: 'Checking in instance...'));

      await _assetsService.checkinInstances(event.instanceId, event.jsonBody);

      emit(AssetsUpdatedSuccess(message: 'Instance checked in successfully'));
    } catch (e) {
      emit(AssetsLoadByIdFailure(message: e.toString()));
    }
  }

  Future<void> _handleInstanceMarkFoundRequested(
    InstanceMarkFoundRequested event,
    Emitter<AssetsState> emit,
  ) async {
    try {
      emit(AssetsLoadByIdLoading(message: 'Marking instance as found...'));

      await _assetsService.markAsFound(event.instanceId);

      emit(
        AssetsUpdatedSuccess(message: 'Instance marked as found successfully'),
      );
    } catch (e) {
      emit(AssetsLoadByIdFailure(message: e.toString()));
    }
  }

  Future<void> _handleAssetBulkInstancesLoaded(
    AssetBulkInstancesLoaded event,
    Emitter<AssetsState> emit,
  ) async {
    try {
      emit(AssetsBulkLoading(message: 'Loading bulk instances...'));

      final bulkData = await _assetsService.getBulkInstance(event.tab);

      emit(AssetsBulkLoadedSuccess(assets: [bulkData]));
    } catch (e) {
      emit(AssetsBulkLoadedFailure(message: e.toString()));
    }
  }

  Future<void> _handleAssetBulkCheckin(
    AssetBulkCheckin event,
    Emitter<AssetsState> emit,
  ) async {
    try {
      emit(AssetsBulkCheckinLoading(message: 'Processing bulk checkin...'));

      await _assetsService.bulkCheckin(event.jsonBody);

      emit(
        AssetsBulkCheckinSuccess(
          message: 'Bulk checkin completed successfully',
        ),
      );

      // Auto-reload bulk data after checkin
      try {
        final bulkData = await _assetsService.getBulkInstance('checkin');
        emit(AssetsBulkLoadedSuccess(assets: [bulkData]));
      } catch (e) {
        print('Failed to reload bulk data after checkin: $e');
      }
    } catch (e) {
      emit(AssetsBulkCheckinFailure(message: e.toString()));
    }
  }

  Future<void> _handleAssetBulkCheckout(
    AssetBulkCheckout event,
    Emitter<AssetsState> emit,
  ) async {
    try {
      emit(AssetsBulkCheckoutLoading(message: 'Processing bulk checkout...'));

      await _assetsService.bulkCheckout(event.jsonBody);

      emit(
        AssetsBulkCheckoutSuccess(
          message: 'Bulk checkout completed successfully',
        ),
      );

      // Auto-reload bulk data after checkout
      try {
        final bulkData = await _assetsService.getBulkInstance('checkout');
        emit(AssetsBulkLoadedSuccess(assets: [bulkData]));
      } catch (e) {
        print('Failed to reload bulk data after checkout: $e');
      }
    } catch (e) {
      emit(AssetsBulkCheckoutFailure(message: e.toString()));
    }
  }
}
