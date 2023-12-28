import 'dart:async';
import 'package:govoltfrontend/config.dart';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/services/token_service.dart';


class NotificationService {

  static final _messageArrivedNotificationController =
      StreamController<String>.broadcast();

  Stream<String> get onMessageArrivedNotificationChanged =>
      _messageArrivedNotificationController.stream;


  void sendMessage(String idUsuario, String message) async {
    final body = {
      "content": message,
      "user_id": idUsuario
    };
    final url = Uri.http(Config.apiURL, Config.notifications);
    final headers = { "Authorization": Token.token};
    try {
      await http.post(url, body: body,headers: headers);
    }
    catch (error){}
  }

}
