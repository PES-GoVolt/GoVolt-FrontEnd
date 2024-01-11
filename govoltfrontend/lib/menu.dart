import 'dart:async';
import 'package:flutter/material.dart';
import 'package:govoltfrontend/pages/chat/chat_list.dart';
import 'package:govoltfrontend/pages/mapa/mapa.dart';
import 'package:govoltfrontend/pages/user/volter.dart';
import 'package:govoltfrontend/services/chat_service.dart';
import 'package:govoltfrontend/services/notification.dart';
import 'package:govoltfrontend/services/notifications_service.dart';
import 'package:govoltfrontend/pages/rutas/main_routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> {
  int _selectDrawerItem = 0;
  ChatService chatService = ChatService();
  late StreamSubscription<String> messageArrivedSubscription;
  late StreamSubscription<String> reportArrivedSubscription;
  late StreamSubscription<bool> showAppbarSubscription;
  ChatListVolter chatList = ChatListVolter();
  NotificationService notificationService = NotificationService();
  
  getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return MapScreen();
      case 1:
        return VolterScreen();
      case 2:
        return const RoutesScreen();
      case 3:
        return ChatListVolter();
    }
  }

  void logout() {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  _onSelectItem(int pos) {
    Navigator.of(context).pop();
    setState(() {
      _selectDrawerItem = pos;
    });
  }

  Future<dynamic> getUSerID() async{
    return ;
  }

  @override
  void initState() {
    chatService.setupDatabaseAllListeners();

    messageArrivedSubscription =
        chatService.onMessageArrivedNotificationChanged.listen((messageArrived) {
          List<String> parts = messageArrived.split("_");
          LocalNotificationService.showNotificationAndroid(parts[0], parts[1]);
        });
    reportArrivedSubscription =
        notificationService.onMessageArrivedNotificationChanged.listen((messageArrived) {
          int numberOfReports = int.parse(messageArrived);
          String numberOfReportsString = (5-numberOfReports).toString();
          if (numberOfReports == 5)
          {
              Navigator.pop(context);
              Navigator.pop(context);
          }
          LocalNotificationService.showNotificationAndroid("Report Warning", "You have, $numberOfReportsString reports until your account gets deleted");
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
        toolbarHeight: 100.0,
      ),
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const UserAccountsDrawerHeader(
              accountName: Text(""),
              accountEmail: Text(''),
              decoration: BoxDecoration(
                color: Color.fromRGBO(125, 193, 165,1),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.profile),
              leading: const Icon(Icons.person),
              selected: (1 == _selectDrawerItem),
              onTap: () {
                _onSelectItem(1);
              },
            ),
            const Divider(),
            ListTile(
              title: Text(AppLocalizations.of(context)!.map),
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
              title: Text(AppLocalizations.of(context)!.chat),
              leading: const Icon(Icons.chat),
              selected: (3 == _selectDrawerItem),
              onTap: () {
                _onSelectItem(3);
              },
            ),
            const Divider(),
            ListTile(
              title: Text(AppLocalizations.of(context)!.logOut),
              leading: const Icon(Icons.touch_app_outlined),
              selected: (3 == _selectDrawerItem),
              onTap: () {
                logout();
              },
            ),
          ],
        ),
      ),
      body: getDrawerItemWidget(_selectDrawerItem),
    );
  }
}