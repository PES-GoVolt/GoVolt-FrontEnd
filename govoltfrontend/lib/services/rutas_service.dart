import 'dart:convert';
import 'package:govoltfrontend/config.dart';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/models/rutas.dart';
import 'package:govoltfrontend/services/token_service.dart';


class RutaService {

  Future<List<Ruta>> getRutasFromEndpoint(String endpoint) async {
    try {
      final url = Uri.http(Config.apiURL, endpoint);

      final headers = { 'Content-Type': 'application/json',"Authorization": Token.token};
      final response = await http.get(url, headers: headers);

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
    final headers = { 'Content-Type': 'application/json',"Authorization": Token.token};
    String urlString = "api${Config.addParticipantToRuta}$idRuta/$userId/";
    final url = Uri.http(Config.apiURL, urlString);
    await http.post(url, headers: headers);
  }

  Future<List<Ruta>> getPartRutas() async {
    return await getRutasFromEndpoint(Config.participantRutas);
  }
  
  String? getParticipantId(String participantName, Ruta ruta) {
    if (ruta.participants != null && ruta.participantsName != null) {
      int index = ruta.participantsName!.indexOf(participantName);
      if (index != -1 && index < ruta.participants!.length) {
        return ruta.participants![index];
      }
    }
    return null;
  }

  Future<void> cancelRoute(String rutaId) async {
    try {
      final url = Uri.http(Config.apiURL, Config.allRutas);
      final bodyRoute= {"route_id": rutaId};
      final headers = {"Authorization": Token.token};
      final response = await http.delete(url, headers: headers, body:bodyRoute );
      if (response.statusCode != 200) {
        throw Exception('Failed to cancel route');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteParticipant(String rutaId, String participantId, String participantName) async{
    try {
      final url = Uri.http(Config.apiURL, Config.myRutas);
      final bodyRoute= {"route_id": rutaId, "participant_id": participantId, "participant_name":participantName};
      final headers = {"Authorization": Token.token};
      final response = await http.delete(url, headers: headers, body:bodyRoute );
      if (response.statusCode != 200) {
        throw Exception('Failed to remove participant');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }

  }


  
}
