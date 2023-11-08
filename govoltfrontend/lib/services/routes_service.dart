import 'dart:convert' as convert;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:govoltfrontend/models/route.dart';
import 'package:http/http.dart' as http;

class RouteService {
  String? apiKey;

  Future<String?> loadJsonData() async {
    String jsonString = await rootBundle.loadString('lib/services/api.json');
    Map<String, dynamic> jsonData = convert.jsonDecode(jsonString);
    return jsonData['apiKey'];
  }

  Future<void> getRoute(List<LatLng> points, RouteVolt route, String mode) async {
      String? apiKeyGoogle = await loadJsonData();
      if (apiKeyGoogle != null)
      {
        final url = Uri.parse('https://routes.googleapis.com/directions/v2:computeRoutes');
        final body = {
      "origin": {
        "location": {
          "latLng": {"latitude": points[0].latitude, "longitude": points[0].longitude}
        }
      },
      "destination": {
        "location": {
          "latLng": {"latitude": points[1].latitude, "longitude": points[1].longitude}
        }
      },
      "travelMode": mode,
      "routingPreference": "TRAFFIC_AWARE",
      "computeAlternativeRoutes": false,
      "routeModifiers": {
        "avoidTolls": false,
        "avoidHighways": false,
        "avoidFerries": false
      },
      "languageCode": "es",
      "units": "METRIC"
    };

        final headers = {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKeyGoogle,
        'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline'
        };

        final response = await http.post(url, headers: headers,body: jsonEncode(body));

        if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            String encodedPolyline = data["routes"][0]["polyline"]["encodedPolyline"];
            String distanceResponse = data["routes"][0]["distanceMeters"];
            String timeResponse = data["routes"][0]["duration"];
            PolylinePoints polylinePoints = PolylinePoints();
            List<PointLatLng> result = polylinePoints.decodePolyline(encodedPolyline);
            route.addPolyLine(result);
            route.distance = distanceResponse;
            route.time = timeResponse;
        }
      }
  }
}
