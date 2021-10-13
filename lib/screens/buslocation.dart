import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(Busposition(tripid: "",));
}

class Busposition extends StatefulWidget {
  const Busposition({Key? key,required this.tripid}) : super(key: key);
  final String tripid;
  @override
  _BuspositionState createState() => _BuspositionState();
}

class _BuspositionState extends State<Busposition> {
  LatLng center = LatLng(50, 50);
  Future<Position> getposition() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  Set<Marker> markers = {};

  double lat = 0.0;
  double long = 0.0;
  bool loading = true;

  void initState() {
    super.initState();
    getposition().then((value) {
      setState(() {
        lat = value.latitude;
        long = value.longitude;
        center = LatLng(value.latitude, value.longitude);
        loading = false;
      });
    });
  }

  late GoogleMapController mapcontroller;

  void onMapcreated(GoogleMapController controller) {
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(lat, long), zoom: 16),
    ));

    setState(() {
      Marker marker = Marker(
        markerId: MarkerId("Bus Location"),
        position: LatLng(lat, long),
        infoWindow: InfoWindow(
          title: "",
          snippet: "My current location",
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
      markers.add(marker);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios))),
      body: loading
          ? Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  Text("Loading map view...")
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.all(5),
              child: GoogleMap(
                mapType: MapType.normal,
                onMapCreated: onMapcreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat, long),
                  zoom: 16.0,
                ),
                markers: Set<Marker>.from(markers),
              ),
            ),
      floatingActionButton: TextButton.icon(
          onPressed: () {
            StreamSubscription<Position> positionStream =
                Geolocator.getPositionStream(
                        distanceFilter: 10)
                    .listen((Position position) {
              setState(() {
                lat = position.latitude;
                long = position.latitude;
              });

               FirebaseFirestore.instance
                                                    .collection("busloc")
                                                    .doc(widget.tripid)
                                                    .set({
                                                      "busid":widget.tripid,
                                                     "location":{
                                                       "lat":lat,
                                                       "long":long
                                                     }
                                                    });

              print(position == null
                  ? 'Unknown'
                  : position.latitude.toString() +
                      ', ' +
                      position.longitude.toString());
            });
          },
          icon: Icon(Icons.share),
          label: Text("Share Location")),
    ));
  }
}
