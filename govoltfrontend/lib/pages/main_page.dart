import 'package:flutter/material.dart';
import 'mapa/mapa.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(''),
          backgroundColor: const Color.fromRGBO(125, 193, 165, 1),
        ),
        body: MapScreen());
  }
}
