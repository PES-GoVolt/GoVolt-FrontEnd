import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:govoltfrontend/models/bike_station.dart';
import 'package:govoltfrontend/models/markers_data.dart';
import 'package:govoltfrontend/services/achievement_service.dart';
import 'package:govoltfrontend/services/geolocator_service.dart';
import 'package:govoltfrontend/blocs/application_bloc.dart';
import 'package:govoltfrontend/models/mapa/place.dart';
import 'package:govoltfrontend/models/place_search.dart';
import 'package:govoltfrontend/services/puntos_carga_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:govoltfrontend/models/mapa/geometry.dart';
import 'package:govoltfrontend/models/mapa/location.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:govoltfrontend/config.dart';
import 'package:intl/intl.dart';

class MapScreen extends StatefulWidget {
  MapScreen();

  @override
  State<StatefulWidget> createState() => _MapaState();
}

class _MapaState extends State<MapScreen> {
  final GeolocatiorService geolocatiorService = GeolocatiorService();
  final AchievementService achievementService = AchievementService();

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

  bool showChargers = true;
  bool showBikeStations = true;

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
    await achievementService
        .incrementAchievement("search_location_achievement");
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
    Place place =
        Place(geometry: geo, address: "address", name: "name", uri: "uri");
    applicationBloc.chargerFinded(place);
    _goToPlace(place);
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> fetchDataFromApi(
      double? latitud, double? longitud) async {
    DateTime now = DateTime.now();
    DateTime maxDate = now.add(const Duration(days: 7));
    String formattedNow = DateFormat('dd-MM-yyyy').format(now);
    String formattedMaxDate = DateFormat('dd-MM-yyyy').format(maxDate);
    final Uri uri = Uri.https(
      Config.eventsURL,
      Config.eventosAPI,
      {
        'latitud': longitud.toString(),
        'longitud': latitud.toString(),
        'distancia': '2',
        'data_min': formattedNow,
        'data_max': formattedMaxDate,
      },
    );

    try {
      final response = await http.get(uri);
      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
          json.decode(utf8.decode(response.bodyBytes)));
      return data;
    } catch (e) {
      return [];
    }
  }

  Future<void> _showEventBottomSheet() async {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.nearbyEvent,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                FutureBuilder(
                  future: fetchDataFromApi(
                    coordSelected?.latitud,
                    coordSelected?.longitud,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final data = snapshot.data;
                      if (data?.isEmpty ?? true) {
                        return Text(AppLocalizations.of(context)!.noEvents);
                      }
                      return Column(
                        children: data?.map((item) {
                              DateTime fechaInicio =
                                  DateTime.parse(item['dataIni']);
                              String fechaFormateada =
                                  DateFormat.yMMMMd('es_ES')
                                      .format(fechaInicio);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item['nom']}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    fechaFormateada,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "${AppLocalizations.of(context)!.address}: + ${item['adreca']}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Divider(),
                                ],
                              );
                            }).toList() ??
                            [],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Container ChargerInfoDisplay() {
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
                    Icons.directions,
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
                  child: Text(AppLocalizations.of(context)!.exit,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "${coordSelected!.municipi}, ${coordSelected!.provincia}",
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
            const SizedBox(
              height: 10,
            ),
            ElevatedButton.icon(
              onPressed: () async {
                achievementService
                    .incrementAchievement("search_event_achievement");
                await _showEventBottomSheet();
              },
              icon: const Icon(
                Icons.event,
                color: Colors.white,
              ),
              label: Text(
                AppLocalizations.of(context)!.nearbyEvent,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange,
              ),
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
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            onTap: () {
              coordSelected = punto;
              chargerIsSelected = true;
              chargerSelected(punto.latitud, punto.longitud);
              setState(() {});
            });
      }).toSet();
      setState(() {
        _chargers = nuevosMarcadores;
      });
    } catch (e) {
    }
  }

  cargarBicis() {
    try {
      final newMarkers = MarkersData.bikeStation.map((station) {
        return Marker(
            markerId: MarkerId(station.stationId),
            position: LatLng(station.latitude, station.longitude),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            onTap: () {
              chargerIsSelected = false;
              setState(() {});
            });
      }).toSet();
      setState(() {
        _bikeStations = newMarkers;
      });
    } catch (e) {
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
    showBikeStations = false;
    showChargers = false;
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
    List<LatLng> points = [userPosition, LatLng(lat, lng)];
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
              buildRouteLocationRow(Icons.location_searching,
                  AppLocalizations.of(context)!.yourUbication),
              const SizedBox(height: 10),
              buildRouteLocationRow(
                  Icons.location_on, AppLocalizations.of(context)!.destination),
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
        buildRouteModeButton(
            Icons.directions_car, AppLocalizations.of(context)!.car, 0),
        buildRouteModeButton(
            Icons.directions_bike, AppLocalizations.of(context)!.car, 1),
        buildRouteModeButton(
            Icons.directions_walk, AppLocalizations.of(context)!.car, 2),
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
                    Icons.directions,
                    color: Colors.white,
                  ),
                  label: Text(
                    AppLocalizations.of(context)!.route,
                    style: const TextStyle(
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
                    showBikeStations = true;
                    showChargers = true;
                    setState(() {});
                  },
                  child: Text(AppLocalizations.of(context)!.exit,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 16)),
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
                  AppLocalizations.of(context)!.webPage,
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
                    ? AppLocalizations.of(context)!.open
                    : AppLocalizations.of(context)!.closed,
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
                    showBikeStations = false;
                    showChargers = false;
                    showRouteDetails = false;
                    await _changeCameraToRouteMode();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.directions,
                    color: Colors.white,
                  ),
                  label: Text(
                    AppLocalizations.of(context)!.startRoute,
                    style: const TextStyle(
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
                    showBikeStations = true;
                    showChargers = true;
                    setState(() {
                      showRouteDetails = false;
                      if (rutaChargerBike) {
                        chargerIsSelected = true;
                        rutaChargerBike = false;
                      } else {
                        placeIsSelected = true;
                      }
                      applicationBloc.cleanRoute();
                      centerScreen();
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.exit,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 16)),
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
        if (showChargers) ..._chargers,
        if (showBikeStations) ..._bikeStations,
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
          prefixIcon: const Icon(Icons.location_on)),
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
                    achievementService
                        .incrementAchievement("nearest_charger_achievement");
                    goToNearestChargerEnable
                        ? applicationBloc.changePointer(0)
                        : await _goToNearestCharger();
                    goToNearestChargerEnable = !goToNearestChargerEnable;
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.directions,
                    color: Colors.white,
                  ),
                  label: !goToNearestChargerEnable
                      ? Text(
                          AppLocalizations.of(context)!.searchNearestCharger,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.returnToDestination,
                          style: const TextStyle(
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
                    showBikeStations = true;
                    showChargers = true;
                    setState(() {});
                  },
                  child: Text(AppLocalizations.of(context)!.exit,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 16)),
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
      bottomSheet: (placeIsSelected ||
              showRouteDetails ||
              routeStarted ||
              chargerIsSelected)
          ? bottomSheetInfo()
          : null,
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _chooseSearchBarOrRouteDetails(),
          ),
          Expanded(
            child: Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height - 100,
                  child: mapWidget(),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60, right: 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          width: 39,
                          height: 40,
                          child: Align(
                            alignment: Alignment.center,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  showChargers = !showChargers;
                                });
                              },
                              icon: Icon(
                                Icons.ev_station,
                                color: showChargers
                                    ? Colors.green
                                    : const Color(0xff4d5e6b),
                              ),
                              iconSize: 26,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          width: 39,
                          height: 40,
                          child: Align(
                            alignment: Alignment.center,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  showBikeStations = !showBikeStations;
                                });
                              },
                              icon: Icon(
                                Icons.directions_bike,
                                color: showBikeStations
                                    ? Colors.blue
                                    : const Color(0xff4d5e6b),
                              ),
                              iconSize: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return getMapScreen();
  }
}
