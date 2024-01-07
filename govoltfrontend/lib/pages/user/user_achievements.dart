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

  Map<String, List<int>> _thresholds = {
    'messages_achievement': [5, 10, 15],
    'nearest_charger_achievement': [20, 30, 50],
    'search_location_achievement': [5, 10, 15],
    'search_event_achievement': [20, 30, 50],
  };

  Color goldColor = Color(0xFFFFD700);
  Color silverColor = Color(0xFFC0C0C0);
  Color bronzeColor = Color(0xFFCD7F32);
  Color darkGreyColor = Color(0xFF303030); // Gris oscuro

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

  Color _getIconColor(String achievementName, int progress) {
    List<int> thresholds = _thresholds[achievementName] ?? [0, 0, 0];

    if (progress >= thresholds[2]) {
      return goldColor;
    } else if (progress >= thresholds[1]) {
      return silverColor;
    } else if (progress >= thresholds[0]) {
      return bronzeColor;
    } else {
      return Colors.black;
    }
  }

  Color _getTextColor(Color iconColor) {
    return iconColor == goldColor ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'),
        backgroundColor: Color.fromRGBO(125, 193, 165, 1),
      ),
      body: _achievements.isNotEmpty
          ? ListView.separated(
              itemCount: _achievements.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final achievementName = _achievements.keys.elementAt(index);
                final progress = _achievements[achievementName];

                String title = '';
                String description = '';
                IconData iconData = Icons.info;

                switch (achievementName) {
                  case 'messages_achievement':
                    title = 'Messenger';
                    description = 'You have sent someone a message!';
                    iconData = Icons.mail;
                    break;
                  case 'nearest_charger_achievement':
                    title = 'Optimizer';
                    description =
                        'You have redirected your route to a near charger';
                    iconData = Icons.battery_full;
                    break;
                  case 'search_location_achievement':
                    title = 'Explorer';
                    description = 'You have searched a location';
                    iconData = Icons.search;
                    break;
                  case 'search_event_achievement':
                    title = 'When and Where?';
                    description = 'You have searched an event';
                    iconData = Icons.event;
                    break;
                }

                return Container(
                  color: _getIconColor(achievementName, progress) == goldColor
                      ? darkGreyColor
                      : null,
                  child: ListTile(
                    leading: Icon(
                      iconData,
                      color: _getIconColor(achievementName, progress),
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        color: _getTextColor(
                            _getIconColor(achievementName, progress)),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          style: TextStyle(
                            color: _getTextColor(
                                _getIconColor(achievementName, progress)),
                          ),
                        ),
                        Text(
                          'Score: $progress',
                          style: TextStyle(
                            color: _getTextColor(
                                _getIconColor(achievementName, progress)),
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      'Progress: $progress',
                      style: TextStyle(
                        color: _getTextColor(
                            _getIconColor(achievementName, progress)),
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text('No achievements available'),
            ),
    );
  }
}
