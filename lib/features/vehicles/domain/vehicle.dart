import 'vehicle_status.dart';

class Vehicle {
  final int? id;
  final String vehicleNumber;
  final String company;
  final String type;
  final String brand;
  final String model;
  final VehicleStatus status;

  const Vehicle({
    this.id,
    required this.vehicleNumber,
    required this.company,
    required this.type,
    required this.brand,
    required this.model,
    required this.status,
  });

  /// Factory constructor to parse JSON received from the REST API
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    int? parsedId;
    if (rawId is num) {
      parsedId = rawId.toInt();
    } else if (rawId != null) {
      parsedId = int.tryParse(rawId.toString());
    }

    return Vehicle(
      id: parsedId,
      vehicleNumber: json['vehicleNumber']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      status: VehicleStatus.fromApi(json['status']?.toString()),
    );
  }

  /// Converts the model to JSON (including id if present)
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'vehicleNumber': vehicleNumber,
        'company': company,
        'type': type,
        'brand': brand,
        'model': model,
        'status': status.apiValue,
      };

  /// Body payload for POST (/api/vehicles) and PUT (/api/vehicles/{id})
  Map<String, dynamic> toRequestBody() => {
        'vehicleNumber': vehicleNumber,
        'company': company,
        'type': type,
        'brand': brand,
        'model': model,
        'status': status.apiValue,
      };

  Vehicle copyWith({
    int? id,
    String? vehicleNumber,
    String? company,
    String? type,
    String? brand,
    String? model,
    VehicleStatus? status,
  }) =>
      Vehicle(
        id: id ?? this.id,
        vehicleNumber: vehicleNumber ?? this.vehicleNumber,
        company: company ?? this.company,
        type: type ?? this.type,
        brand: brand ?? this.brand,
        model: model ?? this.model,
        status: status ?? this.status,
      );
}
