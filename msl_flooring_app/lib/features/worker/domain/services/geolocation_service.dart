// lib/features/worker/domain/services/geolocation_service.dart

import 'package:geolocator/geolocator.dart';

// Una clase simple para encapsular la lógica de geolocalización.
class GeolocationService {
  // Obtiene la posición actual del dispositivo.
  // Maneja la solicitud de permisos y devuelve la posición.
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verifica si los servicios de ubicación están habilitados.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Si no están habilitados, lanza un error.
      return Future.error('Los servicios de ubicación están deshabilitados.');
    }

    // 2. Verifica los permisos actuales.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Si los permisos están denegados, los solicita.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Si el usuario vuelve a denegar, lanza un error.
        return Future.error('Los permisos de ubicación fueron denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Si los permisos están denegados permanentemente, lanza un error.
      return Future.error(
          'Los permisos de ubicación están denegados permanentemente, no podemos solicitar permisos.');
    }

    // 3. Si los permisos son correctos, obtiene y devuelve la posición.
    return await Geolocator.getCurrentPosition();
  }
}