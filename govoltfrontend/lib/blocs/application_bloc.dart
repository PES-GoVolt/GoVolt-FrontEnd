import 'package:flutter/material.dart';
import 'package:govoltfrontend/models/mapa/place.dart';
import 'package:govoltfrontend/models/place_search.dart';
import 'package:govoltfrontend/services/places_service.dart';

class AplicationBloc with ChangeNotifier {
  final placesService = PlacesService();

  List<PlaceSearch>? searchResults;
  Place? place;

  searchPlaces(String searchTerm) async {
    if (searchTerm == "") {
      searchResults!.clear();
    } else {
      searchResults = await placesService.getAutoComplete(searchTerm);
    }
    notifyListeners();
  }

  searchPlace(String placeId) async {
    place = await placesService.getPlace(placeId);
    searchResults!.clear();
    notifyListeners();
  }
}
