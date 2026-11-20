import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_exceptions.dart';
import 'api_auth_repository.dart';

abstract class AuthRepository {
  /// Returns the signed-in user's email, or throws [InvalidCredentialsException].
  Future<String> login(String email, String password);
}

/// Mock login (for offline development/testing)
class MockAuthRepository implements AuthRepository {
  static const _email = 'admin@starkgroup.com';
  static const _password = 'Admin@123';

  @override
  Future<String> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (email.trim().toLowerCase() == _email && password == _password) {
      return _email;
    }
    throw const InvalidCredentialsException();
  }
}

/// Active auth provider connected to the REST API:
/// POST https://vms-backend-lioc.onrender.com/api/auth/login
final authRepositoryProvider =
    Provider<AuthRepository>((ref) => ApiAuthRepository());
