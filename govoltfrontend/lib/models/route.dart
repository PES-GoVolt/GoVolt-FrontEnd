import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteVolt {
  Set<Polyline> route = {};
  int distance = 0;
  String time = "0";

  void clearData()
  {
    route.clear();
    distance = 0;
    time = "0";
  }
  
  void addPolyLine(List<PointLatLng> result)
  {
      PolylineId id = const PolylineId("polyline_id");
      List<LatLng> polylineCoordinates = [];
      for (PointLatLng point in result) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      Polyline polyline = Polyline(
        polylineId: id,
        color: const Color.fromRGBO(185, 15, 219, 0.612),  // Color de la línea
        points: polylineCoordinates, // Lista de coordenadas de la polilínea
        width: 5, // Ancho de la línea en píxeles
      );
      route.add(polyline);
  }

}
