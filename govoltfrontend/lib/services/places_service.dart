import 'package:govoltfrontend/api_keys.dart';
import 'package:govoltfrontend/models/mapa/place.dart';
import 'package:govoltfrontend/models/place_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class PlacesService {
  Future<List<PlaceSearch>> getAutoComplete(
      String search, double lat, double lng) async {
    const region = "es";
    String apiKey = SecretKeys.googleApiKey;
    Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&key=$apiKey&location=$lat%2C$lng&radius=5000&origin=$lat%2C$lng&region=$region');
    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }

  Future<Place> getPlace(String placeId) async {
    String apiKey = SecretKeys.googleApiKey;
    Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey');
    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    var jsonResult = json['result'] as Map<String, dynamic>;
    return Place.fromJson(jsonResult);
  }
}
