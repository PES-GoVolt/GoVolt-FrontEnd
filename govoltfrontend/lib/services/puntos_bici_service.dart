import 'dart:convert';
import 'package:govoltfrontend/models/bike_station.dart';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/config.dart';
import 'package:govoltfrontend/services/token_service.dart';


class BikeStationsService {
  BikeStationsService();

  Future<List<BikeStation>> getBikeStations() async {
    try {
      final url = Uri.http(Config.apiURL, Config.allBikeStations);
      final headers = { 'Content-Type': 'application/json',"Authorization": Token.token};
      //final response = await http.get(url, headers: headers);
      final statusCode = 200;
      final body = 
        [{
          "station_id": "1",
          "latitude": 41.3979779,
          "longitude": 2.1801069,
          "address": "GRAN VIA CORTS CATALANES, 760"
        }];
      if (statusCode == 200) {
        //final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        List<BikeStation> bikeStations = [];

        for (var station in body) {
          bikeStations.add(BikeStation.fromJson(station));
        }
        return bikeStations;
      } else {
        throw Exception('Error fetching bike stations');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
