import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import 'package:govoltfrontend/services/routes_service.dart';

class AplicationBloc with ChangeNotifier {
  final routeService = RouteService();
  MapsRoutes route = new MapsRoutes();

  calculateRoute(List<LatLng> points) async {
    routeService.getRoute(points, route);
  }

}
