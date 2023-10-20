import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:govoltfrontend/pages/mapa/mapa.dart';
import 'package:govoltfrontend/services/geolocator_service.dart';
import 'package:provider/provider.dart';
import 'pages/mapa/mapa.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final GeolocatiorService geolocatiorService = GeolocatiorService();

  @override
  Widget build(BuildContext context) {
    return FutureProvider(
        create: (context) => geolocatiorService.getInitialLocation(),
        initialData: null,
        child: MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.green[700],
          ),
          home: Consumer<Position?>(
            builder: (context, position, widget) {
              // ignore: unnecessary_null_comparison
              return (position != null)
                  ? Mapa(
                      initialPosition: position,
                    )
                  : const Center(child: CircularProgressIndicator());
            },
          ),
        ));
  }
}
