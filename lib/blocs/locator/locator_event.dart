part of 'locator_bloc.dart';

@immutable
sealed class LocatorEvent {}

class LoadPlants extends LocatorEvent {}

class AddPlant extends LocatorEvent {
  final String plantName;
  final String address;

  AddPlant({required this.plantName, required this.address});
}

class EditPlant extends LocatorEvent {
  final int plantId;
  final String plantName;
  final String address;

  EditPlant({
    required this.plantId,
    required this.plantName,
    required this.address,
  });
}

class GetCabinets extends LocatorEvent {
  final String plantId;

  GetCabinets({required this.plantId});
}

class EditCabinet extends LocatorEvent {
  final int cabinetId;
  final String plantId;
  final String cabinetName;
  final String cabinetType;
  final File? imageFile;

  EditCabinet({
    required this.cabinetId,
    required this.plantId,
    required this.cabinetName,
    required this.cabinetType,
    this.imageFile,
  });
}

class AddCabinet extends LocatorEvent {
  final String plantId;
  final String cabinetName;
  final String cabinetType;
  final String labelMode;
  final int shelfCount;
  final List<String>? manualLabelsList;
  final File? imageFile;

  AddCabinet({
    required this.plantId,
    required this.cabinetName,
    required this.cabinetType,
    required this.shelfCount,
    required this.labelMode,
    this.manualLabelsList,
    this.imageFile,
  });
}

class GetShelves extends LocatorEvent {
  final String cabinetId;

  GetShelves({required this.cabinetId});
}

class AddShelf extends LocatorEvent {
  final String cabinetId;
  final String shelfLabel;

  AddShelf({required this.cabinetId, required this.shelfLabel});
}

class EditShelf extends LocatorEvent {
  final int shelfId;
  final int cabinetId;
  final String shelfLabel;

  EditShelf({required this.shelfId, required this.shelfLabel,required this.cabinetId});
}

class GetInstances extends LocatorEvent {
  final String shelfId;

  GetInstances({required this.shelfId});
}

class MoveInstance extends LocatorEvent {
  final int instanceId;
  final int shelfId;

  MoveInstance({required this.instanceId, required this.shelfId});
}

class RefreshPlants extends LocatorEvent {}
