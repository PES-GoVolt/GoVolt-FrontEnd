import 'package:flutter/material.dart';
import 'package:govoltfrontend/models/mapa/place.dart';
import 'package:govoltfrontend/models/place_search.dart';
import 'package:govoltfrontend/models/route_list.dart';
import 'package:govoltfrontend/services/places_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:govoltfrontend/services/puntos_carga_service.dart';
import 'package:govoltfrontend/services/routes_service.dart';

class AplicationBloc with ChangeNotifier {
  final placesService = PlacesService();
  final routeService = RouteService();
  final chargersService = ChargersService("http://127.0.0.1:0080/api");
  RouteVoltList routevolt = RouteVoltList();
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
        points, routevolt.carRoute, "DRIVE");
    await routeService.getRoute(
        points,routevolt.bicycleRoute, "BICYCLE");
    await routeService.getRoute(
        points,routevolt.walkingRoute, "WALK");
  }

  calculateRouteToCharger(List<LatLng> points) async {
    await routeService.getRoute(
        points, routevolt.carRoute, "DRIVE");
  }

  changePointer(int mode) {
    routevolt.i = mode;
  }

  cleanRoute() {
    routevolt.clearData();
  }
}
