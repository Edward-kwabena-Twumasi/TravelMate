import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'homepage.dart';
//import 'package:geocoding/geocoding.dart';

void main() => runApp(Mymap());

class Mymap extends StatefulWidget {
  @override
  _MymapState createState() => _MymapState();
}

class _MymapState extends State<Mymap> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Showmap(),
    );
  }
}

class Showmap extends StatefulWidget {
  const Showmap({Key? key}) : super(key: key);

  @override
  _ShowmapState createState() => _ShowmapState();
}

class _ShowmapState extends State<Showmap> {
  Set<Marker> markers = {};

  Future<Position> getposition() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  Future<List<Placemark>> getplacmark(double lat, double long) async {
    return await GeocodingPlatform.instance.placemarkFromCoordinates(lat, long);
  }

  List stationcitycords = [];
  Future<List<dynamic>> stationcity() async {
    var docs = await FirebaseFirestore.instance
        .collection("appstrings")
        .doc("cordinates")
        .collection("stations")
        .where("city", isEqualTo: "Kumasi")
        .get();
    return docs.docs;
  }

  TextEditingController tripid = TextEditingController();
  Future<List<dynamic>> busloc() async {
    var docs = await FirebaseFirestore.instance
        .collection("appstrings")
        .doc("busloc")
        .collection("stations")
        .where("city", isEqualTo: "kumasi")
        .get();
    return docs.docs;
  }

  Marker mymark = Marker(markerId: MarkerId("value"));
  var distancebtwn = [];
  int idx = -1;
  int distance = 0;
  String locality = "";
  String city = "";
  double lat = 0.0, long = 0.0;
  double lat1 = 0.0, long1 = 0.0;
  bool loading = true;
  String incity = "Kumasi";
  LatLng _center = LatLng(50, 50);
  @override
  void initState() {
    super.initState();

    getposition().then((value) {
      setState(() {
        _center = LatLng(value.latitude, value.longitude);
        lat = value.latitude;
        long = value.longitude;
      });
      getplacmark(value.latitude, value.longitude).then((val) {
        setState(() {
          city = val.first.name! +
              " , " +
              val.first.locality! +
              " , " +
              val.first.subLocality!;
          loading = false;
          incity = val.first.locality!;
        });
      });
    });

    stationcity().then((value) {
      setState(() {
        stationcitycords = value;
      });
      for (var item in value) {
        print(item["name"]);
      }
    });
    // print(_center);
  }

  late GoogleMapController mapcontroller;

  void _onMapCreated(GoogleMapController controller) {
    mapcontroller = controller;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _center, zoom: 16),
    ));

    for (var item in stationcitycords) {
      Marker marker = Marker(
        markerId: MarkerId(item["name"]),
        position: LatLng(item["cordinates"][0], item["cordinates"][1]),
        infoWindow: InfoWindow(
          title: item["city"],
          snippet: item["name"],
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
      setState(() {
        markers.add(marker);
      });
    }
    setState(() {
      mymark = Marker(
        markerId: MarkerId("Current loc"),
        position: LatLng(lat, long),
        infoWindow: InfoWindow(
          title: city,
          snippet: "My current location",
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
      markers.add(mymark);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Card(
          child: Row(
            children: [
              TextButton.icon(
                  onPressed: () {
                    StreamSubscription<Position> positionStream =
                        Geolocator.getPositionStream(distanceFilter: 5)
                            .listen((Position position) {
                      setState(() {
                        lat = position.latitude;
                        long = position.latitude;
                        mymark = Marker(
                          markerId: MarkerId("Current loc"),
                          position: LatLng(lat, long),
                          infoWindow: InfoWindow(
                            title: city,
                            snippet: "My current location",
                          ),
                          icon: BitmapDescriptor.defaultMarker,
                        );
                        markers.add(mymark);
                      });
                      GeocodingPlatform.instance
                          .placemarkFromCoordinates(lat, long)
                          .then((val) {
                        setState(() {
                          city = val.first.name! +
                              " , " +
                              val.first.street! +
                              " , " +
                              val.first.locality!;
                        });
                      });

                      print(position == null
                          ? 'Unknown'
                          : position.latitude.toString() +
                              ', ' +
                              position.longitude.toString());
                    });
                  },
                  icon: Icon(Icons.location_on_sharp),
                  label: Text("Live ")),
              IconButton(
                  onPressed: () {
                    mapcontroller.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(target: _center, zoom: 16),
                    ));
                  },
                  icon: Icon(Icons.center_focus_strong)),
              IconButton(
                  onPressed: () {
                    idx = -1;
                    showModalBottomSheet(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        context: context,
                        builder: (builder) {
                          return Busloc();
                        });
                  },
                  icon: Icon(Icons.track_changes)),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Map View",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserInfoClass()),
              );
            },
            icon: Icon(Icons.arrow_back_ios, color: Colors.black)),
        backgroundColor: Colors.transparent,
      ),
      body: loading
          ? Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  Text("Loading map view...")
                ],
              ),
            )
          : Stack(children: [
              GoogleMap(
                mapType: MapType.normal,
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 16.0,
                ),
                markers: Set<Marker>.from(markers),
              ),

              //secoond container
              Card(
                child: Container(
                  alignment: Alignment.topCenter,
                  height: 200,
                  child: Column(
                    children: [
                      ListView(
                        shrinkWrap: true,
                        children: [
                          Center(child: Text("Nearby stations")),
                          TextField(
                            controller: tripid,
                            decoration:
                                InputDecoration(hintText: "Station name"),
                          ),
                          IconButton(
                              onPressed: () async {
                                await GeocodingPlatform.instance
                                    .locationFromAddress(
                                        tripid.text + "," + incity)
                                    .then((value) {
                                  if (value.isNotEmpty) {
                                    GeocodingPlatform.instance
                                        .placemarkFromCoordinates(
                                            value.first.latitude,
                                            value.first.longitude)
                                        .then((value1) {
                                      setState(() {
                                        locality = value1.first.subLocality!;
                                      });
                                    });
                                    setState(() {
                                      lat1 = value.first.latitude;
                                      long1 = value.first.longitude;

                                      print(lat1.toString() +
                                          " " +
                                          long1.toString());
                                      distance = (Geolocator.distanceBetween(
                                                  lat1, long1, lat, long) /
                                              1000)
                                          .round();
                                    });
                                  } else
                                    showDialog(
                                        context: context,
                                        builder: (builder) {
                                          return AlertDialog(
                                              content:
                                                  Text("Couldnt find station"));
                                        });
                                });
                              },
                              icon: Icon(Icons.search))
                        ],
                      ),
                      ListTile(
                        tileColor: Colors.lightGreen[50],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        title: Text(city,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                        subtitle: Column(
                          children: [
                            Text(locality +
                                " " +
                                distance.toString() +
                                " km Away"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
    );
  }

  Widget Busloc() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('busloc').snapshots(),
        builder: (BuildContext, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData &&
              (snapshot.connectionState == ConnectionState.waiting)) {
            return Center(
                child: Card(
                    elevation: 8,
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 5,
                        )
                      ],
                    )));
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              distancebtwn.add(Geolocator.distanceBetween(
                      lat,
                      long,
                      double.parse(doc["location"]["lat"].toString()),
                      double.parse(doc["location"]["long"].toString()))
                  .round());
              idx += 1;
              return Card(
                  child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text("Trip id :" + doc["busid"]),
                ),
                subtitle: Text("Distance away " + (distancebtwn[idx]/1000).toString() +"  Km"),
              ));
            }).toList(),
          );
        });
  }
}
