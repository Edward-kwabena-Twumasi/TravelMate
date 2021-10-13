import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/components/applicationwidgets.dart';
import 'package:myapp/providersPool/agentStateProvider.dart';
import 'package:myapp/screens/agentlogin.dart';
import 'package:myapp/screens/buslocation.dart';
import 'package:myapp/screens/homepage.dart';
import 'package:geocoding/geocoding.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
//import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
      create: (context) => CompanyState(),
      builder: (context, _) => DashApp(companytype: "Bus")));
}

TripClass onetrip = TripClass(
    "Obuasi", "Obuasi", DateTime.now(), DateTime.now(), "normal", " ");
String companyname = "";
List<String> drivers = ["Driver id"];
List<String> vehivles = ["Vehicle id"];
List destinations = [];

class DashApp extends StatefulWidget {
  final String companytype;
  const DashApp({required this.companytype});
  DashAppState createState() => DashAppState();
}

class DashAppState extends State<DashApp> {
  List<TextEditingController> controls = [];
  String feedback = "";
  List route = [];
  String initialval = vehivles[0];
  String initialval1 = drivers[0];
  bool stop = false, pickup = false;
  void changed(String? value) {
    setState(() {
      initialval = value!;
    });
  }

  List restnames = ["Linda Dor", "KFC", "Hutt Resort"];
  List reststop = [];

  void changed1(String? value) {
    setState(() {
      initialval1 = value!;
    });
  }

