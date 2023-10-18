import 'package:flutter/material.dart';
import 'package:govoltfrontend/models/place_search.dart';
import 'package:govoltfrontend/services/places_service.dart';

class AplicationBloc with ChangeNotifier {
  final placesService = PlacesService();

  List<PlaceSearch>? searchResults;

  searchPlaces(String searchTerm) async {
    if (searchTerm == "") {
      searchResults!.clear();
    } else {
      searchResults = await placesService.getAutoComplete(searchTerm);
    }
    notifyListeners();
  }
}
