import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:govoltfrontend/config.dart';
import 'package:govoltfrontend/models/message.dart';
import 'package:http/http.dart' as http;

class ChatService {
  bool firstLoad = false;
  DateTime now = DateTime.now();
  final message = MessageVolt();
  String currentUserId = "userid";

  final _messageArrivedController = StreamController<MessageVolt>.broadcast();
  Stream<MessageVolt> get onMessageArrivedChanged =>
      _messageArrivedController.stream;

  void setMessageArrived(MessageVolt value) {
    _messageArrivedController.add(value);
  }

  void sendMessage(
      String idRuta, String idUsuario, String message, String idChat) async {
    final body = {
      "content": message,
      "room_name": "$idRuta/$idChat",
      "sender": idUsuario
    };
    final url = Uri.http(Config.apiURL, Config.chatAddMessage);
    await http.post(url, body: body);
  }

  Future<void> getLastMessage(String idRuta, String idUsuario) async {
    final url = Uri.http(Config.apiURL, Config.chatAddMessage,
        {'room_name': "$idRuta/$idUsuario"});
    final response = await http.get(url);
    final jsonResponse = json.decode(response.body);
    var data = jsonResponse["messages"] as List;
    var messageData = data.last as Map;
    message.content = messageData['content'];
    message.timestamp = messageData['timestamp'].toString();
    message.userid = messageData['sender'];
  }

  void setupDatabaseListener() async {
    var id = []; //"rutaid/userid"
    for (int i = 0; i < id.length; ++i) {
      DatabaseReference messagesRef =
          FirebaseDatabase.instance.ref().child(id[i]);

      messagesRef.onChildAdded.listen((event) {
        final dynamicValue = event.snapshot.value;
        if (dynamicValue is String) {
          print(dynamicValue);
        } else if (dynamicValue is Map<String, dynamic>) {
          final data = dynamicValue;
          DateTime messageTime = DateTime.fromMillisecondsSinceEpoch(
              data['timestamp'].toInt() * 1000);
          if (messageTime.isAfter(now)) {
            print('Nuevo mensaje:$i');
          } else {}
        }
      });
    }
  }

  void setupDatabaseSingleListener(String idRoom) async {
    DatabaseReference messagesRefSingle =
        FirebaseDatabase.instance.ref().child(idRoom);

    messagesRefSingle.onChildAdded.listen((event) async {
      final dynamicValue = event.snapshot.value;
      if (dynamicValue is String) {
        await getLastMessage("rutaid", "userid");
        if (message.userid != currentUserId) {
          setMessageArrived(message);
        }
      } else if (dynamicValue is Map) {
        final data = dynamicValue;
        message.content = data['content'];
        message.timestamp = data['timestamp'].toString();
        message.userid = data['sender'];
        setMessageArrived(message);
      }
    });
  }
}
