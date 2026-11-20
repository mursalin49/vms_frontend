enum VehicleStatus {
  active('Active', 'ACTIVE'),
  inactive('Inactive', 'INACTIVE'),
  maintenance('Maintenance', 'MAINTENANCE');

  const VehicleStatus(this.label, this.apiValue);

  final String label;

  /// Value used by the REST API (Spring Boot enum name).
  final String apiValue;

  static VehicleStatus fromApi(String? value) {
    if (value == null || value.isEmpty) return VehicleStatus.active;
    final upper = value.trim().toUpperCase();
    return VehicleStatus.values.firstWhere(
      (s) => s.apiValue.toUpperCase() == upper || s.name.toUpperCase() == upper,
      orElse: () => VehicleStatus.active,
    );
  }
}
