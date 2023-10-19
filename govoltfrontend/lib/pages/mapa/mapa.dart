import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:govoltfrontend/blocs/application_bloc.dart';
import 'package:govoltfrontend/models/mapa/place.dart';
import 'package:govoltfrontend/models/place_search.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final LatLng _center = const LatLng(41.303110065444294, 2.0025687347671783);
  final applicationBloc = AplicationBloc();
  List<PlaceSearch>? searchResults;
  late StreamSubscription locationSubscription;

  List<Marker> myMarkers = [];

  Set<Marker> _myLocMarker = {};

  void valueChanged(var value) async {
    await applicationBloc.searchPlaces(value);
    searchResults = applicationBloc.searchResults;
    setState(() {});
  }

  void placeSelected(var idPlace) async {
    await applicationBloc.searchPlace(idPlace);
    _goToPlace(applicationBloc.place!);
    myMarkers.add(Marker(
        markerId: const MarkerId('1'),
        position: LatLng(applicationBloc.place!.geometry.location.lat,
            applicationBloc.place!.geometry.location.lng)));
    _myLocMarker = myMarkers.toSet();
    setState(() {});
  }

  @override
  void dispose() {
    locationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: const Color.fromRGBO(125, 193, 165, 1),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                      hintText: 'Busca tu trayecto ...',
                      suffixIcon: Icon(Icons.person),
                      prefixIcon: Icon(Icons.location_on)),
                  onChanged: (value) {
                    valueChanged(value);
                  },
                ),
              ))
            ],
          ),
          Expanded(
              child: Stack(
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height - 100,
                  child: GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _mapController.complete(controller);
                    },
                    markers: _myLocMarker,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 15.0,
                    ),
                  )),
              if (applicationBloc.searchResults != null &&
                  applicationBloc.searchResults!.isNotEmpty)
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.6),
                      backgroundBlendMode: BlendMode.darken),
                ),
              if (applicationBloc.searchResults != null &&
                  searchResults!.isNotEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: printListView(),
                )
            ],
          )),
        ],
      ),
    );
  }

  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(place.geometry.location.lat, place.geometry.location.lng),
        zoom: 17)));
  }

  ListView printListView() {
    return ListView.builder(
      key: UniqueKey(),
      itemCount: searchResults?.length ?? 0,
      itemBuilder: (context, index) {
        return ListTile(
            onTap: () {
              FocusScope.of(context).unfocus();
              placeSelected(applicationBloc.searchResults![index].placeId);
            },
            title: Text(
              applicationBloc.searchResults![index].description,
              style: const TextStyle(color: Colors.white),
            ));
      },
    );
  }
}
