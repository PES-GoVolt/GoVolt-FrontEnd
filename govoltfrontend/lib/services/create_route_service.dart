import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/config.dart';

class CreateRoutesService {
  static Future<void> createRuta(Map<String, dynamic> formData) async {
    final url = Uri.http(Config.apiURL, Config.createRoute);
    final headers = {
      'Content-Type': 'application/json',
    };
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(formData),
      );

      if (response.statusCode == 200) {
        print('Ruta created successfully');
        print(response.body);
      } else {
        print('Error creating ruta');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}