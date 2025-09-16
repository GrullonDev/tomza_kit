/// GpsService: obtiene posición (simulada) del dispositivo.
library;

class GpsService {
  Future<(double lat, double lng)> getCurrentPosition() async {
    // TODO: Integrar con geolocator/geocoding.
    return (19.4326, -99.1332); // CDMX
  }
}
