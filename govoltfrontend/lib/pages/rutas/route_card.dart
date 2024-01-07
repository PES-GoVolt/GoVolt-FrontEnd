import 'package:flutter/material.dart';
import 'package:govoltfrontend/blocs/application_bloc.dart';
import 'package:govoltfrontend/models/rutas.dart';
import 'package:govoltfrontend/services/rutas_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RouteCard extends StatelessWidget {
  final Ruta ruta;
  final bool showJoin;
  final bool showCancel;

  RouteCard({Key? key, required this.ruta, required this.showJoin, required this.showCancel}) : super(key: key);

  final applicationBloc = AplicationBloc();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        trailing: _buildTrailingButton(context),
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

  Widget _buildTrailingButton(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            _showParticipantsDialog(context);
          },
          icon: Icon(Icons.group),
        ),
        SizedBox(width: 8), // Ajusta el espacio según sea necesario
        if (showJoin)
          ElevatedButton(
            onPressed: () {
              applicationBloc.createChat(ruta.id, ruta.creator, ruta.creator);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff4d5e6b),
            ),
            child: Text(AppLocalizations.of(context)!.reqToJoin),
          )
        else if (showCancel)
          ElevatedButton(
            onPressed: () {   
              RutaService().cancelRoute(ruta.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff4d5e6b),
            ),
            child: const Text('Cancelar Ruta', style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }

  void _showParticipantsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Participantes Ruta de ${ruta.creatorUsername}'),
          content: SingleChildScrollView(
            child: Column(
              children: _buildParticipantsList(context),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4d5e6b),
              ),
              child: Text('Cerrar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildParticipantsList(BuildContext context) {
  List<String> participants = ruta.participantsName?.cast<String>() ?? [];

  return participants.map((participant) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(participant),
          if (showCancel)
            IconButton(
              onPressed: () {
                _showConfirmationDialog(context, participant);
              },
              icon: Icon(Icons.clear),
              color: const Color(0xff4d5e6b), 
            ),
        ],
      ),
    );
  }).toList();
}


void _showConfirmationDialog(BuildContext context, String participant) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Eliminar participante', style: TextStyle(color: Colors.black)),
        content: Text('¿Estás seguro que quieres eliminar a $participant de la ruta?', style: TextStyle(color: Colors.black)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xff4d5e6b),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.white), 
            ),
          ),
          TextButton(
            onPressed: () {
              _removeParticipant(context, participant);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xff4d5e6b),
            ),
            child: Text(
              'Eliminar',
              style: TextStyle(color: Colors.white), // Color del texto para Eliminar
            ),
          ),
        ],
      );
    },
  );
}


void _removeParticipant(BuildContext context, String participantName) {
    String? participantId = RutaService().getParticipantId(participantName, ruta);
    RutaService().deleteParticipant(ruta.id, participantId!, participantName);
    Navigator.of(context).pop();
}

}
