import 'package:geolocator/geolocator.dart';

class GeolocatiorService {

  Stream<Position> getCurrentLocation(){
    var locationOptions = const LocationSettings(
      accuracy: LocationAccuracy.best, 
      distanceFilter: 2);
      return Geolocator.getPositionStream(locationSettings: locationOptions);
  }

  Future<Position> getInitialLocation() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}