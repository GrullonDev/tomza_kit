/// SessionManager: manejo de sesión simple con token en memoria.
library;

class SessionManager {
  String? _token;
  DateTime? _expiry;

  bool get hasValidSession =>
      _token != null && (_expiry == null || _expiry!.isAfter(DateTime.now()));

  String? get token => _token;

  void saveToken(String token, {Duration? ttl}) {
    _token = token;
    _expiry = ttl != null ? DateTime.now().add(ttl) : null;
  }

  void clear() {
    _token = null;
    _expiry = null;
  }
}
