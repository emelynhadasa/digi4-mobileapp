import 'package:bloc/bloc.dart';
import 'package:digi4_mobile/models/locator_model.dart';
import 'package:digi4_mobile/services/locator_service.dart';
import 'package:meta/meta.dart';
import 'dart:io';

part 'locator_event.dart';
part 'locator_state.dart';

class LocatorBloc extends Bloc<LocatorEvent, LocatorState> {
  final LocatorService _locatorService = LocatorService();
  LocatorBloc() : super(LocatorInitial()) {
    on<LoadPlants>(_handleLoadPlants);
    on<AddPlant>(_handleAddPlant);
    on<EditPlant>(_handleEditPlant);
    on<GetCabinets>(_handleGetCabinets);
    on<EditCabinet>(_handleEditCabinet);
    on<AddCabinet>(_handleAddCabinet);
    on<GetShelves>(_handleGetShelves);
    on<EditShelf>(_handleEditShelf);
    on<AddShelf>(_handleAddShelf);
    on<GetInstances>(_handleGetInstances);
    on<MoveInstance>(_handleMoveInstance);
  }

  Future<void> _handleLoadPlants(
    LoadPlants event,
    Emitter<LocatorState> emit,
  ) async {
    emit(PlantsLoading());
    try {
      final plants = await _locatorService.getPlants();
      emit(PlantsLoadedSuccess(plants));
      for (var p in plants) {
        print('Plant, after plantsloadedsuccess: ${p.plantId}, ${p.plantName}, ${p.address}');
      }
    } catch (e) {
      emit(PlantsLoadedFailure(e.toString()));
    }
  }

  Future<void> _handleAddPlant(
    AddPlant event,
    Emitter<LocatorState> emit,
  ) async {
    emit(AddPlantLoading());
    try {
      await _locatorService.addPlant(event.plantName, event.address);
      final updatedPlants = await _locatorService.getPlants();
      emit(PlantsLoadedSuccess(updatedPlants));
      emit(AddPlantSuccess("Plant added successfully"));
    } catch (e) {
      emit(AddPlantFailure(e.toString()));
    }
  }

  Future<void> _handleEditPlant(
    EditPlant event,
    Emitter<LocatorState> emit,
  ) async {
    emit(EditPlantLoading());
    try {
      await _locatorService.editPlant(
        event.plantId,
        event.plantName,
        event.address,
      );
      emit(EditPlantSuccess("Plant updated successfully"));
    } catch (e) {
      emit(EditPlantFailure(e.toString()));
    }
  }

  Future<void> _handleGetCabinets(
    GetCabinets event,
    Emitter<LocatorState> emit,
  ) async {
    emit(PlantsLoading());
    try {
      final cabinets = await _locatorService.getCabinets(event.plantId);
      emit(GetCabinetsSuccess(cabinets));
    } catch (e) {
      emit(GetCabinetsFailure(e.toString()));
    }
  }

  Future<void> _handleEditCabinet(
    EditCabinet event,
    Emitter<LocatorState> emit,
  ) async {
    emit(EditCabinetLoading());
    try {
      await _locatorService.editCabinet(
        event.cabinetId,
        // event.plantId,
        event.cabinetName,
        event.cabinetType,
        event.imageFile,
      );
      emit(EditCabinetSuccess("edit successfully"));
    } catch (e) {
      emit(EditCabinetFailure(e.toString()));
    }
  }

  Future<void> _handleAddCabinet(
      AddCabinet event,
      Emitter<LocatorState> emit,
      ) async {
    emit(AddCabinetLoading());
    try {
      await _locatorService.createCabinet(
        int.parse(event.plantId),
        event.cabinetName,
        event.cabinetType,
        event.shelfCount,
        event.labelMode,
        event.manualLabelsList,
        event.imageFile,// <-- pakai List<String> di sini
      );
      emit(AddCabinetSuccess("Added successfully"));
    } catch (e) {
      emit(AddCabinetFailure(e.toString()));
    }
  }

  Future<void> _handleGetShelves(
    GetShelves event,
    Emitter<LocatorState> emit,
  ) async {
    emit(GetShelvesLoading());
    try {
      final shelves = await _locatorService.getShelves(
        int.parse(event.cabinetId),
      );
      emit(GetShelvesSuccess(shelves));
    } catch (e) {
      emit(GetShelvesFailure(e.toString()));
    }
  }

  Future<void> _handleEditShelf(
    EditShelf event,
    Emitter<LocatorState> emit,
  ) async {
    emit(EditShelfLoading());
    try {
      await _locatorService.editShelf(
        event.shelfId,
        event.cabinetId,
        event.shelfLabel,
      );
      emit(EditShelfSuccess("edit successfully"));
    } catch (e) {
      emit(EditShelfFailure(e.toString()));
    }
  }

  Future<void> _handleAddShelf(
    AddShelf event,
    Emitter<LocatorState> emit,
  ) async {
    emit(AddShelfLoading());
    try {
      await _locatorService.addShelf(
        int.parse(event.cabinetId),
        event.shelfLabel,
      );
      emit(AddShelfSuccess("add successfully"));
    } catch (e) {
      emit(AddShelfFailure(e.toString()));
    }
  }

  Future<void> _handleGetInstances(
    GetInstances event,
    Emitter<LocatorState> emit,
  ) async {
    emit(GetInstancesLoading());
    try {
      final instances = await _locatorService.getInstances(
        int.parse(event.shelfId),
      );
      emit(GetInstancesSuccess(instances));
    } catch (e) {
      emit(GetInstancesFailure(e.toString()));
    }
  }

  Future<void> _handleMoveInstance(
    MoveInstance event,
    Emitter<LocatorState> emit,
  ) async {
    emit(MoveInstanceLoading());
    try {
      await _locatorService.moveInstances(
        event.instanceId,
        event.shelfId,
      );
      emit(MoveInstanceSuccess("move successfully"));
    } catch (e) {
      emit(MoveInstanceFailure(e.toString()));
    }
  }
}
