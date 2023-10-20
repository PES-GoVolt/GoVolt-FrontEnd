import 'package:flutter/material.dart';
import 'package:govoltfrontend/services/geolocator_service.dart';
import 'pages/main_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final GeolocatiorService geolocatiorService = GeolocatiorService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: const MainPage(),
    );
  }
}
