import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/config.dart';

class AchievementService {
  static const String baseUrl = Config.apiURL; // Replace with your API endpoint

  Future<List<Achievement>> getAchievements() async {
    final url = Uri.http(Config.apiURL, Config.achievementsAPI);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Achievement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load achievements');
    }
  }

  Future<void> incrementAchievement(String achievementName) async {
    final url = Uri.http(Config.apiURL, Config.achievementsAPI);
    final response = await http.post(
      url,
      body: json.encode({'achievement': achievementName}),
      headers: {'Content-Type': 'application/json'},
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