import 'package:flutter/material.dart';
import 'package:govoltfrontend/models/mapa/place.dart';
import 'package:govoltfrontend/models/place_search.dart';
import 'package:govoltfrontend/services/places_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import 'package:govoltfrontend/services/routes_service.dart';
import 'package:govoltfrontend/models/route.dart';

class AplicationBloc with ChangeNotifier {
  final placesService = PlacesService();
  final routeService = RouteService();
  RouteVolt routevolt = RouteVolt();
  DistanceCalculator distanceCalculator = DistanceCalculator();
  List<PlaceSearch>? searchResults;
  Place? place;

  searchPlaces(String searchTerm, double lat, double lng) async {
    if (searchTerm == "") {
      searchResults!.clear();
    } else {
      searchResults = await placesService.getAutoComplete(searchTerm, lat, lng);
    }
    notifyListeners();
  }

  searchPlace(String placeId) async {
    place = await placesService.getPlace(placeId);
    searchResults!.clear();
    notifyListeners();
  }

  calculateRoute(List<LatLng> points) async {
    await routeService.getRoute(
        points, routevolt.carRoute, TravelModes.driving);
    await routeService.getRoute(
        points, routevolt.bicycleRoute, TravelModes.bicycling);
    await routeService.getRoute(
        points, routevolt.walkingRoute, TravelModes.walking);
  }

  String calculateRouteDistance(List<LatLng> points) {
    return distanceCalculator.calculateRouteDistance(points, decimals: 1);
  }

  changePointer(int mode) {
    routevolt.i = mode;
  }

  cleanRoute() {
    routevolt.bicycleRoute.routes.clear();
    routevolt.walkingRoute.routes.clear();
    routevolt.carRoute.routes.clear();
    routevolt.i = 0;
  }
}
