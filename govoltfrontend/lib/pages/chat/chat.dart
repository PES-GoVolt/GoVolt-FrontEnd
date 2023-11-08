import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:uuid/uuid.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
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
  List<Message> _messages = [];
  final currentUser = ChatUser(id: "1", name: "Marc");

  final chatController = ChatController(
    initialMessageList: [],
    scrollController: ScrollController(),
  );

  @override
  void initState() {
    super.initState();
  }

  void onSendTap(String messageText, ReplyMessage replyMessage) {
    final message = Message(
      id: const Uuid().v4(),
      message: messageText,
      createdAt: DateTime.now(),
      sendBy: currentUser.id,
    );
    chatController.addMessage(message);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ChatView(
          sender: currentUser,
          receiver: ChatUser(id: '2', name: 'Simform'),
          chatController: chatController,
          onSendTap: onSendTap,
        ),
      );
}
