import 'dart:convert';
import 'package:http/http.dart' as http;

class ChargersService {
  String baseUrl;

  ChargersService(this.baseUrl);

  Future<List<Coordenada>> obtenerPuntosDeCarga() async {
    try {
      String url = "http://10.0.2.2:80/api/chargers";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Coordenada> puntosDeCarga = [];
        
        for (var punto in data) {
          //el problema esta aki makinon
          puntosDeCarga.add(Coordenada.fromJson(punto));
        }
        return puntosDeCarga;
      } else {
        throw Exception('Error al obtener los puntos de carga');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}

class Coordenada {
  final double latitud;
  final double longitud;
  final String chargerId; // Nuevo campo para el chargerID

  Coordenada(this.latitud, this.longitud, this.chargerId);

  factory Coordenada.fromJson(Map<String, dynamic> json) {

    return Coordenada(
      json['latitude'] as double,
      json['longitude'] as double,
      json['charger_id'] as String, // Asegúrate de que el nombre coincida con el JSON
    );
  }
}

