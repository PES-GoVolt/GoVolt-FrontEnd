import 'package:flutter/services.dart';
import 'package:govoltfrontend/models/place_search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class PlacesService {

Future<String> loadJsonData() async {
  String jsonString = await rootBundle.loadString('lib/services/api.json');
  Map<String, dynamic> jsonData = convert.jsonDecode(jsonString);
  // Ahora tienes acceso a los datos en jsonData
  return jsonData['apiKey'];
}

  Future<List<PlaceSearch>> getAutoComplete(String search) async {
    final apiKey = await loadJsonData();
    Uri url = Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=(cities)&key=$apiKey');
    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    //Map<String, dynamic> json = { "predictions" : [ { "description" : "Baltimore, MD, USA", "matched_substrings" : [ { "length" : 1, "offset" : 0 } ], "place_id" : "ChIJt4P01q4DyIkRWOcjQqiWSAQ", "reference" : "ChIJt4P01q4DyIkRWOcjQqiWSAQ", "structured_formatting" : { "main_text" : "Baltimore", "main_text_matched_substrings" : [ { "length" : 1, "offset" : 0 } ], "secondary_text" : "MD, USA" }, "terms" : [ { "offset" : 0, "value" : "Baltimore" }, { "offset" : 11, "value" : "MD" }, { "offset" : 15, "value" : "USA" } ], "types" : [ "locality", "political", "geocode" ] }, { "description" : "Bethesda, MD, USA", "matched_substrings" : [ { "length" : 1, "offset" : 0 } ], "place_id" : "ChIJLQIkarfLt4kRDc0ravd5siY", "reference" : "ChIJLQIkarfLt4kRDc0ravd5siY", "structured_formatting" : { "main_text" : "Bethesda", "main_text_matched_substrings" : [ { "length" : 1, "offset" : 0 } ], "secondary_text" : "MD, USA" }, "terms" : [ { "offset" : 0, "value" : "Bethesda" }, { "offset" : 10, "value" : "MD" }, { "offset" : 14, "value" : "USA" } ], "types" : [ "locality", "political", "geocode" ] }, { "description" : "Brambleton, VA, USA", "matched_substrings" : [ { "length" : 1, "offset" : 0 } ], "place_id" : "ChIJaTZp6XZAtokRxsvichIEaLI", "reference" : "ChIJaTZp6XZAtokRxsvichIEaLI", "structured_formatting" : { "main_text" : "Brambleton", "main_text_matched_substrings" : [ { "length" : 1, "offset" : 0 } ], "secondary_text" : "VA, USA" }, "terms" : [ { "offset" : 0, "value" : "Brambleton" }, { "offset" : 12, "value" : "VA" }, { "offset" : 16, "value" : "USA" } ], "types" : [ "locality", "political", "geocode" ] }, { "description" : "Broadlands, VA, USA", "matched_substrings" : [ { "length" : 1, "offset" : 0 } ], "place_id" : "ChIJ81HJoqs_tokRmR1HxjHIM1U", "reference" : "ChIJ81HJoqs_tokRmR1HxjHIM1U", "structured_formatting" : { "main_text" : "Broadlands", "main_text_matched_substrings" : [ { "length" : 1, "offset" : 0 } ], "secondary_text" : "VA, USA" }, "terms" : [ { "offset" : 0, "value" : "Broadlands" }, { "offset" : 12, "value" : "VA" }, { "offset" : 16, "value" : "USA" } ], "types" : [ "locality", "political", "geocode" ] }, { "description" : "Boston, MA, USA", "matched_substrings" : [ { "length" : 1, "offset" : 0 } ], "place_id" : "ChIJGzE9DS1l44kRoOhiASS_fHg", "reference" : "ChIJGzE9DS1l44kRoOhiASS_fHg", "structured_formatting" : { "main_text" : "Boston", "main_text_matched_substrings" : [ { "length" : 1, "offset" : 0 } ], "secondary_text" : "MA, USA" }, "terms" : [ { "offset" : 0, "value" : "Boston" }, { "offset" : 8, "value" : "MA" }, { "offset" : 12, "value" : "USA" } ], "types" : [ "locality", "political", "geocode" ] } ], "status" : "OK" };
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }
}