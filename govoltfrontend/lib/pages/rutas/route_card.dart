import 'package:flutter/material.dart';
import 'package:govoltfrontend/models/rutas.dart';

class RouteCard extends StatelessWidget {
  final Ruta ruta;

  RouteCard({required this.ruta});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        title: Text('Inicio: ${ruta.inicio} Destino: ${ruta.destino}'),
        subtitle:  Text('Fecha: ${ruta.fecha}'),
        children: [
          ListTile(
            title: Text('Conductor: ${ruta.creador}')
          ),
          ListTile(
            title: Text('Tiempo Aproximado: ${ruta.tiempoAproximado} minutos'),
          ),
          ListTile(
            title: Text('Precio Aproximado: \€${ruta.precio.toStringAsFixed(2)}'),
          ),
        ],
      ),
    );
  }
}
