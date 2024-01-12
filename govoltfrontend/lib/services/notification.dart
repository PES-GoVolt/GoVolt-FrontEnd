import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:govoltfrontend/config.dart';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/services/token_service.dart';

class NotificationService {
  static final _messageArrivedNotificationController =
      StreamController<String>.broadcast();

  Stream<String> get onMessageArrivedNotificationChanged =>
      _messageArrivedNotificationController.stream;

  void sendReport(String idUsuario, String idUserBlocked) async {
    final body = {
      "content": "Usuario que lo reporto: $idUserBlocked",
      "user_id": idUsuario,
    };
    final url = Uri.https(Config.apiURL, Config.report);
    final headers = {"Authorization": Token.token};
    try {
      await http.post(url, body: body, headers: headers);
    } catch (error) {}
  }

  void setupDatabaseSngleListener(String id) async {
    DatabaseReference messagesRefSingle =
        FirebaseDatabase.instance.ref().child("notifications/$id");

    messagesRefSingle.onChildAdded.listen((event) async {
      if (event.snapshot.value is! Map) {
        final headers = {"Authorization": Token.token};
        final url = Uri.https(Config.apiURL, Config.report);
        final response = await http.get(url, headers: headers);
        if (response.statusCode == 200) {
          Map<String, dynamic> parsedJson = json.decode(response.body);
          List<dynamic> notifications = parsedJson['notifications'];
          if (notifications.isNotEmpty) {
            Map<String, dynamic> ultimaNotificacion = notifications.last;
            String content = ultimaNotificacion['content'];
            String messageReceived = content;
            _messageArrivedNotificationController.add(messageReceived);
          }
        }
      }
    });
  }
}
