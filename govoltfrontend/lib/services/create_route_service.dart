import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/config.dart';

class CreateRoutesService {
  static Future<void> createRuta(Map<String, dynamic> formData) async {
    final url = Uri.http(Config.apiURL, Config.createRoute);
    final headers = {
      'Content-Type': 'application/json',
      // Add any additional headers you might need
    };
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(formData),
      );

      if (response.statusCode == 200) {
        // Successful request, you can handle the response here
        print('Ruta created successfully');
        print(response.body);
      } else {
        // Handle error response
        print('Error creating ruta');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (error) {
      // Handle any network or other errors
      print('Error: $error');
    }
  }
}