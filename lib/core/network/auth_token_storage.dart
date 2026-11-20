/// In-memory storage for JWT / Auth bearer token.
class AuthTokenStorage {
  static final AuthTokenStorage _instance = AuthTokenStorage._internal();
  factory AuthTokenStorage() => _instance;
  AuthTokenStorage._internal();

  String? _token;
  String? _email;

  /// Currently active auth token (Bearer)
  String? get token => _token;

  /// Currently signed in email
  String? get email => _email;

  /// Returns true if an active token exists
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  /// Save active token and email
  void saveAuth({required String token, String? email}) {
    _token = token;
    if (email != null && email.isNotEmpty) {
      _email = email;
    }
  }

  /// Clear token on logout
  void clear() {
    _token = null;
    _email = null;
  }
}

