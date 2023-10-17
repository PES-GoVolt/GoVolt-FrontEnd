import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyWidgetScreen extends StatefulWidget {
  const MyWidgetScreen({Key? key}) : super(key: key);

  @override
  State<MyWidgetScreen> createState() => _MyWidgetScreenState();
}

class _MyWidgetScreenState extends State<MyWidgetScreen> {
  final GeolocatorPlatform geolocator = GeolocatorPlatform.instance;
  Stream<Position> positionStream = Geolocator.getPositionStream();

  Future<Position> determinedPosition() async {
    LocationPermission permission;
    permission = await geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('error');
      }
    }
    const LocationSettings options = LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 10);
    return await geolocator.getCurrentPosition(locationSettings : options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Geolocator"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: StreamBuilder<Position>(
          stream: positionStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                final position = snapshot.data!;
                final ubication = LatLng(position.latitude, position.longitude);

                // Actualiza la interfaz de usuario con la nueva ubicación
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Lat: ${ubication.latitude}'),
                    Text('Lng: ${ubication.longitude}'),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
            }
            // Muestra un mensaje de "Cargando" mientras se obtiene la ubicación
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
