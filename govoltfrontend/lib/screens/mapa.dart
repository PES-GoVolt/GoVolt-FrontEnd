import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(41.303110065444294, 2.0025687347671783);
  
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps Sample App'),
        elevation: 2,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        markers: {_myLocMarker},
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 15.0,
        ),
      ),
    );
  }
}
