import 'dart:math' as math;

/// Utilidades de ubicación.
class LocationUtils {
  /// Calcula distancia aproximada en kilómetros usando Haversine.
  static double distanceKm(
    (double lat, double lng) a,
    (double lat, double lng) b,
  ) {
    const r = 6371.0; // radio de la Tierra en km
    double toRad(double d) => d * (math.pi / 180.0);
    final dLat = toRad(b.$1 - a.$1);
    final dLon = toRad(b.$2 - a.$2);
    final lat1 = toRad(a.$1);
    final lat2 = toRad(b.$1);

    final sinDLat = math.sin(dLat / 2);
    final sinDLon = math.sin(dLon / 2);
    final h =
        sinDLat * sinDLat + math.cos(lat1) * math.cos(lat2) * sinDLon * sinDLon;
    final c = 2 * math.asin(math.min(1, math.sqrt(h)));
    return r * c;
  }
}
