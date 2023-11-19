import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:govoltfrontend/models/message.dart';
import 'package:govoltfrontend/utils/chat_library/flutter_chat_ui.dart';
import 'package:govoltfrontend/services/chat_service.dart';
import 'package:uuid/uuid.dart';
//import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key,
      required this.idUserReciever,
      required this.idRuta,
      required this.userName,
      required this.idChat});

  final String idUserReciever;
  final String idRuta;
  final String userName;
  final String idChat;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> messages = [];
  final user = const types.User(id: 'userid', firstName: "Marc");
  late String idRuta;
  late String idChatUser;
  final chatService = ChatService();
  late StreamSubscription<MessageVolt> messageArrivedSubscription;
  bool messagesLoaded = false;

  void loadAllData() async {
    List<MessageVolt> messagesDataLoaded =
        await chatService.loadAllMessagesData(idRuta, idChatUser);
    for (var element in messagesDataLoaded) {
      String messageUserId = element.userid;
      final textMessage = types.TextMessage(
        author: messageUserId == user.id
            ? user
            : types.User(id: widget.idUserReciever, firstName: widget.userName),
        createdAt: int.parse(element.timestamp),
        id: Uuid().v4(),
        text: element.content,
      );
      _addMessage(textMessage);
    }
    messagesLoaded = true;
  }

  @override
  void initState() {
    idRuta = widget.idRuta;
    idChatUser = widget.idChat;
    if (!messagesLoaded) loadAllData();
    chatService.enterChatRoom("$idRuta/$idChatUser");
    final user2 =
        types.User(id: widget.idUserReciever, firstName: widget.userName);
    super.initState();
    messageArrivedSubscription =
        chatService.onMessageArrivedChanged.listen((messageArrived) {
      String messageUserId = ChatService.message.userid;
      final textMessage = types.TextMessage(
        author: messageUserId == user.id ? user : user2,
        createdAt: int.parse(ChatService.message.timestamp),
        id: Uuid().v4(),
        text: ChatService.message.content,
      );
      _addMessage(textMessage);
    });
    
  }

  @override
  void dispose() {
    chatService.leaveRoomChat();
    messageArrivedSubscription.cancel();
    super.dispose();
  }

  void _addMessage(types.Message message) {
    setState(() {
      messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text: message.text,
    );
    chatService.sendMessage(idRuta, user.id, message.text, idChatUser);
    _addMessage(textMessage);
  }

  void _handleAttachmentPressed() { 
    //TODO send current Location
  }

  void _mostrarOpciones(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Opciones'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextButton(
              onPressed: () {
                
              },
              child: const Row(
                children: <Widget>[
                  Icon(Icons.person_add_alt_1,
                  color: Colors.blue,),
                  SizedBox(width: 11),
                  Text('Añadir Pasajero', style: TextStyle(color: Colors.black),),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {

              },
              child: const Row(
                children: <Widget>[
                  Icon(Icons.block,
                  color: Colors.red,),
                  SizedBox(width: 11),
                  Text('Rechazar Pasajero', style: TextStyle(color: Colors.red),),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(125, 193, 165, 1),
        title: Text(widget.userName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              Navigator.of(context).pop();
            });
          },
        ),
        actions:  <Widget>[
          IconButton(
            icon: const Icon(Icons.shield),
            onPressed: () {
              _mostrarOpciones(context);
            },
          ),
        ],
      ),
      body: Chat(
          messages: messages,
          onSendPressed: _handleSendPressed,
          user: user,
          showUserAvatars: true,
          onAttachmentPressed: _handleAttachmentPressed,
          showUserNames: true));
}
