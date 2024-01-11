import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/config.dart';
import 'package:govoltfrontend/services/token_service.dart';

class CreateRoutesService {
  static Future<String> createRuta(Map<String, dynamic> formData) async {
    final url = Uri.http(Config.apiURL, Config.allRutas);
    final headers = {
      'Content-Type': 'application/json',
      "Authorization": Token.token
    };
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(formData),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonMap = json.decode(response.body);
        String messageValue = jsonMap['message'];
        return messageValue;
      } else {
        return "";
      }
    } catch (error) {
      return "";
    }
  }
}
