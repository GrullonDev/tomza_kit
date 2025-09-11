/// Preferences: preferencias simples en memoria.
library;

class Preferences {
  final Map<String, Object?> _prefs = {};

  Future<void> setString(String key, String value) async => _prefs[key] = value;
  Future<void> setBool(String key, bool value) async => _prefs[key] = value;
  Future<void> setInt(String key, int value) async => _prefs[key] = value;

  String? getString(String key) => _prefs[key] as String?;
  bool? getBool(String key) => _prefs[key] as bool?;
  int? getInt(String key) => _prefs[key] as int?;
}
