import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:govoltfrontend/config.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import '../../models/punto_carga.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: inicio(),
      ),
    );
  }
}

class inicio extends StatefulWidget {
  @override
  _MapWithSearchState createState() => _MapWithSearchState();
}

class _MapWithSearchState extends State<inicio> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  
  List<PuntoCarga> puntosDeCarga = [];

  @override
  void initState() {
    super.initState();
    cargarPuntosDeCarga();
  }
  List<Marker> _markers = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar ubicación',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: searchLocation,
              ),
            ),
          ),
        ),
        Flexible(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(41.38961410271446, 2.113365197679868),  // Ubicación inicial
              zoom: 13.0,  // Nivel de zoom inicial
            ),
            layers: [
              TileLayerOptions(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayerOptions(
                markers: _markers,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> searchLocation() async {
    final searchTerm = _searchController.text;
    final response = await http.get(
      Uri.parse('https://nominatim.openstreetmap.org/search?q=$searchTerm&format=json&limit=1'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      if (data.isNotEmpty) {
        final location = data[0];
        final latitude = double.parse(location['lat']);
        final longitude = double.parse(location['lon']);
        final zoom = 13.0;  // Puedes ajustar el nivel de zoom deseado
        _mapController.move(LatLng(latitude, longitude), zoom);
      } else {
        // Manejar el caso en el que no se encontraron resultados
      }
    } else {
      // Manejar el error de búsqueda
    }
  }

  Future<void> cargarPuntosDeCarga() async {
    // Realiza la solicitud a la API y espera los resultados
    final puntosCarga = await obtenerPuntosDeCargaDesdeAPI();
    
    // Crear marcadores a partir de los datos
    final List<Marker> markers = [];
    for (final puntoCarga in puntosCarga) {
      final marker = Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(puntoCarga.latitud, puntoCarga.longitud),
        builder: (ctx) => Container(
          child: Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40.0,
          ),
        ),
      );
      markers.add(marker);
    }

    // Actualiza el estado con los resultados
    setState(() {
      puntosDeCarga = puntosCarga;
      _markers = markers; // Actualiza los marcadores
    });
  }
  Future<List<PuntoCarga>> obtenerPuntosDeCargaDesdeAPI() async {
    final url = Config.puntosCargaAPI; // Reemplaza con la URL real de tu API.
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      List<PuntoCarga> puntosDeCarga = puntosCargaFromJson(response.body);
      
      return puntosDeCarga;
    } else {
      throw Exception('Error al obtener datos de la API');
    }
  }
}