import 'package:flutter/material.dart';
import 'package:govoltfrontend/models/mapa/place.dart';
import 'package:govoltfrontend/models/place_search.dart';
import 'package:govoltfrontend/services/places_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import 'package:govoltfrontend/services/puntos_carga_service.dart';
import 'package:govoltfrontend/services/routes_service.dart';
import 'package:govoltfrontend/models/route.dart';

class AplicationBloc with ChangeNotifier {
  final placesService = PlacesService();
  final routeService = RouteService();
  final chargersService = ChargersService("http://127.0.0.1:0080/api");
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

  searchCities(String searchTerm) async {
    if (searchTerm == "") {
      searchResults!.clear();
    } else {
      searchResults = await placesService.getAutoCompleteCities(searchTerm);
    }
    notifyListeners();
  }

  Future<List<Coordenada>> getChargers() async {
    return await chargersService.obtenerPuntosDeCarga();
  }

  searchNearestCharger(LatLng coord) async {
    Coordenada chargerCoords =
        await chargersService.obtenerPuntoDeCargaMasCercano(coord);
    return LatLng(chargerCoords.latitud, chargerCoords.longitud);
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

  calculateRouteToCharger(List<LatLng> points) async {
    await routeService.getRoute(
        points, routevolt.tempRouteToCharger, TravelModes.driving);
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
