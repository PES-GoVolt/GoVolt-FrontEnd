import 'dart:async';

import 'package:flutter/material.dart';
import 'package:govoltfrontend/pages/chat/chat.dart';

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

  List<Map<String, dynamic>> itemList = [
    {
      "name": "Marc",
      "idruta": "rutaid",
      "iduser": "userid2",
      "idChat": "userid"
    },
    {
      "name": "Esther",
      "idruta": "rutaid",
      "iduser": "userid",
      "idChat": "userid2"
    },
    // Agrega más elementos según sea necesario
  ];

  
  Widget listChats() {
    return ListView.builder(
      itemCount: itemList.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> item = itemList[index];
        final String userName = item["name"];
        final idRuta = item["idruta"];
        final idUser = item["iduser"];
        final idChatItem = item["idChat"];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Row(
              children: [
                circleColorCustom(userName, idUser),
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
              idRutaPressed = idRuta;
              idUserPressed = idUser;
              idChat = idChatItem;
              userNameChatPressed = userName;
              await Navigator.push(context, MaterialPageRoute(builder: (context) =>  ChatPage(
                idUserReciever: idUser,
                idRuta: idRuta,
                userName: userName,
                idChat: idChat)
                )
              );
              setState(() {});
            },
          ),
        );
      },
    );
  }

  Widget circleColorCustom(String username, String id){
    String usernameLastCharacter = id.characters.first;
    final initialsNumber = usernameLastCharacter.codeUnitAt(0) % 10;
    return CircleAvatar(
                  radius: 16,
                  backgroundColor: colors[initialsNumber],
                  child: Text(
                    username.characters.first,
                    style:
                        const TextStyle(color: Colors.white),
                  ),
                );
  }
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: listChats(),
    );
  }
}
