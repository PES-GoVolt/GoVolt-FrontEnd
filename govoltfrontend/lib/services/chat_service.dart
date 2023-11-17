import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:govoltfrontend/config.dart';
import 'package:govoltfrontend/models/message.dart';
import 'package:http/http.dart' as http;

class ChatService {
  bool firstLoad = false;
  DateTime now = DateTime.now();
  static final message =
      MessageVolt(userid: "", content: "", timestamp: "", roomName: "");
  String currentUserId = "userid";
  static String currentRoom = "";

  static final _messageArrivedController =
      StreamController<MessageVolt>.broadcast();
  Stream<MessageVolt> get onMessageArrivedChanged =>
      _messageArrivedController.stream;

      static final _messageArrivedNotificationController =
      StreamController<String>.broadcast();
  Stream<String> get onMessageArrivedNotificationChanged =>
      _messageArrivedNotificationController.stream;

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

  Future<void> getLastMessage(String idRoom) async {
    final url =
        Uri.http(Config.apiURL, Config.chatAddMessage, {'room_name': idRoom});
    final response = await http.get(url);
    final jsonResponse = json.decode(response.body);
    var data = jsonResponse["messages"] as List;
    var messageData = data.last as Map;
    message.content = messageData['content'];
    message.timestamp = messageData['timestamp'].toString();
    message.userid = messageData['sender'];
    message.roomName = messageData['room_name'];
  }

  void leaveRoomChat() {
    currentRoom = "";
  }

  void enterChatRoom(String idRoom) {
    currentRoom = idRoom;
  }

  Future<List<MessageVolt>> loadAllMessagesData(
      String idRuta, String idUsuario) async {
    final url = Uri.http(Config.apiURL, Config.chatAddMessage,
        {'room_name': "$idRuta/$idUsuario"});
    final response = await http.get(url);
    final jsonResponse = json.decode(response.body);
    var data = jsonResponse["messages"] as List;
    return data.map((mensaje) => MessageVolt.fromMap(mensaje)).toList();
  }

  void setupDatabaseSingleListener() async {
    var id = ["rutaid/userid", "rutaid/userid2"];
    for (int i = 0; i < id.length; ++i) {
      DatabaseReference messagesRefSingle =
          FirebaseDatabase.instance.ref().child(id[i]);

      messagesRefSingle.onChildAdded.listen((event) async {
        final dynamicValue = event.snapshot.value;
        if (dynamicValue is String) {
          var roomName = messagesRefSingle.path;
          if (roomName == currentRoom)
          {
            await getLastMessage(currentRoom);
            if (message.userid != currentUserId) {
              setMessageArrived(message);
            }
          }
          else{
            await getLastMessage(roomName);
            String messageReceived = "${message.userid}_${message.content}";
            _messageArrivedNotificationController.add(messageReceived);
          }
        }
      });
    }
  }
}
