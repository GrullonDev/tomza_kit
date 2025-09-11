/// SecureStorage: almacenamiento simulado (en memoria) para secretos.
library;

class SecureStorage {
  final Map<String, String> _store = {};

  Future<void> write(String key, String value) async {
    _store[key] = value;
  }

  Future<String?> read(String key) async => _store[key];

  Future<void> delete(String key) async {
    _store.remove(key);
  }
}
