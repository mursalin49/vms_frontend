import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/vehicle_repository.dart';
import '../domain/vehicle.dart';

class VehicleListViewModel extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() => ref.read(vehicleRepositoryProvider).getAll();

  /// Throws an [AppException] on failure; the view shows it in a snackbar.
  Future<void> delete(int id) async {
    final repo = ref.read(vehicleRepositoryProvider);
    await repo.delete(id);
    state = AsyncData(await repo.getAll());
  }
}

final vehicleListProvider =
    AsyncNotifierProvider<VehicleListViewModel, List<Vehicle>>(VehicleListViewModel.new);
