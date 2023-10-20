import 'dart:convert' as convert;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_routes/google_maps_routes.dart';

class RouteService {
  String? apiKey;

  Future<void> loadJsonData() async {
    String jsonString = await rootBundle.loadString('lib/services/api.json');
    Map<String, dynamic> jsonData = convert.jsonDecode(jsonString);
    apiKey = jsonData['apiKey'];
  }

  Future<void> getRoute(List<LatLng> points, MapsRoutes route) async {
    if (apiKey == null) await loadJsonData();
    await route.drawRoute(points, 'Test routes',
              Color.fromRGBO(125, 193, 165, 1), apiKey!,
              travelMode: TravelModes.driving);
  }
}
