import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/vehicle_repository.dart';
import '../domain/vehicle.dart';

/// Loads one vehicle for the Edit screen.
final vehicleDetailProvider = FutureProvider.autoDispose.family<Vehicle, int>(
  (ref, id) => ref.read(vehicleRepositoryProvider).getById(id),
);
