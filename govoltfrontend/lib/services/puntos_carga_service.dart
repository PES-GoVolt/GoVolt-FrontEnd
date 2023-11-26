import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/config.dart';
import 'package:govoltfrontend/services/token_service.dart';


class ChargersService {
  ChargersService();

  Future<List<Coordenada>> obtenerPuntosDeCarga() async {
    try {
      final url = Uri.http(Config.apiURL, Config.allChargers);
      final headers = { 'Content-Type': 'application/json',"Authorization": Token.token};
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Coordenada> puntosDeCarga = [];

        for (var punto in data) {
          puntosDeCarga.add(Coordenada.fromJson(punto));
        }
        return puntosDeCarga;
      } else {
        throw Exception('Error al obtener los puntos de carga');
      }
    } catch (e) {
      //throw Exception('Error de red: $e');
      return [];
    }
  }

  Future<Coordenada> obtenerPuntoDeCargaMasCercano(LatLng coordenada) async {
    Map<String, dynamic> data = {
      "longitud": coordenada.longitude,
      "latitud": coordenada.latitude,
    };

    final url = Uri.https(Config.apiURL, Config.chargersNearest);
    final headers = { 'Content-Type': 'application/json',"Authorization": Token.token};
    String jsonData = json.encode(data);
    try {
      final response = await http.post(url,
          headers: headers,
          body: jsonData);
      final jsonResponse = json.decode(response.body);
      return Coordenada.fromJson(jsonResponse);
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}

class Coordenada {
  final double latitud;
  final double longitud;
  final String chargerId;

  Coordenada(this.latitud, this.longitud, this.chargerId);

  factory Coordenada.fromJson(Map<String, dynamic> json) {
    return Coordenada(
      json['latitude'] as double,
      json['longitude'] as double,
      json['charger_id']
          as String,
    );
  }
}
