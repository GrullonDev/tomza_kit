/// AuthService: interfaz y una implementación simple en memoria.
library;

abstract class AuthService {
  Future<bool> signIn({required String username, required String password});
  Future<void> signOut();
  bool get isAuthenticated;
  String? get currentUserId;
}

class InMemoryAuthService implements AuthService {
  bool _loggedIn = false;
  String? _userId;

  @override
  bool get isAuthenticated => _loggedIn;

  @override
  String? get currentUserId => _userId;

  @override
  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    // TODO: Reemplazar con lógica real de autenticación/integración.
    _loggedIn = username.isNotEmpty && password.isNotEmpty;
    _userId = _loggedIn ? username : null;
    return _loggedIn;
  }

  @override
  Future<void> signOut() async {
    _loggedIn = false;
    _userId = null;
  }
}
