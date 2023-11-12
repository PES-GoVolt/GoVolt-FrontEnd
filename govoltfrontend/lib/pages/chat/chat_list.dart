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
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color.fromRGBO(125, 193, 165, 1),
                  child: Text(
                    userName.characters.first,
                    style:
                        const TextStyle(color: Color.fromRGBO(77, 94, 107, 1)),
                  ),
                ),
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
            onTap: () {
              idRutaPressed = idRuta;
              idUserPressed = idUser;
              idChat = idChatItem;
              userNameChatPressed = userName;
              showChat = true;
              setState(() {});
            },
          ),
        );
      },
    );
  }

  Widget showSingleChat(String idUSer, String idRuta, String userName) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userNameChatPressed),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            showChat = false;
            setState(() {});
          },
        ),
      ),
      body: ChatPage(
          idUserReciever: idUSer,
          idRuta: idRuta,
          userName: userName,
          idChat: idChat),
    );
  }

  @override
  Widget build(BuildContext context) {
    return showChat
        ? showSingleChat(idUserPressed, idRutaPressed, userNameChatPressed)
        : listChats();
  }
}
