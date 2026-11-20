import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_exceptions.dart';
import '../data/vehicle_repository.dart';
import '../domain/vehicle.dart';
import 'vehicle_list_viewmodel.dart';

class VehicleFormState {
  final bool isSaving;
  final String? vehicleNumberError; // duplicate Vehicle Number
  final String? generalError;

  const VehicleFormState({this.isSaving = false, this.vehicleNumberError, this.generalError});
}

class VehicleFormViewModel extends AutoDisposeNotifier<VehicleFormState> {
  @override
  VehicleFormState build() => const VehicleFormState();

  /// Creates (id == null) or updates a vehicle. Returns true on success.
  Future<bool> save(Vehicle vehicle) async {
    state = const VehicleFormState(isSaving: true);
    final repo = ref.read(vehicleRepositoryProvider);
    try {
      if (vehicle.id == null) {
        await repo.create(vehicle);
      } else {
        await repo.update(vehicle);
      }
      ref.invalidate(vehicleListProvider);
      state = const VehicleFormState();
      return true;
    } on DuplicateVehicleException catch (e) {
      state = VehicleFormState(vehicleNumberError: e.message);
      return false;
    } on AppException catch (e) {
      state = VehicleFormState(generalError: e.message);
      return false;
    }
  }

  void clearVehicleNumberError() {
    if (state.vehicleNumberError != null) state = const VehicleFormState();
  }
}

final vehicleFormProvider =
    NotifierProvider.autoDispose<VehicleFormViewModel, VehicleFormState>(
        VehicleFormViewModel.new);
