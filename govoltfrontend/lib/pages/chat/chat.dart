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

  @override
  void initState() {
    idRuta = widget.idRuta;
    idChatUser = widget.idChat;
    chatService.setupDatabaseSingleListener("$idRuta/$idChatUser");
    // Suscríbete al stream en el método initState
    final user2 =
        types.User(id: widget.idUserReciever, firstName: widget.userName);
    messageArrivedSubscription =
        chatService.onMessageArrivedChanged.listen((messageArrived) {
      String messageUserId = chatService.message.userid;
      final textMessage = types.TextMessage(
        author: messageUserId == user.id ? user : user2,
        createdAt: int.parse(chatService.message.timestamp),
        id: Uuid().v4(),
        text: chatService.message.content,
      );
      _addMessage(textMessage);
    });
    super.initState();
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

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Chat(
          messages: messages,
          onSendPressed: _handleSendPressed,
          user: user,
          showUserAvatars: true,
          showUserNames: true));
}
