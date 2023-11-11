import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:govoltfrontend/models/message.dart';
import 'package:govoltfrontend/utils/chat_library/flutter_chat_ui.dart';
import 'package:govoltfrontend/services/chat_service.dart';
import 'package:uuid/uuid.dart';
//import 'package:flutter_chat_ui/flutter_chat_ui.dart';

void main() {
  // Cambia la función main para inicializar Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: ChatPage(),
      );
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> messages = [];
  final user = const types.User(id: 'userid', firstName: "Marc");
  final user2 = const types.User(id: 'userid2', firstName: "Lluis");
  final idRuta = "rutaid";
  final chatService = ChatService();
  late StreamSubscription<MessageVolt> messageArrivedSubscription;
  bool messagesLoaded = false;

  @override
  void initState() {
    chatService.setupDatabaseSingleListener("rutaid/userid");
    // Suscríbete al stream en el método initState
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
    chatService.sendMessage(idRuta, user.id, message.text);
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
