import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
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
  bool showRouteDetails = false;
  String routeDistance = '0';

  Widget buildRouteDetailsContainer() {
  return Stack(
    children: [
      Positioned(
        top: 35,
        left: 10,
        right: 10,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 25),
              buildRouteModeButtonsRow(),
              const SizedBox(height: 10),
              buildRouteLocationRow(Icons.location_searching, "Your ubication"),
              const SizedBox(height: 10),
              buildRouteLocationRow(Icons.location_on, "Coordenadas Buscadas"),
              const SizedBox(height: 10),
              buildRouteDistanceText(),
            ],
          ),
        ),
      ),
      buildRouteCloseButton(),
    ],
  );
}

Widget buildRouteModeButtonsRow() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      buildRouteModeButton(Icons.directions_car, "Car", 0),
      buildRouteModeButton(Icons.directions_bike, "Bicycle", 1),
      buildRouteModeButton(Icons.directions_walk, "Walking", 2),
    ],
  );
}

Widget buildRouteModeButton(IconData icon, String label, int mode) {
  return ElevatedButton(
    onPressed: () async {
      await aplicationBloc.changePointer(mode);
      setState(() {});
    },
    child: Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(label),
      ],
    ),
  );
}

Widget buildRouteLocationRow(IconData icon, String labelText) {
  return Row(
    children: [
      Icon(icon),
      const SizedBox(width: 8),
      Expanded(
        child: InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          child: Text(
            labelText,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    ],
  );
}

Widget buildRouteDistanceText() {
  return Container(
    alignment: Alignment.centerRight,
    child: Text(
      "Distancia: ${routeDistance.toString()}",
      style: const TextStyle(
        color: Color.fromRGBO(96, 151, 128, 1),
        fontSize: 16,
      ),
    ),
  );
}

Widget buildRouteCloseButton() {
  return Positioned(
    top: 30,
    right: 10,
    child: IconButton(
      icon: const Icon(Icons.close),
      onPressed: () {
        setState(() {
          showRouteDetails = false;
          aplicationBloc.cleanRoute();
        });
      },
    ),
  );
}

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
            polylines: aplicationBloc.routevolt.routeList[aplicationBloc.routevolt.i].routes.isNotEmpty
                ? aplicationBloc.routevolt.routeList[aplicationBloc.routevolt.i].routes
                : emptyRoute,
          ),
          if (showRouteDetails) buildRouteDetailsContainer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: FloatingActionButton(
                    backgroundColor: Color.fromRGBO(77, 94, 107, 1),
                    onPressed: () async {
                      await aplicationBloc.calculateRoute( points);
                      setState(() {
                        showRouteDetails = true;
                        routeDistance = aplicationBloc.calculateRouteDistance(points);
                      });
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
