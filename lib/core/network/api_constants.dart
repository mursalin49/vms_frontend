/// API Configuration and Endpoints
/// 
/// Base URL can be configured via compile-time environment variable:
/// `flutter run --dart-define=API_BASE_URL=https://vms-backend-lioc.onrender.com`
class ApiConstants {
  ApiConstants._();

  /// Base URL of the backend server
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://vms-backend-lioc.onrender.com',
  );

  // -------------------------------------------------------------
  // Auth Endpoints
  // -------------------------------------------------------------
  /// POST /api/auth/login
  static const String login = '/api/auth/login';

  // -------------------------------------------------------------
  // Vehicle Endpoints
  // -------------------------------------------------------------
  /// GET /api/vehicles (List) | POST /api/vehicles (Create)
  static const String vehicles = '/api/vehicles';

  /// GET /api/vehicles/{id} | PUT /api/vehicles/{id} | DELETE /api/vehicles/{id}
  static String vehicleById(int id) => '/api/vehicles/$id';
}

