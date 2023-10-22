import 'dart:io';

import 'package:geolocator/geolocator.dart';

class GeolocatiorService {
  Stream<Position> getCurrentLocation() {
    var locationOptions = const LocationSettings(
        accuracy: LocationAccuracy.best, distanceFilter: 2);
    askForPermissions();
    return Geolocator.getPositionStream(locationSettings: locationOptions);
  }

  Future<LocationPermission> askForPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Geolocator.openLocationSettings();
        exit(0);
      }
    }
    return permission;
  }
}
