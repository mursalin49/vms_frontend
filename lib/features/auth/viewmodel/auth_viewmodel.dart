import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_exceptions.dart';
import '../../../core/network/auth_token_storage.dart';
import '../data/auth_repository.dart';

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? email;
  final String? error;

  const AuthState({this.isLoggedIn = false, this.isLoading = false, this.email, this.error});
}

class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> login(String email, String password) async {
    state = const AuthState(isLoading: true);
    try {
      final signedInEmail = await ref.read(authRepositoryProvider).login(email, password);
      state = AuthState(isLoggedIn: true, email: signedInEmail);
      return true;
    } on AppException catch (e) {
      state = AuthState(error: e.message);
      return false;
    }
  }

  void logout() {
    AuthTokenStorage().clear();
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);
