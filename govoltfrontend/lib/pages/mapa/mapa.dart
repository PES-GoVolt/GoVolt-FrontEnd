import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:govoltfrontend/models/bike_station.dart';
import 'package:govoltfrontend/models/markers_data.dart';
import 'package:govoltfrontend/services/geolocator_service.dart';
import 'package:govoltfrontend/blocs/application_bloc.dart';
import 'package:govoltfrontend/models/mapa/place.dart';
import 'package:govoltfrontend/models/place_search.dart';
import 'package:govoltfrontend/services/puntos_carga_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:govoltfrontend/models/mapa/geometry.dart';
import 'package:govoltfrontend/models/mapa/location.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class MapScreen extends StatefulWidget {
  MapScreen();

  @override
  State<StatefulWidget> createState() => _MapaState();
}

class _MapaState extends State<MapScreen> {


  final GeolocatiorService geolocatiorService = GeolocatiorService();
  final Completer<GoogleMapController> _mapController = Completer();
  final applicationBloc = AplicationBloc();
  late StreamSubscription locationSubscription;

  LatLng userPosition = const LatLng(41.303110065444294, 2.0025687347671783);
  double directionUser = 0;
  bool placeIsSelected = false;
  bool showRouteDetails = false;
  bool routeStarted = false;
  double zoomMap = 19.0;
  bool goToNearestChargerEnable = false;
  late BitmapDescriptor bikeStationIcon;
  bool allDataLoaded = false;
  bool chargerIsSelected = false;
  Coordenada? coordSelected;
  BikeStation? bikeStation;
  bool rutaChargerBike = false;

  List<PlaceSearch>? searchResults;
  List<Marker> myMarkers = [];
  Set<Marker> _myLocMarker = {};
  Set<Marker> _chargers = {};
  Set<Polyline> emptyRoute = {};
  Set<Marker> _bikeStations = {};

  @override
  void initState() {
    geolocatiorService.getCurrentLocation().listen((position) {
      userPosition = LatLng(position.latitude, position.longitude);
      directionUser = position.heading;
      centerScreen();
      allDataLoaded = true;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

/*
  Future<BitmapDescriptor> createCustomMarkerIcon() async {
  return BitmapDescriptor.fromAssetImage(
    ImageConfiguration(size: Size(1000, 1000)),
    'assets/images/bike_icon.png', 
  );
}
*/

  void getMarkers() async {
    await cargarMarcadores();
    await cargarBicis();
  }

  void valueChanged(var value) async {
    await applicationBloc.searchPlaces(
        value, userPosition.latitude, userPosition.longitude);
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

  void placeRandomSelected(double lat, double lng) {
    placeIsSelected = true;
    Location location = Location(lat: lat, lng: lng);
    Geometry geo = Geometry(location: location);
    String latLong = "$lat, $lng";
    applicationBloc.place =
        Place(geometry: geo, address: latLong, name: "", uri: null);
    _goToRandomPlace(lat, lng);
    myMarkers.clear();
    myMarkers
        .add(Marker(markerId: const MarkerId('1'), position: LatLng(lat, lng)));
    _myLocMarker = myMarkers.toSet();
    setState(() {});
  }

  String calculateTime() {
    String timeS = applicationBloc.routevolt.getTime();
    int time = int.parse(timeS.substring(0, timeS.length - 1));
    if (time < 60) {
      return "$time s";
    } else if (time < 3600) {
      int minutos = (time % 3600) ~/ 60;
      return '$minutos min';
    } else {
      int horas = time ~/ 3600;
      int minutos = (time % 3600) ~/ 60;
      return '$horas h $minutos min';
    }
  }

  String prettyDistance() {
    int distance = applicationBloc.routevolt.getDistance();
    if (distance < 1000) {
      return '$distance m';
    } else {
      int km = distance ~/ 1000;
      return '$km km';
    }
  }

  Future<void> _goToRandomPlace(double lat, double lng) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 17)));
  }

