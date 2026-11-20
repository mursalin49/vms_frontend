import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/auth_token_storage.dart';
import 'auth_repository.dart';

/// REST API implementation of [AuthRepository] connecting to:
/// `POST https://vms-backend-lioc.onrender.com/api/auth/login`
class ApiAuthRepository implements AuthRepository {
  final ApiClient _client;

  ApiAuthRepository({ApiClient? client}) : _client = client ?? ApiClient();

  @override
  Future<String> login(String email, String password) async {
    final requestBody = {
      'email': email.trim(),
      'password': password,
    };

    final response = await _client.post(
      ApiConstants.login,
      body: requestBody,
    );

    String? token;
    String userEmail = email.trim();

    if (response is Map<String, dynamic>) {
      // Check common token keys from backend responses
      token = response['token']?.toString() ??
          response['accessToken']?.toString() ??
          response['jwt']?.toString() ??
          response['id_token']?.toString() ??
          (response['data'] is Map ? response['data']['token']?.toString() : null);

      if (response['email'] != null) {
        userEmail = response['email'].toString();
      }
    } else if (response is String && response.isNotEmpty) {
      token = response;
    }

    // Save token for subsequent authorized API calls
    if (token != null && token.isNotEmpty) {
      AuthTokenStorage().saveAuth(token: token, email: userEmail);
    } else {
      // In case the backend returns empty body or session cookie
      AuthTokenStorage().saveAuth(token: 'active_session', email: userEmail);
    }

    return userEmail;
  }
}

