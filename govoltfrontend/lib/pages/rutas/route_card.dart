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
        title: Text('${AppLocalizations.of(context)!.start}: ${ruta.beginning} ${AppLocalizations.of(context)!.destination}: ${ruta.destination}'),
        subtitle: Text('${AppLocalizations.of(context)!.date}: ${ruta.date}'),
        children: [
          ListTile(
            title: Text('${AppLocalizations.of(context)!.driver}: ${ruta.creatorUsername}'),
          ),
          ListTile(
            title: Text('${AppLocalizations.of(context)!.numberOfSeats}: ${ruta.seats}'),
          ),
          ListTile(
            title: Text('${AppLocalizations.of(context)!.approximatePrice}: €${ruta.price}'),
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
          icon: const Icon(Icons.group),
        ),
        const SizedBox(width: 8), 
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
            child: Text(AppLocalizations.of(context)!.cancelRoute, style: const TextStyle(color: Colors.white)),
          ),
      ],
    );
  }

  void _showParticipantsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${AppLocalizations.of(context)!.routeParticipants}: ${ruta.creatorUsername}'),
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
              child: Text(AppLocalizations.of(context)!.close, style: const TextStyle(color: Colors.white)),
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
              icon: const Icon(Icons.clear),
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
        title: Text(AppLocalizations.of(context)!.deleteParticipant, style: const TextStyle(color: Colors.black)),
        content: Text('${AppLocalizations.of(context)!.areYouSureDelete} $participant?', style: const TextStyle(color: Colors.black)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xff4d5e6b),
            ),
            child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              _removeParticipant(context, participant);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xff4d5e6b),
            ),
            child: Text(AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: Colors.white),
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
