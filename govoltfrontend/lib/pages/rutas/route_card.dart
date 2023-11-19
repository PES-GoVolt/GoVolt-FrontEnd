import 'package:flutter/material.dart';
import 'package:govoltfrontend/models/rutas.dart';

class RouteCard extends StatelessWidget {
  final Ruta ruta;
  final bool showJoin;

  RouteCard({super.key,required this.ruta, required this.showJoin});

  @override
  Widget build(BuildContext context) {
  return Card(
    elevation: 3,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: ExpansionTile(
      trailing: showJoin
        ? ElevatedButton(
            onPressed: () {
              // Cosas marc :)
            },
            child: const Text('Solicitar unirse'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff4d5e6b),
            ),
          )
        : null,
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