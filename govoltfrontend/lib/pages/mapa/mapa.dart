import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:govoltfrontend/services/geolocator_service.dart';

class Mapa extends StatefulWidget{
  Mapa({required this.initialPosition});

  final Position initialPosition;

  @override
  State<StatefulWidget> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  final GeolocatiorService geolocatiorService = GeolocatiorService();
  final Completer<GoogleMapController> _controller = Completer();
  
  @override
  void initState() {
    geolocatiorService.getCurrentLocation().listen((position){
        centerScreen(position);
    }); 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.initialPosition.latitude, widget.initialPosition.longitude)
          , zoom: 22.0),
          myLocationEnabled: true,
          onMapCreated: (GoogleMapController controller) {
             _controller.complete(controller);
          }),
        )
      );
  }

  Future<void> centerScreen(Position position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 22.0,
    )));
  }
}