  void chargerSelected(double lat, double lng) async {
    Location loc = Location(lat: lng, lng: lat);
    Geometry geo = Geometry(location: loc);
    Place place = Place(geometry: geo, address: "address", name: "name", uri: "uri");
    applicationBloc.chargerFinded(place);
    _goToPlace(place);
    setState(() {});
  }

  Container ChargerInfoDisplay()
  {
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
                    coordSelected!.adre_a,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    chargerIsSelected = false;
                    rutaChargerBike = true;
                    await _calculateRoute();
                    await _changeCameraToRoutePreview();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons
                        .directions,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Ruta',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red)),
                  onPressed: () {
                    chargerIsSelected = false;
                    setState(() {});
                  },
                  child: const Text('Salir',
                      style: TextStyle(color: Colors.black, fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              coordSelected!.municipi + ", " + coordSelected!.provincia,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.payment + coordSelected!.acces,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              "${coordSelected!.tipus_connexi}, ${coordSelected!.ac_dc}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  cargarMarcadores() {
    try {
      final nuevosMarcadores = MarkersData.chargers.map((punto) {
        return Marker(
          markerId: MarkerId(punto.chargerId),
          position: LatLng(punto.longitud, punto.latitud),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          onTap: () {
            coordSelected = punto;
            chargerIsSelected = true;
            chargerSelected(punto.latitud, punto.longitud);
            setState(() {});
          }
        );
      }).toSet();
      setState(() {
        _chargers = nuevosMarcadores;
      });
    } catch (e) {
      print('Error al cargar marcadores: $e');
    }
  }

  cargarBicis() {
    try {
      final newMarkers = MarkersData.bikeStation.map((station) {
        return Marker(
          markerId:
              MarkerId(station.stationId),
          position: LatLng(station.latitude, station.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );
      }).toSet(); 
      setState(() {
        _bikeStations = newMarkers;
      });
    } catch (e) {
      print('Error loading markers: $e');
    }
  }

  Future<void> centerScreen() async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: (placeIsSelected || showRouteDetails)
            ? LatLng(applicationBloc.place!.geometry.location.lat,
                applicationBloc.place!.geometry.location.lng)
            : LatLng(userPosition.latitude, userPosition.longitude),
        zoom: zoomMap,
        bearing: routeStarted ? directionUser : 0.0)));
  }

  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller = await _mapController.future;
    zoomMap = 17;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(place.geometry.location.lat, place.geometry.location.lng),
        zoom: 17)));
  }

  Future<void> _changeCameraToRoutePreview() async {
    placeIsSelected = false;
    showRouteDetails = true;
    routeStarted = false;
    zoomMap = 14;
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(applicationBloc.place!.geometry.location.lat,
            applicationBloc.place!.geometry.location.lng),
        zoom: 14)));
  }

  Future<void> _calculateRoute() async {
    List<LatLng> points = [
      userPosition,
      LatLng(applicationBloc.place!.geometry.location.lat,
          applicationBloc.place!.geometry.location.lng)
    ];
    await applicationBloc.calculateRoute(points);
  }

  Future<void> _calculateRouteCharger(double lat, double lng) async {
    List<LatLng> points = [
      userPosition,
      LatLng(lat,
          lng)
    ];
    await applicationBloc.calculateRoute(points);
  }

  Future<void> _changeCameraToRouteMode() async {
    final GoogleMapController controller = await _mapController.future;
    zoomMap = 19;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(userPosition.latitude, userPosition.longitude),
        zoom: 19,
        bearing: directionUser)));
  }

  Future<void> _goToNearestCharger() async {
    LatLng coord = LatLng(userPosition.latitude, userPosition.longitude);
    applicationBloc.changePointer(3);
    LatLng nearestCharger = await applicationBloc.searchNearestCharger(coord);
    List<LatLng> points = [
      userPosition,
      LatLng(nearestCharger.latitude, nearestCharger.longitude)
    ];
    await applicationBloc.calculateRouteToCharger(points);

    setState(() {});
  }

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
              buildRouteModeButtonsRow(),
              const SizedBox(height: 10),
              buildRouteLocationRow(Icons.location_searching, "Your ubication"),
              const SizedBox(height: 10),
              buildRouteLocationRow(Icons.location_on, "Coordenadas Buscadas"),
            ],
          ),
        ),
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

  Container bottomSheetInfo() {
    if (placeIsSelected) return _showPlaceInfo();

    if (chargerIsSelected) return ChargerInfoDisplay();

    if (routeStarted == true) return bottomSheetDisplayedDuringRoute();

    return _routeInfo();
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
                    await _calculateRoute();
                    await _changeCameraToRoutePreview();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons
                        .directions,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Ruta',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red)),
                  onPressed: () {
                    placeIsSelected = false;
                    setState(() {});
                  },
                  child: const Text('Salir',
                      style: TextStyle(color: Colors.black, fontSize: 16)),
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
                child: const Text(
                  'Web Page',
                  style: TextStyle(
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

  Container _routeInfo() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
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
                    calculateTime(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    routeStarted = true;
                    showRouteDetails = false;
                    await _changeCameraToRouteMode();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons
                        .directions,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Iniciar Ruta',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red)),
                  onPressed: () {
                    placeIsSelected = false;
                    setState(() {
                      showRouteDetails = false;
                      if (rutaChargerBike){
                        chargerIsSelected = true;
                          rutaChargerBike = false;
                      }
                      else{
                        placeIsSelected = true;
                        }
                      applicationBloc.cleanRoute();
                      centerScreen();
                    });
                  },
                  child: const Text('Salir',
                      style: TextStyle(color: Colors.black, fontSize: 16)),
                ),
              ],
            ),
            Text(
              prettyDistance(),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  GoogleMap mapWidget() {
    return GoogleMap(
      onLongPress: (LatLng latLng) {
        placeRandomSelected(latLng.latitude, latLng.longitude);
      },
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
        cargarBicis();
        cargarMarcadores();
      },
      myLocationEnabled: true,
      
      markers: {
        ..._chargers,
        ..._bikeStations,
        ..._myLocMarker,
      },
      initialCameraPosition: CameraPosition(target: userPosition, zoom: 15.0),
      polylines: applicationBloc
              .routevolt.routeList[applicationBloc.routevolt.i].route.isNotEmpty
          ? applicationBloc
              .routevolt.routeList[applicationBloc.routevolt.i].route
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
      decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchYourRoute,
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
              chargerIsSelected = false;
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

  Widget _chooseSearchBarOrRouteDetails() {
    if (!showRouteDetails) return printSearchBar();

    return buildRouteDetailsContainer();
  }

  Container bottomSheetDisplayedDuringRoute() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      padding: const EdgeInsets.all(16),
      color: Colors.blue.withOpacity(0.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    goToNearestChargerEnable
                        ? applicationBloc.changePointer(0)
                        : await _goToNearestCharger();
                    goToNearestChargerEnable = !goToNearestChargerEnable;
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons
                        .directions,
                    color: Colors.white,
                  ),
                  label: !goToNearestChargerEnable
                      ? const Text(
                          'Buscar cargador cercano',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Volver a destino original',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue, 
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red)),
                  onPressed: () async {
                    await _changeCameraToRoutePreview();
                    setState(() {});
                  },
                  child: const Text('Salir',
                      style: TextStyle(color: Colors.black, fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getMapScreen() {
    return Scaffold(
      bottomSheet: (placeIsSelected || showRouteDetails || routeStarted || chargerIsSelected)
          ? bottomSheetInfo()
          : null,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: !routeStarted ? _chooseSearchBarOrRouteDetails() : null,
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

  @override
  Widget build(BuildContext context) {
    return getMapScreen();
  }
}
