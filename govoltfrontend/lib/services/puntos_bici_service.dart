import 'dart:convert';
import 'package:http/http.dart' as http;

class BikeStationsService {
  String baseUrl;

  BikeStationsService(this.baseUrl);

  Future<List<BikeStation>> getBikeStations() async {
    try {
      String url = 'http://10.0.2.2:8000/api/bikestations/all'; // Update the URL for bike stations
      final response = await http.get(Uri.parse(url));
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

class BikeStation {
  final double latitude;
  final double longitude;
  final String stationId; // New field for station ID

  BikeStation(this.latitude, this.longitude, this.stationId);

  factory BikeStation.fromJson(Map<String, dynamic> json) {
    return BikeStation(
      json['latitude'] as double,
      json['longitude'] as double,
      json['station_id'] as String, // Make sure the field name matches the JSON
    );
  }
}
