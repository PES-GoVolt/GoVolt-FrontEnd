import 'package:google_maps_routes/google_maps_routes.dart';

class RouteVolt {
  MapsRoutes carRoute = MapsRoutes();
  MapsRoutes bicycleRoute = MapsRoutes();
  MapsRoutes walkingRoute = MapsRoutes();
  MapsRoutes tempRouteToCharger = MapsRoutes();
  List<MapsRoutes> routeList = [];
  int i = 0;
  String distance = "0";

  RouteVolt() {
    routeList = [carRoute, bicycleRoute, walkingRoute, tempRouteToCharger];
  }
}
