import 'dart:convert';
import 'package:govoltfrontend/models/bike_station.dart';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/config.dart';

class BikeStationsService {
  BikeStationsService();

  Future<List<BikeStation>> getBikeStations() async {
    try {
      final url = Uri.http(Config.apiURL, Config.allBikeStations);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<BikeStation> bikeStations = [];

        for (var station in data) {
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
