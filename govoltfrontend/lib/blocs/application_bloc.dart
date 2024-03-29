import 'package:flutter/material.dart';
import 'package:govoltfrontend/models/bike_station.dart';
import 'package:govoltfrontend/models/mapa/place.dart';
import 'package:govoltfrontend/models/place_search.dart';
import 'package:govoltfrontend/models/route_list.dart';
import 'package:govoltfrontend/services/auth_service.dart';
import 'package:govoltfrontend/services/chat_service.dart';
import 'package:govoltfrontend/services/notification.dart';
import 'package:govoltfrontend/services/rutas_service.dart';
import 'package:govoltfrontend/services/user_service.dart';
import 'package:govoltfrontend/services/places_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:govoltfrontend/services/puntos_bici_service.dart';
import 'package:govoltfrontend/services/puntos_carga_service.dart';
import 'package:govoltfrontend/services/google_routes_service.dart';

class AplicationBloc with ChangeNotifier {
  final placesService = PlacesService();
  final routeService = RouteService();
  final chargersService = ChargersService();
  final bikeService = BikeStationsService();
  final editUser = EditUserService();
  final rutasService = RutaService();
  RouteVoltList routevolt = RouteVoltList();
  final chatService = ChatService();
  final notificationService = NotificationService();
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

  Future<dynamic> getCurrentUserID() async{
    return await editUser.getCurrentUserID();
  }

  Future<List<Coordenada>> getChargers() async {
    try
    {
      return await chargersService.obtenerPuntosDeCarga();
    }
    catch(e){
      return [];
    }
  }

  Future<List<BikeStation>> getBikeStations() async {
    return await bikeService.getBikeStations();
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

  chargerFinded(Place p) {
    place = p;
  }


  addParticipant(String userId, String idRuta)
  {
      rutasService.addParticipant(userId, idRuta);
  }

  deleteRequestParticipant(String userId, String idRuta, String roomName) async
  {
    await rutasService.deleteRequestParticipant(userId, idRuta, roomName);
  }


  Future<dynamic> login(String encodedData) async {
    return await authService.login(encodedData);
  }

  calculateRoute(List<LatLng> points) async {
    await routeService.getRoute(points, routevolt.carRoute, "DRIVE");
    await routeService.getRoute(points, routevolt.bicycleRoute, "BICYCLE");
    await routeService.getRoute(points, routevolt.walkingRoute, "WALK");
  }

  calculateRouteToCharger(List<LatLng> points) async {
    await routeService.getRoute(points, routevolt.tempRouteToCharger, "DRIVE");
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

  createChat(String idRuta, String userUid, String creatorUid){
      chatService.createChat(idRuta, userUid, creatorUid);
  }

  sendNotification(String idUsuario, String idUserBlocked)
  {
      notificationService.sendReport(idUsuario, idUserBlocked);
  }

}
