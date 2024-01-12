import 'dart:convert';
import 'package:govoltfrontend/services/token_service.dart';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/config.dart';

class AchievementService {
  static const String baseUrl = Config.apiURL;

  Future<Map<String, dynamic>> getAchievements() async {
    final url = Uri.https(Config.apiURL, Config.achievementsAPI);
    final headers = {
      'Content-Type': 'application/json',
      "Authorization": Token.token
    };
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load achievements');
    }
  }

  Future<void> incrementAchievement(String achievementName) async {
    final url = Uri.https(Config.apiURL, Config.achievementsAPI);
    final response = await http.post(
      url,
      body: json.encode({'achievement': achievementName}),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": Token.token
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to increment achievement');
    }
  }
}

class Achievement {
  final String name;
  final int progress;

  Achievement({required this.name, required this.progress});

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      name: json['name'] as String,
      progress: json['progress'] as int,
    );
  }
}
