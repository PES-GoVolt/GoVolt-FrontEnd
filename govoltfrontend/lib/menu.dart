import 'dart:io';

import 'package:flutter/material.dart';
import 'package:govoltfrontend/config.dart';
import 'package:govoltfrontend/pages/mapa/mapa.dart';
import 'pages/crear_viaje/create_route.dart';

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
      case 4: // Add this case for "CrearViaje" screen
      return CrearViajeScreen();
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
              accountName: Text(Config.appName),
              accountEmail: Text('contaco@xyz.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/images/logoxyz.png'),
              ),
            ),
            ListTile(
              title: const Text('Inicio'),
              leading: const Icon(Icons.phone),
              selected: (0 == _selectDrawerItem),
              onTap: () {
                _onSelectItem(0);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Clientes'),
              leading: const Icon(Icons.person),
              selected: (1 == _selectDrawerItem),
              onTap: () {
                _onSelectItem(1);
              },
            ),
            ListTile(
              title: const Text('Productos'),
              leading: const Icon(Icons.wind_power_rounded),
              selected: (2 == _selectDrawerItem),
              onTap: () {
                _onSelectItem(2);
              },
            ),
            ListTile(
              title: const Text('Ventas'),
              leading: const Icon(Icons.production_quantity_limits),
              selected: (3 == _selectDrawerItem),
              onTap: () {
                _onSelectItem(3);
              },
            ),
            ListTile(
              title: const Text('Addviajes'), // New button
              leading: const Icon(Icons.add), // Icon for the new button
              selected: (4 == _selectDrawerItem), // Change the index to match the desired selection index.
              onTap: () {


                /*AQUI ES DONDE TENGO QUE NAVEGAR AL ADD VIAJES!!!!*/ 


                _onSelectItem(4); // Change the index to match the desired selection index.
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => CrearViajeScreen()));
                // Add your logic for handling the "Addviajes" button tap here.
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Cerra Sessión'),
              leading: const Icon(Icons.touch_app_outlined),
              selected: (5 == _selectDrawerItem),
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
