import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:govoltfrontend/blocs/application_bloc.dart';
import 'package:govoltfrontend/models/message.dart';
import 'package:govoltfrontend/utils/chat_library/flutter_chat_ui.dart';
import 'package:govoltfrontend/services/chat_service.dart';
import 'package:uuid/uuid.dart';
//import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key,
      required this.idUserReciever,
      required this.userName,
      required this.idChat,
      required this.lastConection});

  final String idUserReciever;
  final String userName;
  final String idChat;
  final int lastConection;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> messages = [];
  final user = const types.User(id: 'userid', firstName: "Marc");
  late String roomName;
  late String idChatUser;
  late int lastConection;
  final chatService = ChatService();
  final applicationBloc = AplicationBloc();
  late StreamSubscription<MessageVolt> messageArrivedSubscription;
  bool messagesLoaded = false;
  String idLastMessageReaded = "";

  void loadAllData(int lastConection) async {
    List<MessageVolt> messagesDataLoaded =
        await chatService.loadAllMessagesData(roomName, "userid");
    for (var element in messagesDataLoaded) {
      
        String messageUserId = element.userid;
        String idMessage = Uuid().v4();
        final textMessage = types.TextMessage(
          author: messageUserId == user.id
              ? user
              : types.User(id: widget.idUserReciever, firstName: widget.userName),
          createdAt: int.parse(element.timestamp),
          id: idMessage,
          text: element.content,
        );
        DateTime dateTimeLastConection = DateTime.fromMillisecondsSinceEpoch(lastConection);
        DateTime messageDate = DateTime.fromMillisecondsSinceEpoch(int.parse(element.timestamp));
        if (messageDate.isBefore(dateTimeLastConection))
        {
          idLastMessageReaded = idMessage;
        }
        _addMessage(textMessage);
    }
    messagesLoaded = true;
  }

  @override
  void initState() {
    roomName = widget.idChat;
    idChatUser = widget.idChat;
    lastConection = widget.lastConection;
    if (!messagesLoaded) loadAllData(lastConection);
    chatService.enterChatRoom(roomName);
    //chatService.updateLastConnection(roomName);
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
    chatService.sendMessage(roomName, user.id, message.text);
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
                applicationBloc.addParticipant("userId3", "auAsER3wB1dytm9rDz4w");
                Navigator.of(context).pop();
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
        title: Text(widget.userName, style: const TextStyle(color: Colors.black),),
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
            icon: const Icon(Icons.shield, color: Color(0xff4d5e6b),),
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
          scrollToUnreadOptions: (idLastMessageReaded != "") ?  ScrollToUnreadOptions(
          lastReadMessageId: idLastMessageReaded,
          scrollOnOpen: true
          ): const ScrollToUnreadOptions(),
          //onAttachmentPressed: _handleAttachmentPressed,
          showUserNames: true));
}
