/// App-level exceptions. Repositories throw these; ViewModels turn them into state.
/// When the REST API is added, the API repository maps HTTP errors to the same exceptions
/// (409 -> DuplicateVehicleException, 401 -> InvalidCredentialsException, ...).
class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => message;
}

class DuplicateVehicleException extends AppException {
  const DuplicateVehicleException() : super('This vehicle number already exists.');
}

class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException([super.message = 'Invalid email or password']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized: Access is denied.']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Vehicle not found.']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred. Please try again later.']);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Cannot reach the server. Check your connection and retry.']);
}
