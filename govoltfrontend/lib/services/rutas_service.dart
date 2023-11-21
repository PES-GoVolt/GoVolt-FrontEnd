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

  Future<List<Ruta>> getRutasFromEndpoint(String endpoint) async {
    try {
      final url = Uri.http(Config.apiURL, endpoint);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['rutas'];

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

  Future<List<Ruta>> getAllRutas() async {
    return await getRutasFromEndpoint(Config.allRutas);
  }

  Future<List<Ruta>> getMyRutas() async {
    return await getRutasFromEndpoint(Config.myRutas);
  }

  Future <void> addParticipant(String userId, String idRuta) async{
    String urlString = "api${Config.addParticipantToRuta}$idRuta/$userId/";
    final url = Uri.http(Config.apiURL, urlString);
    await http.post(url);
  }

  Future<List<Ruta>> getPartRutas() async {
    return await getRutasFromEndpoint(Config.participantRutas);
  }
}