  Widget interroutes(bool val1, bool val2) {
    //bool value = false;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 18,
        child: Column(
          children: [
            TextField(
              controller: routecontroller,
              decoration: InputDecoration(hintText: "Enter route name"),
            ),
            SizedBox(),
            StatefulBuilder(builder: (BuildContext context, setstate) {
              return Column(
                children: [
                  SwitchListTile(
                      title: Text(
                        "Indicate as pick up point",
                        style: TextStyle(color: Colors.black),
                      ),
                      activeColor: Colors.lightBlue,
                      selectedTileColor: Colors.lightBlue,
                      value: val1,
                      //selected: val1,
                      onChanged: (bool val) {
                        setState(() {
                          val1 = val;
                        });
                      }),
                  SwitchListTile(
                      title: Text(
                        "Indicate as stop point",
                        style: TextStyle(color: Colors.black),
                      ),
                      activeColor: Colors.lightBlue,
                      selectedTileColor: Colors.lightBlue,
                      value: val2,
                      //selected: val1,
                      onChanged: (bool val) {
                        setState(() {
                          val2 = val;
                        });
                      }),
                ],
              );
            }),
            ButtonBar(
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        route.add({
                          "routename": routecontroller.text,
                          "stop": stop,
                          "pickup": pickup
                        });
                      });
                    },
                    child: Text("ADD ROUTE")),
                TextButton(
                    onPressed: () {
                      setState(() {
                        routecontroller.text = "";
                        stop = false;
                        pickup = false;
                      });
                    },
                    child: Text("ADD ANOTHER ROUTE")),
              ],
            )
          ],
        ),
      ),
    );
  }

  List<String> places = [];

  final namecontroller = TextEditingController(),
      idcontroller = TextEditingController(),
      regioncontroller = TextEditingController(),
      citycontroller = TextEditingController(),
      destcontroller = TextEditingController(),
      seatcontroller = TextEditingController(),
      about = TextEditingController(),
      from = TextEditingController(),
      to = TextEditingController(),
      restname = TextEditingController(),
      distcontroller = TextEditingController(),
      timecontroller = TextEditingController(),
      datecontroller = TextEditingController(),
      phonecontroller = TextEditingController(),
      drivername = TextEditingController(),
      driverphone = TextEditingController(),
      busname = TextEditingController(),
      fare = TextEditingController(),
      latitude = TextEditingController(),
      longitude = TextEditingController(),
      busnumber = TextEditingController(),
      routecontroller = TextEditingController();
  TextEditingController searchfrom = TextEditingController();
  TextEditingController searchto = TextEditingController();

  final form1 = GlobalKey<FormState>();
  final form2 = GlobalKey<FormState>();
  var selectregions = [];
  var interoutes = [];
  String showregions = '';
  int? routenum = 1;
  PageController? pgcontrol;
  @override
  void initState() {
    latitude.text = "0.0";
    longitude.text = "0.0";
    datecontroller.text = DateTime.now().toString().split(" ")[0];
    driverphone.addListener(() {
      setState(() {});
    });

    busnumber.addListener(() {
      setState(() {});
    });
    timecontroller.addListener(() {
      if (timecontroller.text.isEmpty ||
          timecontroller.text.split(":")[1].isEmpty ||
          timecontroller.text.split(":")[1].length < 2) {
        print("invalid time format");
      }
    });
    datecontroller.addListener(() {
      if (datecontroller.text.isEmpty ||
          datecontroller.text.split("-")[2].isEmpty ||
          datecontroller.text.split("-")[2].length < 2) {
        print("invalid date format");
      }
    });
    List<String> getplaces = [
      "Kumasi",
      "Obuasi",
      "Accra",
      "Kasoa",
      "Mankessim",
      "Wa"
    ];
    places = getplaces;
    super.initState();
  }

  String? foldername = companytype, imagename, imageurl;

  void pressed() {
    selectregions.add("REGION");
    return null;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState!.openDrawer();
  }

  void _closeDrawer() {
    Navigator.of(context).pop();
  }

  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          "/schedules": (context) => ShedulesInfo(),
        },
        home: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: Colors.white,
              leading: IconButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut().then((value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyCompApp()),
                      );
                    });
                  },
                  icon: Icon(
                    Icons.logout,
                    color: Colors.red,
                  )),
              centerTitle: true,
              title: Text(
                "DashBoard",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              elevation: 0,
              actions: [
                FloatingActionButton(
                    onPressed: _openDrawer, child: Icon(Icons.menu))
              ],
            ),
            drawer: DecoratedBox(
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.only(topRight: Radius.circular(30)),
                  color: Color.fromRGBO(50, 50, 100, 1)),
              child: Drawer(
                elevation: 30,
                semanticLabel: "drawer",
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.only(topRight: Radius.circular(30)),
                      color: Color.fromRGBO(50, 50, 100, 1)),
                  child: Center(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        IconButton(
                            onPressed: _closeDrawer,
                            icon: Icon(Icons.arrow_back_ios)),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextButton(
                            child: Text("Register " + companytype,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            onPressed: () {
                              setState(() {
                                foldername = companytype;
                              });
                              showModalBottomSheet(
                                  backgroundColor: Colors.lightBlue[50],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(50),
                                          topRight: Radius.circular(50))),
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return FractionallySizedBox(
                                      heightFactor: 0.95,
                                      child: SingleChildScrollView(
                                          child: Form(
                                        child: Column(children: [
                                          Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                  "Provide  details of " +
                                                      companytype)),
                                          InputFields(
                                              "name",
                                              busname,
                                              Icons.person_add,
                                              TextInputType.name),
                                          InputFields(
                                              "number/id",
                                              busnumber,
                                              Icons.phone,
                                              TextInputType.number),
                                          InputFields(
                                              "number of seats",
                                              seatcontroller,
                                              Icons.chair,
                                              TextInputType.number),
                                          InputFields(
                                              "Describe vehicle",
                                              about,
                                              Icons.phone,
                                              TextInputType.multiline),
                                          UploadPic(
                                            foldername: foldername!,
                                            imagename: busnumber.text,
                                          ),
                                          FloatingActionButton.extended(
                                              label: Text("Add " + companytype),
                                              onPressed: () {
                                                imageurl = imgUrl;

                                                FirebaseFirestore.instance
                                                    .collection('companies')
                                                    .doc(widget.companytype)
                                                    .collection(
                                                        'Registered Companies')
                                                    .doc(FirebaseAuth.instance
                                                        .currentUser!.uid)
                                                    .update({
                                                  "vehicles":
                                                      FieldValue.arrayUnion([
                                                    {
                                                      "name": busname.text,
                                                      "number": busnumber.text,
                                                      "seats": int.parse(
                                                          seatcontroller.text),
                                                      "image": imageurl,
                                                      "about": about.text
                                                    }
                                                  ])
                                                }).then((value) {
                                                  showDialog(
                                                      context: context,
                                                      builder: (builder) {
                                                        return AlertDialog(
                                                            content: Text(
                                                                "Vehicle registereed succesfully"));
                                                      });
                                                });
                                              },
                                              icon: Icon(Icons.add)),
                                        ]),
                                      )),
                                    );
                                  });
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextButton(
                            child: Text(
                              "Register driver",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            onPressed: () {
                              setState(() {
                                companytype == "Flight"
                                    ? foldername = "Pilot"
                                    : foldername = "Driver";
                              });
                              showModalBottomSheet(
                                  backgroundColor: Colors.lightBlue[50],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(50),
                                          topRight: Radius.circular(50))),
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return FractionallySizedBox(
                                        heightFactor: 0.95,
                                        child: SingleChildScrollView(
                                          child: Form(
                                              child: Column(children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text("Provide  details"),
                                            ),
                                            InputFields(
                                                "name",
                                                drivername,
                                                Icons.person_add,
                                                TextInputType.name),
                                            InputFields(
                                                "phone",
                                                driverphone,
                                                Icons.phone,
                                                TextInputType.number),
                                            InputFields(
                                                "About description",
                                                about,
                                                Icons.phone,
                                                TextInputType.multiline),
                                            UploadPic(
                                              foldername: foldername!,
                                              imagename: driverphone.text,
                                            ),
                                            FloatingActionButton.extended(
                                                label: Text("Add to system"),
                                                onPressed: () {
                                                  imageurl = imgUrl;
                                                  FirebaseFirestore.instance
                                                      .collection('companies')
                                                      .doc(widget.companytype)
                                                      .collection(
                                                          'Registered Companies')
                                                      .doc(FirebaseAuth.instance
                                                          .currentUser!.uid)
                                                      .update({
                                                    "drivers":
                                                        FieldValue.arrayUnion([
                                                      {
                                                        "name": drivername.text,
                                                        "phone":
                                                            driverphone.text,
                                                        "image": imageurl,
                                                        "about": about.text
                                                      }
                                                    ])
                                                  }).then((value) {
                                                    showDialog(
                                                        context: context,
                                                        builder: (builder) {
                                                          return AlertDialog(
                                                              content: Text(
                                                                  "Driver added to system"));
                                                        });
                                                  });
                                                },
                                                icon: Icon(Icons.add)),
                                          ])),
                                        ));
                                  });
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                    backgroundColor: Colors.lightBlue[50],
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10))),
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return FractionallySizedBox(
                                        heightFactor: 0.5,
                                        child: SingleChildScrollView(
                                            child: Column(
                                          children: [
                                            MenuButton(
                                                regioncontroller:
                                                    regioncontroller),
                                            Text(showregions),
                                            FloatingActionButton.extended(
                                                onPressed: () {
                                                  selectregions.add(
                                                      regioncontroller.text);
                                                  showregions = '';
                                                  for (var i in selectregions) {
                                                    showregions +=
                                                        i.toString() + " ,";
                                                  }
                                                  setState(() {
                                                    //showregions;
                                                  });

                                                  print(showregions);
                                                },
                                                label: Icon(Icons.add)),
                                            TextButton(
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection('companies')
                                                      .doc(widget.companytype)
                                                      .collection(
                                                          'Registered Companies')
                                                      .doc(FirebaseAuth.instance
                                                          .currentUser!.uid)
                                                      .update({
                                                    "regions":
                                                        FieldValue.arrayUnion(
                                                            selectregions)
                                                  }).then((value) {
                                                    showDialog(
                                                        context: context,
                                                        builder: (builder) {
                                                          return AlertDialog(
                                                              content: Text(
                                                                  "Station added to system"));
                                                        });
                                                  });
                                                },
                                                child: Text("Submit"))
                                          ],
                                        )),
                                      );
                                    });
                              },
                              child: Text("Regional Location",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20))),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                    backgroundColor: Colors.lightBlue[50],
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(50),
                                            topRight: Radius.circular(50))),
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return FractionallySizedBox(
                                        heightFactor: 0.95,
                                        child: Form(
                                          key: form1,
                                          child: SingleChildScrollView(
                                            child: Column(children: [
                                              Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Text("Station Details",
                                                      style: TextStyle(
                                                          fontSize: 30,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              InputFields(
                                                  "name",
                                                  namecontroller,
                                                  Icons.input,
                                                  TextInputType.text),
                                              Text("Station Location"),
                                              Text("Region"),
                                              InputFields(
                                                  "Region",
                                                  regioncontroller,
                                                  Icons.input,
                                                  TextInputType.text),
                                              InputFields(
                                                  "id",
                                                  idcontroller,
                                                  Icons.input,
                                                  TextInputType.text),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: InputFields(
                                                        "City",
                                                        citycontroller,
                                                        Icons.input,
                                                        TextInputType.text),
                                                  ),
                                                  Expanded(
                                                    child: TextButton(
                                                        onPressed: () async {
                                                          await GeocodingPlatform
                                                              .instance
                                                              .locationFromAddress(
                                                                  namecontroller
                                                                          .text +
                                                                      "," +
                                                                      citycontroller
                                                                          .text)
                                                              .then((value) {
                                                            setState(() {
                                                              latitude.text =
                                                                  value.first
                                                                      .latitude
                                                                      .toString();
                                                              longitude.text =
                                                                  value.first
                                                                      .longitude
                                                                      .toString();
                                                            });

                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (builder) {
                                                                  return AlertDialog(
                                                                      content: Text(
                                                                          "Cordinated fetched succesfully"));
                                                                });
                                                          }).catchError((e) {
                                                            print(e);
                                                          });
                                                        },
                                                        child: Text(
                                                            "GET COORDINATES",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green))),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: InputFields(
                                                        "Latitude",
                                                        latitude,
                                                        Icons.input,
                                                        TextInputType.text),
                                                  ),
                                                  Expanded(
                                                    child: InputFields(
                                                        "Longitude",
                                                        longitude,
                                                        Icons.input,
                                                        TextInputType.text),
                                                  ),
                                                ],
                                              ),
                                              FloatingActionButton.extended(
                                                  onPressed: () {
                                                    if (form1.currentState!
                                                        .validate()) {
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'companies')
                                                          .doc(widget
                                                              .companytype)
                                                          .collection(
                                                              'Registered Companies')
                                                          .doc(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid)
                                                          .update({
                                                        "stations": FieldValue
                                                            .arrayUnion([
                                                          {
                                                            "name":
                                                                namecontroller
                                                                    .text,
                                                            "region":
                                                                regioncontroller
                                                                    .text
                                                                    .toUpperCase(),
                                                            "city":
                                                                citycontroller
                                                                    .text,
                                                            "cordinates": [
                                                              double.parse(
                                                                  latitude
                                                                      .text),
                                                              double.parse(
                                                                  longitude
                                                                      .text)
                                                            ],
                                                            "id": idcontroller
                                                                .text,
                                                            "destinations":
                                                                destcontroller
                                                                    .text
                                                                    .toLowerCase()
                                                                    .split(","),
                                                          }
                                                        ]),
                                                        "destinations":
                                                            FieldValue
                                                                .arrayUnion([
                                                          citycontroller.text
                                                        ])
                                                      }).then((value) {
                                                        showDialog(
                                                            context: context,
                                                            builder: (builder) {
                                                              return AlertDialog(
                                                                  content: Text(
                                                                      "Station added succesfully"));
                                                            });
                                                      });
                                                      //add this in appstrings
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              "appstrings")
                                                          .doc("cordinates")
                                                          .collection(
                                                              "stations")
                                                          .add({
                                                        "city":
                                                            citycontroller.text,
                                                        "cordinates": [
                                                          double.parse(
                                                              latitude.text),
                                                          double.parse(
                                                              longitude.text)
                                                        ]
                                                      });

                                                      print({
                                                        namecontroller.text,
                                                        regioncontroller.text,
                                                        idcontroller.text
                                                      });
                                                    }
                                                  },
                                                  label: Text(
                                                    "Add station",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20),
                                                  ))
                                            ]),
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child: Text(
                                "Add Station",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              )),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                    backgroundColor: Colors.lightBlue[50],
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(50),
                                            topRight: Radius.circular(50))),
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return FractionallySizedBox(
                                        heightFactor: 0.95,
                                        child: Form(
                                          key: form2,
                                          child: SingleChildScrollView(
                                            child: Column(children: [
                                              Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Text("Trip Details",
                                                      style: TextStyle(
                                                          fontSize: 30,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              SearchLocs(
                                                direction: 'from',
                                                locations: places,
                                                searchcontrol: searchfrom,
                                              ),
                                              SearchLocs(
                                                direction: 'to',
                                                locations: places,
                                                searchcontrol: searchto,
                                              ),
                                              SizedBox(),
                                              interroutes(stop, pickup),
                                              SizedBox(height: 5),
                                              StatefulBuilder(builder:
                                                  (BuildContext context,
                                                      setstate) {
                                                return OptionButton(
                                                    options: vehivles,
                                                    onchange: changed,
                                                    dropdownValue: initialval);
                                              }),
                                              InputFields(
                                                  "Seats",
                                                  seatcontroller,
                                                  Icons.input,
                                                  TextInputType.number),
                                              InputFields(
                                                  "fare",
                                                  fare,
                                                  Icons.input,
                                                  TextInputType.number),
                                              InputFields(
                                                  "distance/km",
                                                  distcontroller,
                                                  Icons.input,
                                                  TextInputType.number),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: InputFields(
                                                        "Date : YYYY/MM/DD",
                                                        datecontroller,
                                                        Icons.input,
                                                        TextInputType.datetime),
                                                  ),
                                                  Expanded(
                                                    child: InputFields(
                                                        "Time : 00:00",
                                                        timecontroller,
                                                        Icons.input,
                                                        TextInputType.datetime),
                                                  )
                                                ],
                                              ),
                                              StatefulBuilder(builder:
                                                  (BuildContext context,
                                                      setstate) {
                                                return OptionButton(
                                                    options: drivers,
                                                    onchange: changed1,
                                                    dropdownValue: initialval1);
                                              }),
                                              InputFields(
                                                  "Please describe Trip to traveller",
                                                  about,
                                                  Icons.input,
                                                  TextInputType.text),
                                              FloatingActionButton.extended(
                                                  onPressed: () {
                                                    FirebaseFirestore.instance
                                                        .collection("trips")
                                                        .add({
                                                      "from": searchfrom.text,
                                                      "to": searchto.text,
                                                      "interoutes": route,
                                                      "distance": int.parse(
                                                          distcontroller.text),
                                                      "date": DateTime.parse(
                                                          datecontroller.text +
                                                              " " +
                                                              timecontroller
                                                                  .text),
                                                      "seats": int.parse(
                                                          seatcontroller.text),
                                                      "company": companyname,
                                                      "vehid": initialval,
                                                      "full": false,
                                                      "chosen": [],
                                                      "stars": 0,
                                                      "booked": [],
                                                      "reststops": reststop,
                                                      "fare":
                                                          int.parse(fare.text),
                                                      "driverid": initialval1,
                                                      "triptype": companytype,
                                                      "abouttrip": about.text,
                                                      "status": "pending"
                                                    }).then((value) {
                                                      showDialog(
                                                          context: context,
                                                          builder: (builder) {
                                                            return AlertDialog(
                                                              content: Text(
                                                                  "Trip added successfully"),
                                                            );
                                                          });
                                                      setState(() {
                                                        feedback =
                                                            "Trip added successfullly";
                                                      });
                                                      print(
                                                          "Trip added successfullly");
                                                    });
                                                  },
                                                  label: Text("Add Trip")),
                                              Text(feedback,
                                                  style: TextStyle(
                                                      color: Colors.green))
                                            ]),
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child: Text("Schedule Trip",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20))),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: TextButton(
                            child: Text("Rest stops",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            onPressed: () {
                              setState(() {
                                foldername = "Reststop";
                              });
                              showModalBottomSheet(
                                  backgroundColor: Colors.lightBlue[50],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(50),
                                          topRight: Radius.circular(50))),
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return FractionallySizedBox(
                                      heightFactor: 0.95,
                                      child: SingleChildScrollView(
                                          child: Form(
                                        child: Column(children: [
                                          Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text("Name")),
                                          InputFields(
                                              "name",
                                              restname,
                                              Icons.restaurant,
                                              TextInputType.name),
                                          InputFields(
                                              "Distance ahead",
                                              distcontroller,
                                              Icons.phone,
                                              TextInputType.number),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: InputFields(
                                                    "from routes",
                                                    from,
                                                    Icons.input,
                                                    TextInputType.text),
                                              ),
                                              Expanded(
                                                child: InputFields(
                                                    "to routes",
                                                    to,
                                                    Icons.input,
                                                    TextInputType.text),
                                              ),
                                            ],
                                          ),
                                          InputFields(
                                              "Describe rest stop",
                                              about,
                                              Icons.phone,
                                              TextInputType.multiline),
                                          UploadPic(
                                            foldername: foldername!,
                                            imagename: busnumber.text,
                                          ),
                                          FloatingActionButton.extended(
                                              label: Text("Add place"),
                                              onPressed: () {
                                                imageurl = imgUrl;

                                                FirebaseFirestore.instance
                                                    .collection('appstrings')
                                                    .doc("reststops")
                                                    .collection('reststops')
                                                    .add({
                                                  "name": busname.text,
                                                  "distance": int.parse(
                                                      distcontroller.text),
                                                  "fromroutes":
                                                      from.text.split(","),
                                                  "to": to.text.split(","),
                                                  "image": imageurl,
                                                  "about": about.text
                                                }).then((value) => {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (builder) {
                                                                return AlertDialog(
                                                                    content: Text(
                                                                        "Rest stop added"));
                                                              })
                                                        });
                                              },
                                              icon: Icon(Icons.add)),
                                        ]),
                                      )),
                                    );
                                  });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: PageView(
                controller: pgcontrol,
                physics: ScrollPhysics(),
                children: [
                  Dashboard(companytype: widget.companytype),
                  ShedulesInfo(),
                  Statistics()
                ])));
  }
}

