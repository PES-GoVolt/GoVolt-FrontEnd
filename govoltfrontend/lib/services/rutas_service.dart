import 'dart:convert' as convert;
import 'dart:convert';
import 'package:govoltfrontend/config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:govoltfrontend/models/rutas.dart';


class RutaService {
  String? apiKey;

  Future<String?> loadJsonData() async {
    String jsonString = await rootBundle.loadString('lib/services/api.json');
    Map<String, dynamic> jsonData = convert.jsonDecode(jsonString);
    return jsonData['apiKey'];
  }

  Future<List<Ruta>> getAllRutas() async {
    try {
      final url = Uri.http(Config.apiURL, Config.allRutas); 
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['rutas']; // Accede a la lista 'rutas'

        List<Ruta> rutas = [];

        for (var rutaData in data) {
          rutas.add(Ruta.fromJson(rutaData));
        }
        return rutas;
      } else {
        throw Exception('Error fetching routes');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

}
