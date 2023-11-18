import 'package:flutter/material.dart';
import 'package:govoltfrontend/models/rutas.dart';

class RouteCard extends StatelessWidget {
  final Ruta ruta;

  RouteCard({required this.ruta});

  @override
  Widget build(BuildContext context) {
  return Card(
    elevation: 3,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: ExpansionTile(
      trailing: ElevatedButton(
        onPressed: () {
          // Lógica para unirse a la ruta :)
        },
        child: const Text('Unirse'),
        style: ElevatedButton.styleFrom(
          backgroundColor:  Color(0xff4d5e6b)
          )
      ),
      title: Text('Inicio: ${ruta.beginning} Destino: ${ruta.destination}'),
      subtitle: Text('Fecha: ${ruta.date}'),
      children: [
        ListTile(
          title: Text('Conductor: ${ruta.creator}'),
        ),
        ListTile(
          title: Text('Número de plazas: ${ruta.seats}'),
        ),
        ListTile(
          title: Text('Precio Aproximado: €${ruta.price}'),
        ),
      ],
      
    ),
  );
}

}
