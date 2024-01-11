import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:govoltfrontend/api_keys.dart';
import 'package:govoltfrontend/models/route.dart';
import 'package:http/http.dart' as http;

class RouteService {
  Future<void> getRoute(
      List<LatLng> points, RouteVolt route, String mode) async {
    String apiKey = SecretKeys.googleApiKey;
    final url =
        Uri.parse('https://routes.googleapis.com/directions/v2:computeRoutes');
    final body = {
      "origin": {
        "location": {
          "latLng": {
            "latitude": points[0].latitude,
            "longitude": points[0].longitude
          }
        }
      },
      "destination": {
        "location": {
          "latLng": {
            "latitude": points[1].latitude,
            "longitude": points[1].longitude
          }
        }
      },
      "travelMode": mode,
      "computeAlternativeRoutes": false,
      "routeModifiers": {
        "avoidTolls": false,
        "avoidHighways": false,
        "avoidFerries": false
      },
      "languageCode": "es",
      "units": "METRIC",
      "polylineQuality": "HIGH_QUALITY",
    };

    if (mode == "DRIVE") {
      body["routingPreference"] = "TRAFFIC_AWARE";
    }

    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask':
          'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline'
    };

    final response =
        await http.post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String encodedPolyline = data["routes"][0]["polyline"]["encodedPolyline"];
      int distanceResponse = data["routes"][0]["distanceMeters"];
      String timeResponse = data["routes"][0]["duration"];
      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> result = polylinePoints.decodePolyline(encodedPolyline);
      route.addPolyLine(result);
      route.distance = distanceResponse;
      route.time = timeResponse;
    }
  }
}
