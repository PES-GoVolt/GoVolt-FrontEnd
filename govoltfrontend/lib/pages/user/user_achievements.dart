// achievements_screen.dart

import 'package:flutter/material.dart';
import 'package:govoltfrontend/services/achievement_service.dart';

class AchievementsScreen extends StatefulWidget {
  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementService _achievementService = AchievementService();
  Map<String, dynamic> _achievements = {};

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    try {
      final achievements = await _achievementService.getAchievements();
      setState(() {
        _achievements = achievements;
      });
    } catch (e) {
      print('Error loading achievements: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'),
      ),
      body: _achievements.isNotEmpty
          ? ListView.builder(
              itemCount: _achievements.length,
              itemBuilder: (context, index) {
                final achievementName = _achievements.keys.elementAt(index);
                final progress = _achievements[achievementName];
                return ListTile(
                  title: Text(achievementName),
                  subtitle: Text('Progress: $progress'),
                );
              },
            )
          : Center(
              child: Text('No achievements available'),
            ),
    );
  }
}
