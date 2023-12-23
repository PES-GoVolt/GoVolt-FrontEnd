import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:govoltfrontend/blocs/application_bloc.dart';
import 'package:govoltfrontend/models/message.dart';
import 'package:govoltfrontend/services/achievement_service.dart';
import 'package:govoltfrontend/utils/chat_library/flutter_chat_ui.dart';
import 'package:govoltfrontend/services/chat_service.dart';
import 'package:uuid/uuid.dart';
//import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key,
      required this.idUserReciever,
      required this.userName,
      required this.roomName,
      required this.lastConection, 
      required this.myUserId, 
      required this.creador, 
      required this.chatId, 
      required this.refreshChats});

  final String idUserReciever;
  final String myUserId;
  final bool creador;
  final String userName;
  final String roomName;
  final int lastConection;
  final String chatId;
  final Function refreshChats;
  


  @override
  State<ChatPage> createState() => _ChatPageState();
  
}

final AchievementService achievementService = AchievementService();

class _ChatPageState extends State<ChatPage> {
  List<types.Message> messages = [];

  late String roomName;
  late String idUserReciever;
  late int lastConection;
  late bool creador;
  late String myUserId;
  late String userName;
  late String chatId;

  final chatService = ChatService();
  final applicationBloc = AplicationBloc();
  late StreamSubscription<MessageVolt> messageArrivedSubscription;
  bool messagesLoaded = false;
  String idLastMessageReaded = "";

  void loadAllData(int lastConection) async {
    List<MessageVolt> messagesDataLoaded =
        await chatService.loadAllMessagesData(roomName);
    for (var element in messagesDataLoaded) {
        String messageUserId = element.userid;
        String idMessage = Uuid().v4();
        final textMessage = types.TextMessage(
          author: (messageUserId == myUserId || (messageUserId == "DefaultUser" && !creador))
              ? types.User(id: myUserId)
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
    roomName = widget.roomName;
    idUserReciever = widget.idUserReciever;
    lastConection = widget.lastConection;
    creador = widget.creador;
    myUserId = widget.myUserId;
    userName = widget.userName;
    chatId = widget.chatId;

    if (!messagesLoaded) loadAllData(lastConection);
    chatService.enterChatRoom(roomName, myUserId);
    chatService.updateLastConnection(chatId);
    final user2 =
        types.User(id: widget.idUserReciever, firstName: widget.userName);
    super.initState();
    
    messageArrivedSubscription =
        chatService.onMessageArrivedChanged.listen((messageArrived) {
      String messageUserId = ChatService.message.userid;
      final textMessage = types.TextMessage(
        author: messageUserId == myUserId ? types.User(id: myUserId) : user2,
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
    widget.refreshChats();
    super.dispose();
  }

  void _addMessage(types.Message message) {
    setState(() {
      messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    
    final textMessage = types.TextMessage(
      author: types.User(id: myUserId),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text: message.text,
    );
    chatService.sendMessage(roomName, myUserId, message.text);
    _addMessage(textMessage);
    achievementService.incrementAchievement("messages_achievement");  
  }

  void _handleAttachmentPressed() { 
    //TODO send current Location
  }

  List<Widget> opcionesCreador()
  {
    return [
      TextButton(
        onPressed: () {
          applicationBloc.addParticipant(idUserReciever, roomName.split("/")[0]);
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
    ];
  }

  List<Widget> opcionesPasajero()
  {
    return [
      TextButton(
        onPressed: () {
        },
        child: const Row(
          children: <Widget>[
            Icon(Icons.block,
            color: Colors.red,),
            SizedBox(width: 11),
            Text('Bloquear Usuario', style: TextStyle(color: Colors.red),),
          ],
        ),
      ),    
    ];
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
            creador ? Column(children: opcionesCreador()) : Column(children: opcionesPasajero())
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
          user: types.User(id: myUserId),
          showUserAvatars: true,
          scrollToUnreadOptions: (idLastMessageReaded != "") ?  ScrollToUnreadOptions(
          lastReadMessageId: idLastMessageReaded,
          scrollOnOpen: true
          ): const ScrollToUnreadOptions(),
          //onAttachmentPressed: _handleAttachmentPressed,
          showUserNames: true));
}