class Statistics extends StatefulWidget {
  const Statistics({
    Key? key,
  }) : super(key: key);

  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  int users = 0;
  int insession = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 900,
        child: SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: Text(" Business Statistics",
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.black)),
          ),
          SizedBox(),
          Card(
              child: Column(children: [
            Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("User visits",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue)),
            )),
            SizedBox(),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("bookings").where("company",isEqualTo: companyname)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshots) {
                  if (!snapshots.hasData) {
                    return CircularProgressIndicator();
                  } else if (snapshots.hasError) {
                    return Text("fix errors");
                  }
                  return Column(
                    children:[ ListView(
                        shrinkWrap: true,
                        children: snapshots.data!.docs.map((doc) {
                          users += 1;
                          return ListTile(
                            title: Text("User id :" + doc["transactor"]),
                          );
                        }).toList()),
                        Text("Total : "+snapshots.data!.size.toString())
                        ]
                  );
                })
          ])),
          SizedBox(),
          SizedBox(),
          Card(
              child: Column(children: [
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Trips pending",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)))),
            SizedBox(),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("trips")
                    .where("status", isEqualTo: "pending")
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshots) {
                  if (!snapshots.hasData) {
                    return CircularProgressIndicator();
                  } else if (snapshots.hasError) {
                    return Text("fix errors");
                  }
                  return Column(
                    children: [
                      ListView(
                          shrinkWrap: true,
                          children: snapshots.data!.docs.map((doc) {
                            
                            return Card(
                              child: ListTile(
                               
                                subtitle: Text("ID :" + doc.id),
                              ),
                            );
                          }).toList()),
                           Text("Total : "+snapshots.data!.size.toString())
                          
                    ],
                  );
                })
          ])),
          SizedBox(),
          Card(
              child: Column(children: [
            Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Trips in session"),
            )),
            SizedBox(),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("trips")
                    .where("status", isEqualTo: "insession")
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshots) {
                  if (!snapshots.hasData) {
                    return CircularProgressIndicator();
                  } else if (snapshots.hasError) {
                    return Text("fix errors");
                  }
                  return Column(
                    children: [
                      ListView(
                          shrinkWrap: true,
                          children: snapshots.data!.docs.map((doc) {
                           
                            return ListTile(
                              title: Text("",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue)),
                              subtitle: Text("ID :" + doc.id),
                            );
                          }).toList()),
                           Text("Total : "+snapshots.data!.size.toString())
                    ],
                  );
                })
          ])),
          SizedBox(),
          Card(
              child: Column(children: [
            Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Completed trips",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue)),
            )),
            SizedBox(),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("trips")
                    .where("status", isEqualTo: "Ended")
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshots) {
                  if (!snapshots.hasData) {
                    return CircularProgressIndicator();
                  } else if (snapshots.hasError) {
                    return Text("fix errors");
                  }
                  return Column(
                    children: [
                      ListView(
                          shrinkWrap: true,
                          children: snapshots.data!.docs.map((doc) {
                           
                            return ListTile(
                             
                              subtitle: Text("ID :" + doc.id),
                            );
                          }).toList()),
                           Text("Total : "+snapshots.data!.size.toString())
                    ],
                  );
                })
          ])),

          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Card(
              child:Row(
                children: [
                  Expanded(child: ListTile(
                    title:Text("Ratings"),
                    subtitle: Text("10")
                  )),
                   Expanded(child: ListTile(
                    title:Text("Reviews"),
                    subtitle: Text("5")
                  ))
                ],
              )
            ),
          )
        ],
      ),
    ));
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key, required this.companytype}) : super(key: key);
  final String companytype;
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
              padding: EdgeInsets.all(5),
              child: Card(
                color: Colors.lightBlue[50]!.withOpacity(0.5),
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: SingleChildScrollView(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('companies')
                            .doc(widget.companytype)
                            .collection('Registered Companies')
                            .where('id',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData &&
                              !(snapshot.connectionState ==
                                  ConnectionState.done)) {
                            return Center(
                                child: Card(
                                    elevation: 8,
                                    child: Column(
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text("Loading data...")
                                      ],
                                    )));
                          } else if (snapshot.hasError) {
                            print(snapshot.error);
                          } else if (snapshot.hasData) {
                            if (snapshot.data!.size > 0) {
                              companyname =
                                  snapshot.data!.docs[0].get('registered_name');
                            }

                            print(companyname);
                          }

                          return SingleChildScrollView(
                            child: Column(
                                children: snapshot.data!.docs.map((doc) {
                              // destinations = doc["destinations"];
                              // print(destinations);
                              return Center(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Text(doc['registered_name'],
                                          style: TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold)),
                                      ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: doc['regions'].length,
                                          itemBuilder: (context, index) {
                                            return ExpansionTile(
                                                title:
                                                    Text(doc['regions'][index]),
                                                children: doc['stations']
                                                            .length <
                                                        1
                                                    ? [Text("Add stations")]
                                                    : List.unmodifiable(
                                                        () sync* {
                                                        for (var i = 0;
                                                            i <
                                                                doc['stations']
                                                                    .length;
                                                            i++) {
                                                          if (doc['stations'][i]
                                                                  ['region'] ==
                                                              doc['regions']
                                                                  [index]) {
                                                            yield ListTile(
                                                              title: Text(
                                                                  doc['stations']
                                                                          [i]
                                                                      ['name']),
                                                            );
                                                          }
                                                        }
                                                      }()));
                                          }),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Card(
                                          color:
                                              Colors.pink[50]!.withOpacity(0.5),
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount:
                                                  doc['drivers'].length > 0
                                                      ? doc['drivers'].length
                                                      : 0,
                                              itemBuilder:
                                                  (BuildContext context, idx) {
                                                if (!drivers.contains(
                                                    doc['drivers'][idx]
                                                        ["phone"])) {
                                                  drivers.add(doc['drivers']
                                                      [idx]["phone"]);
                                                }

                                                return ListTile(
                                                    title: Text(doc['drivers']
                                                        [idx]["name"]),
                                                    subtitle: Text(
                                                      doc['drivers'][idx]
                                                          ["phone"],
                                                    ));
                                              }),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Card(
                                          color: Colors.grey.withOpacity(0.4),
                                          elevation: 5,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount:
                                                  doc['vehicles'].length > 0
                                                      ? doc['vehicles'].length
                                                      : 0,
                                              itemBuilder:
                                                  (BuildContext context, idx) {
                                                if (!vehivles.contains(
                                                    doc['vehicles'][idx]
                                                        ["number"])) {
                                                  vehivles.add(doc['vehicles']
                                                      [idx]["number"]);
                                                }

                                                return ListTile(
                                                    title: Text(doc['vehicles']
                                                        [idx]["name"]),
                                                    subtitle: Text(
                                                      doc['vehicles'][idx]
                                                          ["number"],
                                                    ));
                                              }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList()),
                          );
                        })),
              )),
        ],
      ),
    );
  }
}

