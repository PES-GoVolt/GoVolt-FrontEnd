import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize native android notification
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize native Ios Notifications
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  static void showNotificationAndroid(String title, String value) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel_id', 'Channel Name',
            channelDescription: 'Channel Description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');

    int notification_id = 1;
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        notification_id, title, value, notificationDetails,
        payload: 'Not present');
  }

  static Future<void> zonedScheduleNotification(int id, String? title, String? value, TZDateTime scheduledDate) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      channelDescription: 'Channel Description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      value,
      scheduledDate,
      notificationDetails,
      payload: 'Not present', uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
