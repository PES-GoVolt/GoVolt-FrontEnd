import 'package:govoltfrontend/models/mapa/geometry.dart';
import 'package:govoltfrontend/models/mapa/opening_hours.dart';

class Place {
  final Geometry geometry;
  final String address;
  final String name;
  final String? uri;
  final OpeningHours? openingHours;

  Place(
      {required this.geometry,
      required this.address,
      required this.name,
      required this.uri,
      this.openingHours});

  factory Place.fromJson(Map<String, dynamic> parsedJson) {
    return Place(
      geometry: Geometry.fromJson(parsedJson['geometry']),
      address: parsedJson['formatted_address'],
      name: parsedJson['name'],
      uri: parsedJson.containsKey('website') ? parsedJson['website'] : null,
      openingHours: parsedJson.containsKey('opening_hours')
          ? OpeningHours.fromJson(parsedJson['opening_hours'])
          : null,
    );
  }
}
