import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/app_exceptions.dart';
import '../domain/vehicle.dart';
import 'vehicle_repository.dart';

/// REST API implementation of [VehicleRepository] connecting to:
/// `https://vms-backend-lioc.onrender.com`
class ApiVehicleRepository implements VehicleRepository {
  final ApiClient _client;

  ApiVehicleRepository({ApiClient? client}) : _client = client ?? ApiClient();

  /// GET /api/vehicles
  /// Returns a list of all vehicles
  @override
  Future<List<Vehicle>> getAll() async {
    final response = await _client.get(ApiConstants.vehicles);
    if (response is List) {
      return response
          .map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// GET /api/vehicles/{id}
  /// Retrieves a specific vehicle by its ID
  @override
  Future<Vehicle> getById(int id) async {
    final response = await _client.get(ApiConstants.vehicleById(id));
    if (response is Map<String, dynamic>) {
      return Vehicle.fromJson(response);
    }
    throw const NotFoundException();
  }

  /// POST /api/vehicles
  /// Creates a new vehicle record
  @override
  Future<Vehicle> create(Vehicle vehicle) async {
    final response = await _client.post(
      ApiConstants.vehicles,
      body: vehicle.toRequestBody(),
    );
    if (response is Map<String, dynamic>) {
      return Vehicle.fromJson(response);
    }
    return vehicle;
  }

  /// PUT /api/vehicles/{id}
  /// Updates an existing vehicle record
  @override
  Future<Vehicle> update(Vehicle vehicle) async {
    if (vehicle.id == null) {
      throw const NotFoundException('Cannot update vehicle without an ID');
    }
    final response = await _client.put(
      ApiConstants.vehicleById(vehicle.id!),
      body: vehicle.toRequestBody(),
    );
    if (response is Map<String, dynamic>) {
      return Vehicle.fromJson(response);
    }
    return vehicle;
  }

  /// DELETE /api/vehicles/{id}
  /// Deletes a vehicle by its ID (204 No Content)
  @override
  Future<void> delete(int id) async {
    await _client.delete(ApiConstants.vehicleById(id));
  }
}

