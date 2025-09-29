// Generic JSON parsing helpers used across the project.
// Provides `parse<T>` and `parseNullable<T>` to safely convert dynamic
// values from JSON into typed Dart values.

T parse<T>(dynamic value, {required T fallback}) {
  if (value == null) return fallback;
  if (value is T) return value;

  if (T == int) {
    if (value is num) return value.toInt() as T;
    if (value is String) {
      return (int.tryParse(value) ??
              double.tryParse(value)?.toInt() ??
              fallback)
          as T;
    }
  }

  if (T == double) {
    if (value is num) return value.toDouble() as T;
    if (value is String) return (double.tryParse(value) ?? fallback) as T;
  }

  if (T == String) {
    return value.toString() as T;
  }

  if (T == bool) {
    if (value is bool) return value as T;
    if (value is String) {
      final v = value.toLowerCase();
      if (v == 'true' || v == '1') return true as T;
      if (v == 'false' || v == '0') return false as T;
    }
    if (value is num) return (value != 0) as T;
  }

  try {
    return value as T;
  } catch (_) {
    return fallback;
  }
}

T? parseNullable<T>(dynamic value) {
  if (value == null) return null;
  if (value is T) return value;

  if (T == int) {
    if (value is num) {
      return value.toInt() as T;
    }
    if (value is String) {
      return (int.tryParse(value) ?? double.tryParse(value)?.toInt()) as T?;
    }
  }

  if (T == double) {
    if (value is num) return value.toDouble() as T;
    if (value is String) return double.tryParse(value) as T?;
  }

  if (T == String) return value.toString() as T;

  if (T == bool) {
    if (value is bool) return value as T;
    if (value is String) {
      final v = value.toLowerCase();
      if (v == 'true' || v == '1') return true as T;
      if (v == 'false' || v == '0') return false as T;
    }
    if (value is num) return (value != 0) as T;
  }

  try {
    return value as T;
  } catch (_) {
    return null;
  }
}
