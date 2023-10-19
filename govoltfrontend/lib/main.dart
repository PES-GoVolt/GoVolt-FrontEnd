import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:govoltfrontend/services/puntos_carga_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(41.386058, 2.116819);
  Set<Marker> _markers = {}; // Conjunto de marcadores vacío al principio

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    cargarMarcadores();
  }

  final chargersService = ChargersService("http://127.0.0.1:0080/api"); // Corrige la URL

  Future<void> cargarMarcadores() async {
    try {
      // Llama al servicio para obtener los puntos de carga
      final puntosDeCarga = await chargersService.obtenerPuntosDeCarga();
      
      // Itera a través de los puntos de carga y crea marcadores
      print("hola1");
      final nuevosMarcadores = puntosDeCarga.map((punto) {
        print("hola2");
        return Marker(
          markerId: MarkerId(punto.chargerId), // Debe ser único para cada marcador
          position: LatLng(punto.longitud, punto.latitud),
          infoWindow: InfoWindow(title: 'Cargador ID: ${punto.chargerId}'),
        );
  
      }).toSet(); // Convierte la lista de marcadores en un conjunto de marcadores
      print("hola3");    
      // Actualiza el conjunto de marcadores
      setState(() {
        print(nuevosMarcadores);
        _markers = nuevosMarcadores;
      });
      print("hola4");
    } catch (e) {
      print('Error al cargar marcadores: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Maps Sample App'),
          elevation: 2,
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          markers: _markers, // Usa el conjunto de marcadores actual
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 15.0,
          ),
        ),
      ),
    );
  }
}
