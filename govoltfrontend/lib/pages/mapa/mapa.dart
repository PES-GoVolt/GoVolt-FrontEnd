import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:govoltfrontend/blocs/application_bloc.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(41.303110065444294, 2.0025687347671783);
  final aplicationBloc = AplicationBloc();

  static const Marker _myLocMarker = Marker(
    markerId: MarkerId('_myLocMarker'),
    infoWindow: InfoWindow(title: "TEST"),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(41.303110065444294, 2.0025687347671783),
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  List<LatLng> points = [
    LatLng(41.38745590006128, 2.172276141806381),
    LatLng(41.30282101632336, 2.002613484100842)
  ];
  Set<Polyline> emptyRoute = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps Sample App'),
        elevation: 2,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            markers: {_myLocMarker},
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 15.0,
            ),
            polylines: aplicationBloc.route.routes.isNotEmpty? aplicationBloc.route.routes: emptyRoute,
          ),
          FloatingActionButton(
            backgroundColor: Color.fromRGBO(77, 94, 107, 1),
            onPressed: () async {
              aplicationBloc.calculateRoute(points);
              setState((){});
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ],
      ),
    );
  }
}
