import '../../../core/network/app_exceptions.dart';
import '../domain/vehicle.dart';
import '../domain/vehicle_status.dart';
import 'vehicle_repository.dart';

/// In-memory repository with the same business rules the backend will enforce.
class MockVehicleRepository implements VehicleRepository {
  final List<Vehicle> _items = [
    const Vehicle(id: 1, vehicleNumber: 'DHK-METRO-1021', company: 'Stark Logistics', type: 'Truck', brand: 'Tata', model: 'Prima', status: VehicleStatus.active),
    const Vehicle(id: 2, vehicleNumber: 'DHK-METRO-2044', company: 'Stark Transport', type: 'Van', brand: 'Toyota', model: 'HiAce', status: VehicleStatus.active),
    const Vehicle(id: 3, vehicleNumber: 'CTG-KA-3310', company: 'Stark Logistics', type: 'Pickup', brand: 'Isuzu', model: 'D-Max', status: VehicleStatus.inactive),
    const Vehicle(id: 4, vehicleNumber: 'DHK-GA-4581', company: 'Stark Motors', type: 'Car', brand: 'Honda', model: 'Civic', status: VehicleStatus.maintenance),
    const Vehicle(id: 5, vehicleNumber: 'SYL-HA-5002', company: 'Stark Transport', type: 'Bus', brand: 'Hino', model: 'RK8', status: VehicleStatus.active),
  ];
  int _nextId = 6;

  Future<void> _latency() => Future<void>.delayed(const Duration(milliseconds: 400));
  String _normalize(String s) => s.trim().toUpperCase();

  bool _exists(String number, {int? exceptId}) => _items.any(
        (v) => v.vehicleNumber.toUpperCase() == number && v.id != exceptId,
      );

  @override
  Future<List<Vehicle>> getAll() async {
    await _latency();
    return List.unmodifiable(_items);
  }

  @override
  Future<Vehicle> getById(int id) async {
    await _latency();
    return _items.firstWhere((v) => v.id == id, orElse: () => throw const NotFoundException());
  }

  @override
  Future<Vehicle> create(Vehicle vehicle) async {
    await _latency();
    final number = _normalize(vehicle.vehicleNumber);
    if (_exists(number)) throw const DuplicateVehicleException();
    final created = vehicle.copyWith(id: _nextId++, vehicleNumber: number);
    _items.add(created);
    return created;
  }

  @override
  Future<Vehicle> update(Vehicle vehicle) async {
    await _latency();
    final index = _items.indexWhere((v) => v.id == vehicle.id);
    if (index < 0) throw const NotFoundException();
    final number = _normalize(vehicle.vehicleNumber);
    if (_exists(number, exceptId: vehicle.id)) throw const DuplicateVehicleException();
    final updated = vehicle.copyWith(vehicleNumber: number);
    _items[index] = updated;
    return updated;
  }

  @override
  Future<void> delete(int id) async {
    await _latency();
    final before = _items.length;
    _items.removeWhere((v) => v.id == id);
    if (_items.length == before) throw const NotFoundException();
  }
}
