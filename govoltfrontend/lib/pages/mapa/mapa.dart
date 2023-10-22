import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:govoltfrontend/services/geolocator_service.dart';
import 'package:govoltfrontend/blocs/application_bloc.dart';
import 'package:govoltfrontend/models/mapa/place.dart';
import 'package:govoltfrontend/models/place_search.dart';
import 'package:govoltfrontend/services/puntos_carga_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  MapScreen();

  @override
  State<StatefulWidget> createState() => _MapaState();
}

class _MapaState extends State<MapScreen> {
  final GeolocatiorService geolocatiorService = GeolocatiorService();
  final Completer<GoogleMapController> _mapController = Completer();
  final LatLng _center = const LatLng(41.303110065444294, 2.0025687347671783);
  final applicationBloc = AplicationBloc();
  List<PlaceSearch>? searchResults;
  late StreamSubscription locationSubscription;
  bool placeIsSelected = false;
  final chargersService = ChargersService("http://127.0.0.1:0080/api");

  List<Marker> myMarkers = [];

  Set<Marker> _myLocMarker = {};

  Set<Marker> _chargers = {};

  void valueChanged(var value) async {
    await applicationBloc.searchPlaces(value);
    searchResults = applicationBloc.searchResults;
    setState(() {});
  }

  void placeSelected(var idPlace) async {
    await applicationBloc.searchPlace(idPlace);
    placeIsSelected = true;
    _goToPlace(applicationBloc.place!);
    myMarkers.clear();
    myMarkers.add(Marker(
        markerId: const MarkerId('1'),
        position: LatLng(applicationBloc.place!.geometry.location.lat,
            applicationBloc.place!.geometry.location.lng)));
    _myLocMarker = myMarkers.toSet();
    setState(() {});
  }

  Future<void> cargarMarcadores() async {
    try {
      // Llama al servicio para obtener los puntos de carga
      final puntosDeCarga = await chargersService.obtenerPuntosDeCarga();

      // Itera a través de los puntos de carga y crea marcadores
      final nuevosMarcadores = puntosDeCarga.map((punto) {
        return Marker(
          markerId:
              MarkerId(punto.chargerId), // Debe ser único para cada marcador
          position: LatLng(punto.longitud, punto.latitud),
          infoWindow: InfoWindow(title: 'Cargador ID: ${punto.chargerId}'),
        );
      }).toSet(); // Convierte la lista de marcadores en un conjunto de marcadores
      // Actualiza el conjunto de marcadores
      setState(() {
        _chargers = nuevosMarcadores;
      });
    } catch (e) {
      print('Error al cargar marcadores: $e');
    }
  }

  @override
  void dispose() {
    locationSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    geolocatiorService.getCurrentLocation().listen((position) {
      centerScreen(position);
    });
    super.initState();
  }

  Future<void> centerScreen(Position position) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 19.0,
    )));
  }

  List<LatLng> points = [
    LatLng(41.38745590006128, 2.172276141806381),
    LatLng(41.30282101632336, 2.002613484100842)
  ];
  Set<Polyline> emptyRoute = {};
  bool showRouteDetails = false;
  String routeDistance = '0';

  Widget buildRouteDetailsContainer() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 25),
              buildRouteModeButtonsRow(),
              const SizedBox(height: 10),
              buildRouteLocationRow(Icons.location_searching, "Your ubication"),
              const SizedBox(height: 10),
              buildRouteLocationRow(Icons.location_on, "Coordenadas Buscadas"),
              const SizedBox(height: 10),
              buildRouteDistanceText(),
            ],
          ),
        ),
        buildRouteCloseButton(),
      ],
    );
  }

  Widget buildRouteModeButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildRouteModeButton(Icons.directions_car, "Car", 0),
        buildRouteModeButton(Icons.directions_bike, "Bicycle", 1),
        buildRouteModeButton(Icons.directions_walk, "Walking", 2),
      ],
    );
  }

  Widget buildRouteModeButton(IconData icon, String label, int mode) {
    return ElevatedButton(
      onPressed: () async {
        await applicationBloc.changePointer(mode);
        setState(() {});
      },
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget buildRouteLocationRow(IconData icon, String labelText) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Expanded(
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            child: Text(
              labelText,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRouteDistanceText() {
    return Container(
      alignment: Alignment.centerRight,
      child: Text(
        "Distancia: ${routeDistance.toString()}",
        style: const TextStyle(
          color: Color.fromRGBO(96, 151, 128, 1),
          fontSize: 16,
        ),
      ),
    );
  }

  Widget buildRouteCloseButton() {
    return Positioned(
      top: 30,
      right: 10,
      child: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          setState(() {
            showRouteDetails = false;
            applicationBloc.cleanRoute();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: placeIsSelected ? _showPlaceInfo() : null,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: !showRouteDetails
                    ? printSearchBar()
                    : buildRouteDetailsContainer(),
              ))
            ],
          ),
          Expanded(
              child: Stack(
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height - 100,
                  child: mapWidget()),
              if (applicationBloc.searchResults != null &&
                  applicationBloc.searchResults!.isNotEmpty)
                blackPageForSearch(),
              if (applicationBloc.searchResults != null &&
                  searchResults!.isNotEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: printListView(),
                ),
            ],
          )),
        ],
      ),
    );
  }

  Container _showPlaceInfo() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color.fromRGBO(77, 94, 107, 1),
          width: 2.0,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: Text(
                    applicationBloc.place!.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await applicationBloc.calculateRoute(points);
                    placeIsSelected = false;
                    showRouteDetails = true;
                    routeDistance =
                        applicationBloc.calculateRouteDistance(points);
                    setState(() {});
                  },
                  icon: Icon(
                    Icons
                        .directions, // Icono de dirección similar al de Google Maps
                    color: Colors.white, // Color del icono
                  ),
                  label: Text(
                    'Ruta', // Texto del botón
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue, // Color del texto en el botón
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    placeIsSelected = false;
                    setState(() {});
                  },
                  child: const Text('X'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              applicationBloc.place!.address,
              style: const TextStyle(fontSize: 16),
            ),
            if (applicationBloc.place!.uri != null)
              GestureDetector(
                onTap: () {
                  Uri url = Uri.parse(applicationBloc.place!.uri!);
                  launchUrl(url);
                },
                child: Text(
                  'Web Page',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            if (applicationBloc.place!.openingHours != null)
              Text(
                applicationBloc.place!.openingHours!.open
                    ? 'Abierto'
                    : 'Cerrado',
                style: TextStyle(
                  color: applicationBloc.place!.openingHours!.open
                      ? Colors.green
                      : Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
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

  GoogleMap mapWidget() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
        cargarMarcadores();
      },
      myLocationEnabled: true,
      markers: {..._myLocMarker, ..._chargers},
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 15.0,
      ),
      polylines: applicationBloc.routevolt
              .routeList[applicationBloc.routevolt.i].routes.isNotEmpty
          ? applicationBloc
              .routevolt.routeList[applicationBloc.routevolt.i].routes
          : emptyRoute,
    );
  }

  Container blackPageForSearch() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(.6),
          backgroundBlendMode: BlendMode.darken),
    );
  }

  TextField printSearchBar() {
    return TextField(
      decoration: const InputDecoration(
          hintText: 'Busca tu trayecto ...',
          suffixIcon: Icon(Icons.person),
          prefixIcon: Icon(Icons.location_on)),
      onChanged: (value) {
        valueChanged(value);
      },
    );
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
