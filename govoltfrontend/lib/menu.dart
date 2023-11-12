import 'dart:io';

import 'package:flutter/material.dart';
import 'package:govoltfrontend/config.dart';
import 'package:govoltfrontend/pages/mapa/mapa.dart';
import 'package:govoltfrontend/pages/rutas/main_routes.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> {
  int _selectDrawerItem = 0;
  getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return MapScreen();
      case 2:
        return RoutesScreen();
    }
  }

  _onSelectItem(int pos) {
    Navigator.of(context).pop();
    setState(() {
      _selectDrawerItem = pos;
    });
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
              ),
            ),
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
