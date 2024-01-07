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

  // Thresholds para cambiar de color los iconos
  Map<String, List<int>> _thresholds = {
    'messages_achievement': [5, 10, 15],
    'nearest_charger_achievement': [20, 30, 50],
    'search_location_achievement': [5, 10, 15],
    'search_event_achievement': [20, 30, 50],
  };

  // Colores personalizados para oro, plata y bronce
  Color goldColor = Color(0xFFFFD700);
  Color silverColor = Color(0xFFC0C0C0);
  Color bronzeColor = Color(0xFFCD7F32);

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

  // Función para determinar el color del icono según el progreso
  Color _getIconColor(String achievementName, int progress) {
    List<int> thresholds = _thresholds[achievementName] ?? [0, 0, 0];

    if (progress >= thresholds[2]) {
      return goldColor; // Oro
    } else if (progress >= thresholds[1]) {
      return silverColor; // Plata
    } else if (progress >= thresholds[0]) {
      return bronzeColor; // Bronce
    } else {
      return Colors.black; // Gris por defecto
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'),
      ),
      body: _achievements.isNotEmpty
          ? ListView.separated(
              itemCount: _achievements.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final achievementName = _achievements.keys.elementAt(index);
                final progress = _achievements[achievementName];

                // Títulos y descripciones personalizados para cada logro
                String title = '';
                String description = '';
                IconData iconData = Icons.info; // Icono predeterminado

                switch (achievementName) {
                  case 'messages_achievement':
                    title = 'Messenger';
                    description = 'You have sent someone a message!';
                    iconData = Icons.mail; // Icono de mensaje
                    break;
                  case 'nearest_charger_achievement':
                    title = 'Optimizer';
                    description =
                        'You have redirected your route to a near charger';
                    iconData = Icons.battery_full; // Icono de batería
                    break;
                  case 'search_location_achievement':
                    title = 'Explorer';
                    description = 'You have searched a location';
                    iconData = Icons.search; // Icono de lupa
                    break;
                  case 'search_event_achievement':
                    title = 'When and Where?';
                    description = 'You have searched an event';
                    iconData = Icons.event; // Icono de evento
                    break;
                  // Puedes agregar más casos según sea necesario
                }

                return ListTile(
                  leading: Icon(
                    iconData,
                    color: _getIconColor(achievementName, progress),
                  ),
                  title: Text(title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(description),
                    ],
                  ),
                  trailing: Text('Progress: $progress'),
                );
              },
            )
          : Center(
              child: Text('No achievements available'),
            ),
    );
  }
}
