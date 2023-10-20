import 'package:geolocator/geolocator.dart';

class GeolocatiorService {
  Stream<Position> getCurrentLocation() {
    var locationOptions = const LocationSettings(
        accuracy: LocationAccuracy.best, distanceFilter: 2);
    return Geolocator.getPositionStream(locationSettings: locationOptions);
  }

  Future<Position> getInitialLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      // El usuario rechazó los permisos de ubicación, puedes manejarlo aquí.
    }
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
