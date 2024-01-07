import 'package:flutter/material.dart';
import 'package:govoltfrontend/models/bike_station.dart';
import 'package:govoltfrontend/models/mapa/place.dart';
import 'package:govoltfrontend/models/place_search.dart';
import 'package:govoltfrontend/models/route_list.dart';
import 'package:govoltfrontend/services/auth_service.dart';
import 'package:govoltfrontend/services/chat_service.dart';
import 'package:govoltfrontend/services/rutas_service.dart';
import 'package:govoltfrontend/services/user_service.dart';
import 'package:govoltfrontend/services/places_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:govoltfrontend/services/puntos_bici_service.dart';
import 'package:govoltfrontend/services/puntos_carga_service.dart';
import 'package:govoltfrontend/services/routes_service.dart';

class AplicationBloc with ChangeNotifier {
  final placesService = PlacesService();
  final routeService = RouteService();
  final chargersService = ChargersService();
  final bikeService = BikeStationsService();
  final editUser = EditUserService();
  final rutasService = RutaService();
  RouteVoltList routevolt = RouteVoltList();
  final chatService = ChatService();
  final authService = AuthService();
  List<PlaceSearch>? searchResults;
  Place? place;

  saveUserChanges(String firstName, String lastName, String email,
      String phoneNumber, String photo) async {
    await editUser.saveChanges(firstName, lastName, email, phoneNumber, photo);
  }

  Future<dynamic> getCurrentUserData() async {
    return await editUser.getCurrentUserData();
  }

  Future<bool> logOutUser() async {
    return await editUser.logOut();
  }

  searchPlaces(String searchTerm, double lat, double lng) async {
    if (searchTerm == "") {
      searchResults!.clear();
    } else {
      searchResults = await placesService.getAutoComplete(searchTerm, lat, lng);
    }
    notifyListeners();
  }

  /*searchCities(String searchTerm) async {
    if (searchTerm == "") {
      searchResults!.clear();
    } else {
      searchResults = await placesService.getAutoComplete(searchTerm, );
    }
    notifyListeners();
  }*/

  Future<List<Coordenada>> getChargers() async {
    try {
      return await chargersService.obtenerPuntosDeCarga();
    } catch (e) {
      return [];
    }
  }

  Future<List<BikeStation>> getBikeStations() async {
    return await bikeService.getBikeStations();
  }

  foundMarker(Place p) {
    place = p;
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

  addParticipant(String userId, String idRuta) {
    rutasService.addParticipant(userId, idRuta);
  }

  Future<dynamic> login(String encodedData) async {
    print("entro en application_bloc.dart");
    print(encodedData);
    return await authService.login(encodedData);
  }

  calculateRoute(List<LatLng> points) async {
    await routeService.getRoute(points, routevolt.carRoute, "DRIVE");
    await routeService.getRoute(points, routevolt.bicycleRoute, "BICYCLE");
    await routeService.getRoute(points, routevolt.walkingRoute, "WALK");
  }

  calculateRouteToCharger(List<LatLng> points) async {
    await routeService.getRoute(points, routevolt.carRoute, "DRIVE");
  }

  changePointer(int mode) {
    routevolt.i = mode;
  }

  cleanRoute() {
    routevolt.clearData();
  }

  createRouteListener(String roomName) async {
    chatService.createChatRouteListener(roomName);
  }

  createChat(String idRuta, String userUid, String creatorUid) {
    chatService.createChat(idRuta, userUid, creatorUid);
  }
}