class ShedulesInfo extends StatefulWidget {
  @override
  _ShedulesInfoState createState() => _ShedulesInfoState();
}

class _ShedulesInfoState extends State<ShedulesInfo> {
  final seatscontroller = TextEditingController(),
      timecontroller = TextEditingController();
  int yr = DateTime.now().year;
  int mnt = DateTime.now().month;
  int day = DateTime.now().day;
  int hour = TimeOfDay.now().hour;
  int min = TimeOfDay.now().minute;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
                      heroTag: "offers",
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      onPressed: () {
                        showModalBottomSheet(
                            backgroundColor: Colors.amber[100],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(50),
                                    topRight: Radius.circular(50))),
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return FractionallySizedBox(
                                  heightFactor: 0.9, child: Offers());
                            });
                      },
                      label: Text(" Reports",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black))),
            
        body: ListView(
          shrinkWrap: true,
          children: [
            
            ListTile(
              title: Text("Sheduled Trips",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('trips')
                  .where("company", isEqualTo: companyname)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                return SingleChildScrollView(
                  child: Column(
                    children: snapshot.data!.docs.map((data) {
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Container(
                          height: 150,
                          child: new ListTile(
                            subtitle: ListView(
                              shrinkWrap: true,
                              children: [
                                new Text(
                                    "Status : " + data['status'].toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green)),
                                new Text(data['from'] + " > " + data['to'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )),
                                new Text(
                                    "Vehicle id : " + data['vehid'].toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )),
                                new Text(
                                    "Booked : " +
                                        data['chosen'].length.toString(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                new Text(
                                    "Remaining : " + data['seats'].toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )),
                                new Text(
                                    "Take off : " +
                                        data['date']
                                            .toDate()
                                            .toString()
                                            .split(" ")[1],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green)),
                                Container(
                                  height: 40,
                                  child: ListView(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: IconButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (builder) {
                                                    return AlertDialog(
                                                        content: Column(
                                                      children: [
                                                        Text(
                                                            "Fill reschedule info",style:TextStyle(fontWeight:FontWeight.bold ) ,),
                                                        InputFields(
                                                            "number of seats",
                                                            seatscontroller,
                                                            Icons.chair,
                                                            TextInputType
                                                                .number),
                                                       
                                                        FloatingActionButton
                                                            .extended(
                                                                label: Text(
                                                                    "Choose time"),
                                                                onPressed:
                                                                    () async {
                                                                  showTimePicker(
                                                                          context:
                                                                              context,
                                                                          initialTime: TimeOfDay
                                                                              .now())
                                                                      .then(
                                                                          (value) {
                                                                    setState(
                                                                        () {
                                                                      hour = value!
                                                                          .hour;
                                                                      min = value
                                                                          .minute;
                                                                    });
                                                                  });
                                                                }),
                                                        TextButton(
                                                            onPressed: () {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "trips")
                                                                  .doc(data.id)
                                                                  .update({
                                                                "status":
                                                                    "pending",
                                                                "date":
                                                                    DateTime(
                                                                        yr,
                                                                        mnt,
                                                                        day,
                                                                        hour,
                                                                        min),
                                                                        "seats":int.parse(seatscontroller.text),
                                                                        "chosen":[],
                                                                         "boooked":[]
                                                                        
                                                              });
                                                            },
                                                            child: Text("OK"))
                                                      ],
                                                    ));
                                                  });

                                              // FirebaseFirestore.instance
                                              //     .collection("trips")
                                              //     .doc(data.id)
                                              //     .update(
                                              //         {"status": "insession"});
                                            },
                                            icon: Icon(Icons.restart_alt)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: IconButton(
                                            onPressed: () {},
                                            icon: Icon(Icons.cancel)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                            onPressed: () {
                                              if (data["status"] == "pending") {
                                                FirebaseFirestore.instance
                                                    .collection("trips")
                                                    .doc(data.id)
                                                    .update({
                                                  "status": "insession"
                                                });
                                              } else {
                                                FirebaseFirestore.instance
                                                    .collection("trips")
                                                    .doc(data.id)
                                                    .update(
                                                        {"status": "Ended"});
                                                FirebaseFirestore.instance
                                                    .collection("busloc")
                                                    .doc(data.id)
                                                    .delete();
                                              }
                                            },
                                            child: Text(data["status"]=="insession"?"End" :"Start")),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext) {
                                              return Busposition(tripid:data.id);
                                            }));
                                          },
                                          icon: Icon(Icons.location_on)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// class SimpleCardPaint extends CustomPaint {
//   @override
//   void paint(Canvas canvas, Size size) {
//     var radius = 24.0;
//     var paint = Paint();
//     paint.shader=Gradient.linear(from, to, colors)

//   }
// }

class FlightCompany extends StatefulWidget {
  const FlightCompany({Key? key}) : super(key: key);

  @override
  _FlightCompanyState createState() => _FlightCompanyState();
}

class _FlightCompanyState extends State<FlightCompany> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Driver {
  Driver(this.id);
  String id;
}

class Bus {
  Bus(this.id);
  String id;
}

class Route {
  String name;
  bool stop;
  bool pickup;
  Route(this.name, this.stop, this.pickup);
}
