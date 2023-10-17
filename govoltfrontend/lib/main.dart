import 'package:flutter/material.dart';
import 'pages/mapa/mapa.dart';
import 'pages/mapa/utils/locate_position.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: const MyWidgetScreen(),
    );
  }
}
