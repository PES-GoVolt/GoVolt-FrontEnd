import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:govoltfrontend/blocs/application_bloc.dart';
import 'package:govoltfrontend/models/place_search.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(41.303110065444294, 2.0025687347671783);
  final applicationBloc = AplicationBloc();
  List<PlaceSearch>? searchResults;

  static const Marker _myLocMarker = Marker(
    markerId: MarkerId('_myLocMarker'),
    infoWindow: InfoWindow(title: "TEST"),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(41.303110065444294, 2.0025687347671783),
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void valueChanged(var value) async {
    await applicationBloc.searchPlaces(value);
    searchResults = applicationBloc.searchResults;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                  hintText: 'Search Location', suffixIcon: Icon(Icons.search)),
              onChanged: (value) {
                valueChanged(value);
              },
            ),
          ),
          Stack(
            children: [
              SizedBox(
                  height: 300,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    markers: {_myLocMarker},
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 15.0,
                    ),
                  )),
              if (applicationBloc.searchResults != null &&
                  applicationBloc.searchResults!.isNotEmpty)
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.6),
                      backgroundBlendMode: BlendMode.darken),
                ),
              if (applicationBloc.searchResults != null)
                SizedBox(
                  height: 300,
                  child: printListView(),
                )
            ],
          )
        ],
      ),
    );
  }

  ListView printListView() {
    return ListView.builder(
      key: UniqueKey(),
      itemCount: searchResults?.length ?? 0,
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(
          applicationBloc.searchResults![index].description,
          style: const TextStyle(color: Colors.white),
        ));
      },
    );
  }
}
