import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:govoltfrontend/config.dart';
import 'package:govoltfrontend/models/message.dart';
import 'package:govoltfrontend/models/rutas.dart';
import 'package:govoltfrontend/services/rutas_service.dart';
import 'package:http/http.dart' as http;

class ChatService {
  bool firstLoad = false;
  DateTime now = DateTime.now();
  static final message =
      MessageVolt(userid: "", content: "", timestamp: "", roomName: "");
  String currentUserId = "userid";
  static String currentRoom = "";
  final rutasService = RutaService();

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
      String roomName, String idUsuario, String message) async {
    final body = {
      "content": message,
      "room_name": roomName,
      "sender": idUsuario
    };
    final url = Uri.http(Config.apiURL, Config.chatAddMessage);
    try {
      await http.post(url, body: body);
    }
    catch (error){}
  }

  Future<void> createChat(String idRuta) async {
    final body = {
      "content": "Default",
      "room_name": idRuta,
      "sender": "Default"
    };
    final url = Uri.http(Config.apiURL, Config.chatAddMessage);
    try {
      await http.post(url, body: body);
    }
    catch (error){}
  }

  Future<dynamic> getChats() async{
    final url =
        Uri.http(Config.apiURL, Config.chats);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }

  Future<void> getLastMessage(String idRoom) async {
    final url =
        Uri.http(Config.apiURL, Config.chatAddMessage, {'room_name': idRoom});
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      var data = jsonResponse["messages"] as List;
      var messageData = data.last as Map;
      message.content = messageData['content'];
      message.timestamp = messageData['timestamp'].toString();
      message.userid = messageData['sender'];
      message.roomName = messageData['room_name'];
    }
  }

  void leaveRoomChat() {
    currentRoom = "";
  }

  void enterChatRoom(String idRoom) {
    currentRoom = idRoom;
  }

  Future<List<MessageVolt>> loadAllMessagesData(
      String room_name, String idUsuario) async {
    final url = Uri.http(Config.apiURL, Config.chatAddMessage,
        {'room_name': room_name});
    try {
      final response = await http.get(url);
      final jsonResponse = json.decode(response.body);
      var data = jsonResponse["messages"] as List;
      return data.map((mensaje) => MessageVolt.fromMap(mensaje)).toList();
    }
    catch (error){
      return [];
    }
  }

  void updateLastConnection(String roomName) {
    final url = Uri.http(Config.apiURL, Config.chats);
    final body = {
      "id_chat": roomName,
    };
    try {
      //await
      http.put(url, body: body);
    }
    catch (e){

    }
  }

  Future<List<String>> getAllListeners() async {
    dynamic chats = await getChats();
    List<Ruta> rutas = await rutasService.getMyRutas();
    Map<String, dynamic> data = jsonDecode(chats);
    List<dynamic> chatsList = data['chats'];
    List<String> roomNames = chatsList.map((chat) => chat['room_name'].toString()).toList();
    List<String> rutasMy = rutas.map((ruta) => ruta.id).toList();
    return rutasMy + roomNames;
  }

  void setupDatabaseAllListeners() async {
    var id = ["rutaid/userid", "rutaid/userid2"];
    for (int i = 0; i < id.length; ++i) {
      DatabaseReference messagesRefSingle =
          FirebaseDatabase.instance.ref().child(listaConcatenada[i]);

      messagesRefSingle.onChildAdded.listen((event) async {
        final dynamicValue = event.snapshot.value;
        if (dynamicValue is String) {
          var roomName = messagesRefSingle.path;
          if (roomName == currentRoom)
          {
            try{
              await getLastMessage(currentRoom);
            }
            catch (error){}
            if (message.userid != currentUserId) {
              setMessageArrived(message);
            }
          }
          else{
            try{
              await getLastMessage(roomName);
            }
            catch (error){}
            String messageReceived = "Nuevo Mensaje_";
            _messageArrivedNotificationController.add(messageReceived);
          }
        }
      });
    }
  }

  void setupDatabaseSngleListener(String roomName) async {

    createChat(roomName);

    DatabaseReference messagesRefSingle =
        FirebaseDatabase.instance.ref().child(roomName);

    messagesRefSingle.onChildAdded.listen((event) async {
      if (event.snapshot.value is Map)
      {
          String messageReceived = "Nuevo mensaje_Alguien quiere unirse a tu ruta";
          _messageArrivedNotificationController.add(messageReceived);

      }
    });
  }

  void addParticipantToRoute(String idUser, String idRuta) async {
    String urlInfo = "${Config.chatAddMessage}/$idRuta/$idUser/";
    final url = Uri.http(Config.apiURL, urlInfo);
    try{
    await http.post(url);
    }
    catch (error){}
  }
}
