import 'package:flutter/material.dart';
import 'package:govoltfrontend/blocs/application_bloc.dart';
import 'package:govoltfrontend/models/rutas.dart';

class RouteCard extends StatelessWidget {
  final Ruta ruta;
  final bool showJoin;

  RouteCard({super.key,required this.ruta, required this.showJoin});

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
        : null,
      title: Text('Inicio: ${ruta.beginning} Destino: ${ruta.destination}'),
      subtitle: Text('Fecha: ${ruta.date}'),
      children: [
        ListTile(
          title: Text('Conductor: LluisPetardo'),
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
