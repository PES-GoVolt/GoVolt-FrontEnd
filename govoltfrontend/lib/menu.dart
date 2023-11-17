import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:govoltfrontend/pages/chat/chat_list.dart';
import 'package:govoltfrontend/pages/mapa/mapa.dart';
import 'package:govoltfrontend/services/chat_service.dart';
import 'package:govoltfrontend/services/notifications_service.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> {
  int _selectDrawerItem = 0;
  ChatService chatService = ChatService();
  late StreamSubscription<String> messageArrivedSubscription;
  late StreamSubscription<bool> showAppbarSubscription;
  ChatListVolter chatList = ChatListVolter();
  getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return MapScreen();
      case 3:
        return ChatListVolter();
      case 1:
        return VolterScreen();
    }
  }

  _onSelectItem(int pos) {
    Navigator.of(context).pop();
    setState(() {
      _selectDrawerItem = pos;
    });
  }

  @override
  void initState() {
    chatService.setupDatabaseSingleListener();
    messageArrivedSubscription =
        chatService.onMessageArrivedNotificationChanged.listen((messageArrived) {
          List<String> parts = messageArrived.split("_");
          LocalNotificationService.showNotificationAndroid(parts[0], parts[1]);
        });
    super.initState();
  }

  @override
  void dispose() {
    messageArrivedSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(125, 193, 165, 1),
        title: const Text(""),
      ),
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const UserAccountsDrawerHeader(
              accountName: Text(""),
              accountEmail: Text(''),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(125, 193, 165,
                    1), // Cambia este color según tus preferencias
              accountName: Text(""),
              accountEmail: Text(''),
              decoration: BoxDecoration(
                color: Color.fromRGBO(125, 193, 165,
                    1), // Cambia este color según tus preferencias
              ),
            ),
            ListTile(
              title: const Text('Inicio'),
              leading: const Icon(Icons.map),
              selected: (0 == _selectDrawerItem),
              onTap: () {
                _onSelectItem(0);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Perfil'),
              leading: const Icon(Icons.person),
              selected: (1 == _selectDrawerItem),
              onTap: () {
                _onSelectItem(1);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Mapa'),
              leading: const Icon(Icons.map),
              selected: (0 == _selectDrawerItem),
              onTap: () {
                _onSelectItem(0);
              },
            ),
            ListTile(
              title: const Text('Volters'),
              leading: const Icon(Icons.directions_car),
              selected: (2 == _selectDrawerItem),
              onTap: () {
                _onSelectItem(2);
              },
            ),
            ListTile(
              title: const Text('Chat'),
              leading: const Icon(Icons.chat),
              selected: (3 == _selectDrawerItem),
              onTap: () {
                _onSelectItem(3);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Cerra Sessión'),
              leading: const Icon(Icons.touch_app_outlined),
              selected: (3 == _selectDrawerItem),
              onTap: () {
                exit(0);
              },
            ),
          ],
        ),
      ),
      body: getDrawerItemWidget(_selectDrawerItem),
    );
  }
}
