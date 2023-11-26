import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:govoltfrontend/config.dart';
import 'package:govoltfrontend/models/message.dart';
import 'package:govoltfrontend/models/rutas.dart';
import 'package:govoltfrontend/services/rutas_service.dart';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/services/token_service.dart';


class ChatService {
  bool firstLoad = false;
  DateTime now = DateTime.now();
  static final message =
      MessageVolt(userid: "", content: "", timestamp: "", roomName: "", chatId: "");
  static String currentUserId = "userid";
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

  void createChat(String idRuta, String userUid, String creatorUid) async {
    final url = Uri.http(Config.apiURL, Config.chats);
    final body = {
      "user_uid": userUid,
      "creator_uid" : creatorUid,
      "room_name": idRuta
    };
    final headers = { 'Content-Type': 'application/json',"Authorization": Token.token};

    try{
      dynamic response = await http.post(url, body: body, headers: headers);
      Map<String, dynamic> responseData = json.decode(response.body);
      String roomName = responseData['room_name'];
      if (roomName != null)
      {
        sendMessage(roomName as String, "DefaultUser", "Me gustaria unirme a tu ruta");
        subscribeToNewChat(roomName);
      }
    }
    catch (e){}
  }
  
  void sendMessage(String roomName, String idUsuario, String message) async {
    final body = {
      "content": message,
      "room_name": roomName,
      "sender": idUsuario
    };
    final url = Uri.http(Config.apiURL, Config.chatAddMessage);
    final headers = { 'Content-Type': 'application/json',"Authorization": Token.token};
    try {
      await http.post(url, body: body,headers: headers);
    }
    catch (error){}
  }

  Future<void> createChatRouteListener(String idRuta) async {
    
    setupDatabaseSngleListener(idRuta);
    
    final body = {
      "content": "Default",
      "room_name": idRuta,
      "sender": "Default"
    };
    final url = Uri.http(Config.apiURL, Config.chatAddMessage);
    final headers = { 'Content-Type': 'application/json',"Authorization": Token.token};
    try {
      await http.post(url, body: body, headers: headers);
      
    }
    catch (error){}
  }

  Future<dynamic> getChats() async{
    final url =
        Uri.http(Config.apiURL, Config.chats);
    final headers = { 'Content-Type': 'application/json',"Authorization": Token.token};    
    final response = await http.get(url,headers: headers);
    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }

  Future<void> getLastMessage(String idRoom) async {
    final url =
        Uri.http(Config.apiURL, Config.chatAddMessage, {'room_name': idRoom});
    final headers = { 'Content-Type': 'application/json',"Authorization": Token.token};
    final response = await http.get(url, headers: headers);
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

  void enterChatRoom(String idRoom, String myId) {
    currentRoom = idRoom;
    currentUserId = myId;
  }

  Future<List<MessageVolt>> loadAllMessagesData(
      String room_name) async {
    final url = Uri.http(Config.apiURL, Config.chatAddMessage,
        {'room_name': room_name});
    final headers = { 'Content-Type': 'application/json',"Authorization": Token.token};
    try {
      final response = await http.get(url, headers: headers);
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
    final headers = { 'Content-Type': 'application/json',"Authorization": Token.token};
    try {
      //await
      http.put(url, body: body, headers: headers);
    }
    catch (e){}
  }

  Future<List<String>> getAllListeners() async {
    dynamic chats = await getChats();
    List<String> rutasMy = [];
    List<String> roomNames = [];
    List<Ruta> rutas = await rutasService.getMyRutas();
    if (chats != null)
    {
      Map<String, dynamic> data = jsonDecode(chats);
      List<dynamic> chatsList = data['chats'];
      roomNames = chatsList.map((chat) => chat['room_name'].toString()).toList();
    }
    rutasMy = rutas.map((ruta) => ruta.id).toList();
    return rutasMy + roomNames;
  }

  void setupDatabaseAllListeners() async {
    var listaConcatenada = await getAllListeners();
    for (int i = 0; i < listaConcatenada.length; ++i) {
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
              updateLastConnection(roomName);
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

  void subscribeToNewChat(String roomName) async {

    DatabaseReference messagesRefSingle =
        FirebaseDatabase.instance.ref().child(roomName);

    messagesRefSingle.onChildAdded.listen((event) async {
        final dynamicValue = event.snapshot.value;
        if (dynamicValue is String) {
          var roomName = messagesRefSingle.path;
          if (roomName == currentRoom)
          {
            try{
              await getLastMessage(currentRoom);
              updateLastConnection(roomName);
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

  void addParticipantToRoute(String idUser, String idRuta) async {
    String urlInfo = "${Config.chatAddMessage}/$idRuta/$idUser/";
    final url = Uri.http(Config.apiURL, urlInfo);
    final headers = { 'Content-Type': 'application/json',"Authorization": Token.token};
    try{
    await http.post(url, headers: headers);
    }
    catch (error){}
  }
}
