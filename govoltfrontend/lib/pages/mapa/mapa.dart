import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng? currentLocation;
  final LatLng _center = const LatLng(41.303110065444294, 2.0025687347671783);

  Future<Position> getCurrentLocation() async{
    LocationPermission permission;
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied){
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied){
          return Future.error('error');
        }
      }
      return Geolocator.getCurrentPosition();
  }

  void getCurrentPosition() async {
    Position position = await getCurrentLocation();
    LatLng ubication = LatLng(position.latitude, position.longitude);
    setState((){
      currentLocation = ubication;
    });
    print(currentLocation!.latitude);
  }

  static const Marker _myLocMarker = Marker(
    markerId: MarkerId('_myLocMarker'),
    infoWindow: InfoWindow(title: "TEST"),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(41.303110065444294, 2.0025687347671783),
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState(){
    getCurrentPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps Sample App'),
        elevation: 2,
      ),
      body: currentLocation == null ? const Center(child: Text("Loading")) : 
      GoogleMap(
        onMapCreated: _onMapCreated,
        markers: {_myLocMarker,
        Marker(
          markerId: const MarkerId("currentPosition"),
          position: LatLng(currentLocation!.latitude, currentLocation!.longitude)
        )},
        initialCameraPosition: CameraPosition(
          target: LatLng(currentLocation!.latitude, currentLocation!.longitude),
          zoom: 15.0,
        ),
      ),
    );
  }
}
