import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/vehicle.dart';
import 'api_vehicle_repository.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getAll();
  Future<Vehicle> getById(int id);

  /// Throws [DuplicateVehicleException] when the Vehicle Number already exists.
  Future<Vehicle> create(Vehicle vehicle);

  /// Throws [DuplicateVehicleException] / [NotFoundException].
  Future<Vehicle> update(Vehicle vehicle);

  Future<void> delete(int id);
}

/// Switched to ApiVehicleRepository connected to the REST API:
/// https://vms-backend-lioc.onrender.com/api/vehicles
/// To test offline without backend, replace with MockVehicleRepository()
final vehicleRepositoryProvider =
    Provider<VehicleRepository>((ref) => ApiVehicleRepository());
