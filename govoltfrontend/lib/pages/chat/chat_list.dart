import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:govoltfrontend/pages/chat/chat.dart';
import 'package:govoltfrontend/services/chat_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatListVolter extends StatefulWidget {
  const ChatListVolter({super.key});

  @override
  State<ChatListVolter> createState() => _ChatListState();
}

class _ChatListState extends State<ChatListVolter> {
  bool hasImage = false;
  bool showChat = false;
  String userNameChatPressed = "";
  String idRutaPressed = "";
  String idUserPressed = "";
  String idChat = "";
  final chatService = ChatService();
  late List<Map<String, dynamic>> itemList = [];

  static const colors = [
  Color(0xffff6767),
  Color(0xff66e0da),
  Color(0xfff5a2d9),
  Color(0xfff0c722),
  Color(0xff6a85e5),
  Color(0xfffd9a6f),
  Color(0xff92db6e),
  Color(0xff73b8e5),
  Color(0xfffd7590),
  Color(0xffc78ae5),
];

  getChatsMethod() async {
    
    dynamic jsonResponse = await chatService.getChats();
    if (jsonResponse != null)
    {
      Map<String, dynamic> response = jsonDecode(jsonResponse);
      itemList = List.from(response['chats']);
      setState(() {});
    }
  }

  @override
  void initState() {
    if (itemList.isEmpty)
    {
      getChatsMethod();
    }
    super.initState();
  }
  
  
  Widget listChats() {
    return ListView.builder(
      itemCount: itemList.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> item = itemList[index];
        final String userName = item["email"];
        final idRuta = item["room_name"];
        final lastConection = item["last_conection"];
        final idUserReciever = item["userUid_reciever"];
        final myUserId = item["userUid_sender"];
        final creador = item["creator"];
        final idChat = item["id_chat"];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Row(
              children: [
                circleColorCustom(userName),
                const SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () async {
              idUserPressed = idUserReciever;
              userNameChatPressed = userName;
              await Navigator.push(context, MaterialPageRoute(builder: (context) =>  ChatPage(
                idUserReciever: idUserReciever, 
                userName: userName, 
                roomName: idRuta, 
                lastConection: lastConection, 
                myUserId: myUserId, 
                creador: creador,
                chatId: idChat,
                refreshChats: () {
                  getChatsMethod();
                }))
              ).then((result) async {
                  await getChatsMethod();
                  setState(() {});
              });
              setState(() {});
            },
          ),
        );
      },
    );
  }

  Widget circleColorCustom(String username){
    String usernameLastCharacter = username.characters.first;
    final initialsNumber = usernameLastCharacter.codeUnitAt(0) % 10;
    return CircleAvatar(
                  radius: 16,
                  backgroundColor: colors[initialsNumber],
                  child: Text(
                    username.characters.first.toUpperCase(),
                    style:
                        const TextStyle(color: Colors.white),
                  ),
                );
  }
  
  @override
  Widget build(BuildContext context) {
    if (itemList.length != 0)
    {
      return Scaffold(
        body: listChats(),
      );
    }
    else{
      return Scaffold( body: Center(child: Text(AppLocalizations.of(context)!.noChats)));
    }
  }
}
