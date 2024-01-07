import 'dart:convert' as convert;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:govoltfrontend/services/token_service.dart';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/config.dart';

class AuthService {
  String? apiKey;
  final headers = {"Content-Type": "application/json;charset=UTF-8"};
  Future<String?> loadJsonData() async {
    String jsonString = await rootBundle.loadString('lib/services/api.json');
    Map<String, dynamic> jsonData = convert.jsonDecode(jsonString);
    return jsonData['apiKey'];
  }

  Future<dynamic> login(String encodedData) async {
    try {
      final urllogin = Uri.parse(Config.loginFIREBASE);
      final res = await http.post(urllogin, headers: headers, body: encodedData);
      print(res);
      final data = json.decode(res.body);
      final token = data['idToken'];
      Token.token = 'Bearer $token';

      return res;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
}