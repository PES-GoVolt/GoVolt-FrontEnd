import 'package:flutter/material.dart';
import 'package:govoltfrontend/blocs/application_bloc.dart';
import 'package:govoltfrontend/models/rutas.dart';
import 'package:govoltfrontend/services/rutas_service.dart';

class RouteCard extends StatelessWidget {
  final Ruta ruta;
  final bool showJoin;
  final bool showCancel;

  RouteCard({super.key,required this.ruta, required this.showJoin, required this.showCancel});

  final applicationBloc = AplicationBloc();

  @override
  Widget build(BuildContext context) {
  return Card(
    elevation: 3,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: ExpansionTile(
      trailing: showJoin
        ? ElevatedButton(
            onPressed: () {
              applicationBloc.createChat(ruta.id, ruta.creator, ruta.creator);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff4d5e6b),
            ),
            child: const Text('Solicitar unirse'),
          )
        : showCancel
        ? ElevatedButton(
            onPressed: () {
               RutaService().cancelRoute(ruta.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff4d5e6b),
            ),
            child: const Text('Cancelar Ruta'),
          )
        : null,
      title: Text('Inicio: ${ruta.beginning} Destino: ${ruta.destination}'),
      subtitle: Text('Fecha: ${ruta.date}'),
      children: [
        ListTile(
          title: Text('Conductor: ${ruta.creatorUsername}'),
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
