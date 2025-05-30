part of 'locator_bloc.dart';

@immutable
sealed class LocatorState {}

final class LocatorInitial extends LocatorState {}

class PlantsLoadedSuccess extends LocatorState {
  final List<Plants> plants;

  PlantsLoadedSuccess(this.plants);
}

class PlantsLoadedFailure extends LocatorState {
  final String error;

  PlantsLoadedFailure(this.error);
}

class PlantsLoading extends LocatorState {}

class AddPlantSuccess extends LocatorState {
  final String message;

  AddPlantSuccess(this.message);
}

class AddPlantFailure extends LocatorState {
  final String error;

  AddPlantFailure(this.error);
}

class AddPlantLoading extends LocatorState {}

class EditPlantSuccess extends LocatorState {
  final String message;

  EditPlantSuccess(this.message);
}

class EditPlantFailure extends LocatorState {
  final String error;

  EditPlantFailure(this.error);
}

class EditPlantLoading extends LocatorState {}

class GetCabinetsSuccess extends LocatorState {
  final List<Cabinet> cabinets;

  GetCabinetsSuccess(this.cabinets);
}

class GetCabinetsFailure extends LocatorState {
  final String error;

  GetCabinetsFailure(this.error);
}

class GetCabinetsLoading extends LocatorState {}

class AddCabinetSuccess extends LocatorState {
  final String message;

  AddCabinetSuccess(this.message);
}

class AddCabinetFailure extends LocatorState {
  final String error;

  AddCabinetFailure(this.error);
}

class AddCabinetLoading extends LocatorState {}

class EditCabinetSuccess extends LocatorState {
  final String message;

  EditCabinetSuccess(this.message);
}

class EditCabinetFailure extends LocatorState {
  final String error;

  EditCabinetFailure(this.error);
}

class GetShelvesSuccess extends LocatorState {
  final List<Shelf> shelves;

  GetShelvesSuccess(this.shelves);
}

class GetShelvesFailure extends LocatorState {
  final String error;

  GetShelvesFailure(this.error);
}

class GetShelvesLoading extends LocatorState {}

class EditShelfSuccess extends LocatorState {
  final String message;

  EditShelfSuccess(this.message);
}

class EditShelfFailure extends LocatorState {
  final String error;

  EditShelfFailure(this.error);
}

class EditShelfLoading extends LocatorState {}

class AddShelfSuccess extends LocatorState {
  final String message;

  AddShelfSuccess(this.message);
}

class AddShelfFailure extends LocatorState {
  final String error;

  AddShelfFailure(this.error);
}

class AddShelfLoading extends LocatorState {}

class GetInstancesSuccess extends LocatorState {
  final List<Instances> instances;

  GetInstancesSuccess(this.instances);
}

class GetInstancesFailure extends LocatorState {
  final String error;

  GetInstancesFailure(this.error);
}

class GetInstancesLoading extends LocatorState {}

class MoveInstanceSuccess extends LocatorState {
  final String message;

  MoveInstanceSuccess(this.message);
}
class MoveInstanceFailure extends LocatorState {
  final String error;

  MoveInstanceFailure(this.error);
}

class MoveInstanceLoading extends LocatorState {}

class EditCabinetLoading extends LocatorState {}
