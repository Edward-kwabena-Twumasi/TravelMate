import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:geolocator/geolocator.dart';

import 'package:myapp/components/applicationwidgets.dart';

import 'package:myapp/components/userfeatures.dart';
import 'package:myapp/main.dart';
import 'package:myapp/screens/chatscreen.dart';

import 'package:myapp/screens/completebook.dart';
import 'package:myapp/screens/reportscreen.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providersPool/userStateProvider.dart';

import 'package:myapp/components/getlocation.dart';

import 'package:geocoding/geocoding.dart';

import 'googlemap.dart';

enum companyFilters { VIP, STC, MMT }
enum queryFilters { isEqualTo }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
      create: (context) => UserState(), builder: (context, _) => ButtomNav()));
}

// TripClass onetrip =
//     TripClass("Obuasi", "Obuasi", "10:00", "20 10 2021", "normal");
List triptype = ["Bus", "Flight", "Train"];
List<String> places = ["Kumasi", "Obuasi", "Accra", "Kasoa", "Mankessim", "Wa"];
List<Interoutes> routes = [];
Seat seat = Seat("busnumber", 30, 20, "from", "to", "tripid", routes, "company",
    DateTime.now());
int results = 0;
Timestamp now = Timestamp.now();
DateTime time =
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
TextEditingController datecontroller = TextEditingController();

class ButtomNav extends StatefulWidget {
  @override
  ButtomNavState createState() => ButtomNavState();
}

class ButtomNavState extends State<ButtomNav> {
  static List<Widget> pages = [
    Column(
      children: [Expanded(child: TabBarDemo()), Primary()],
    ),
    Announcements(),
    UserInfoClass(),
  ];
  int currentindx = 0;

  void swithnav(int value) {
    setState(() {
      currentindx = value;
    });
  }

  Future<void> getSavetoken() async {
    String? token = await FirebaseMessaging.instance.getToken();

    // Save the initial token to the database
    await saveTokenToDatabase(token!);

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
  }

  @override
  void initState() {
    super.initState();

    getSavetoken();
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/matchingtrips": (context) => Trips(onetrip, triptype[1]),
        "/location": (context) => GeolocatorWidget(),
        "/completebook": (context) => Booking(),
        "/reports": (context) => Reporter(),
        "/map": (context) => Mymap(),
        "/chat": (context) => ChatApp()
      },
      home: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentindx,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            elevation: 8,
            onTap: swithnav,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.help), label: "Announcements"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Me"),
            ]),
        body: pages.elementAt(currentindx),
      ),
    );
  }
}

class TabBarDemo extends StatefulWidget {
  const TabBarDemo({Key? key}) : super(key: key);

  @override
  TabBarDemoState createState() => TabBarDemoState();
}

class TabBarDemoState extends State<TabBarDemo> {
  List<String> typelist = ["Local", "International"];
  List<String> returnlist = ["Retrun trip", "One Time"];
  void initState() {
    initialreturn = returnlist[0];
    initialtype = typelist[0];
    super.initState();
  }

  String? initialreturn;
  String? initialtype;

  void typeaction(String? choice) {
    setState(() {
      initialtype = choice;
    });
  }

  void returnaction(String? choice) {
    setState(() {
      initialreturn = choice;
    });
  }

  TextEditingController searchfrom = TextEditingController();
  TextEditingController searchto = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Book your trip",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            bottom: TabBar(
              indicatorColor: Colors.lightGreen,
              tabs: [
                Tab(icon: Icon(Icons.bus_alert_rounded, color: Colors.black)),
                Tab(icon: Icon(Icons.train, color: Colors.black)),
                Tab(icon: Icon(Icons.flight, color: Colors.black)),
              ],
            )),
        body: TabBarView(
          children: [
            Container(
              height: 900,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/busstation.jpg'),
                    fit: BoxFit.cover),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Locations(typeoftrip: triptype[0]),
                  ],
                ),
              ),
            ),

            //Block for Buses
            Container(
              height: 900,
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/train1.png'), fit: BoxFit.cover),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Locations(typeoftrip: triptype[2]),
                  ],
                ),
              ),
            ),

            //Block for trains

            Container(
              height: 900,
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/flight.jpg'), fit: BoxFit.cover),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      margin: EdgeInsets.only(left: 5, right: 5, bottom: 3),
                      child: Card(
                        color: Colors.transparent,
                        elevation: 7,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            Expanded(
                                child: OptionButton(
                                    options: typelist,
                                    onchange: typeaction,
                                    dropdownValue: initialtype!)),
                            Expanded(
                                child: OptionButton(
                                    options: returnlist,
                                    onchange: returnaction,
                                    dropdownValue: initialreturn!))
                          ],
                        ),
                      ),
                    ),
                    Locations(typeoftrip: triptype[1]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Locations extends StatefulWidget {
  const Locations({Key? key, required this.typeoftrip}) : super(key: key);

  final String typeoftrip;
  @override
  LocationsState createState() => LocationsState();
}

class LocationsState extends State<Locations> {
  bool stripcity = false;
  String swap = "";
  TextEditingController from = TextEditingController();
  TextEditingController to = TextEditingController();
  bool wait = false;
  void initState() {
    super.initState();
    datecontroller.text = time.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white.withOpacity(0.9),
        child: Center(
            child: Card(
          color: Colors.white.withOpacity(0.7),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SearchLocs(
                direction: 'from',
                locations: places,
                searchcontrol: from,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                    onPressed: () {
                      swap = from.text;
                      from.text = to.text;
                      to.text = swap;
                    },
                    icon: Icon(Icons.change_circle,size:30,color: Colors.green,)),
              ),
              SearchLocs(
                direction: 'to',
                locations: places,
                searchcontrol: to,
              ),
              InputFields("Travel date", datecontroller, Icons.date_range,
                  TextInputType.datetime),
              Expanded(
                  child: Center(
                      child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton.extended(
                    heroTag: "getpos",
                    onPressed: () async {
                      setState(
                        () {
                          wait = true;
                        },
                      );
                      await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.best)
                          .then((value) async {
                        await placemarkFromCoordinates(
                                value.latitude, value.longitude)
                            .then((value2) {
                          from.text = value2.first.locality! +
                              "," +
                              value2.first.subLocality!;
                          setState(
                            () {
                              wait = false;
                            },
                          );
                          return value2;
                        });
                      });

                      setState(
                        () {
                          stripcity = true;
                        },
                      );
                    },
                    label: wait
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(""),
                    icon: Icon(Icons.location_on),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  SizedBox(
                    height: 40,
                    child: MyStatefulWidget(
                      restorationId: "main",
                    ),
                  ), //proceed with boooking
                  SizedBox(
                    height: 40,
                    child: FloatingActionButton(
                      heroTag: "dosearch",
                      splashColor: Colors.white,
                      shape: StadiumBorder(),
                      onPressed: () {
                        stripcity
                            ? onetrip.fromLoc = from.text.split(",")[0].trim()
                            : onetrip.fromLoc = from.text.trim();

                        onetrip.toLoc = to.text;
                        onetrip.triptype = widget.typeoftrip;
                        setState(() {
                          // widget.typeoftrip;
                        });
                        print("clicked for : " + widget.typeoftrip);
                        print(onetrip.date);
                        print(widget.typeoftrip +
                            onetrip.fromLoc +
                            onetrip.toLoc);
                        Navigator.pushNamed(context, "/matchingtrips");
                      },
                      child: Text("Search"),
                    ),
                  )
                ],
              ))),
            ],
          ),
        )),
        height: 400,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(3));

    // ignore: todo
    // TODO: implement build
  }
}

//primary actions

/// This is the stateful widget that the main application instantiates.

//trips class to list trips serached for
class Trips extends StatefulWidget {
  final String triptype;
  final TripClass _tripdata;
  const Trips(this._tripdata, this.triptype);
  @override
  TripsState createState() => TripsState();
}

class TripsState extends State<Trips> {
  bool isfound = true;
  String filter1 = '';
  String filter2 = '';
  int year = DateTime.now().year;
  int month = DateTime.now().month;
  int day = DateTime.now().day;
  DateTime? tod;
  TimeOfDay morning = TimeOfDay(hour: 11, minute: 59);
  TimeOfDay afternoon = TimeOfDay(hour: 14, minute: 59);
  TimeOfDay evening = TimeOfDay(hour: 16, minute: 59);
  String getday(int tripday, int searchday) {
    String particular = "Today  ";
    List days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
      "Tomorrow"
    ];
    if ((tripday - searchday) == 1) {
      particular = days[7];
    } else {
      particular = days[tripday];
    }

    return particular;
  }

  Future<List<dynamic>> listcomps() async {
    var docs = await FirebaseFirestore.instance
        .collection("appstrings")
        .doc("companynamestrings")
        .get();
        return docs["companynamestrings"];
  }

  List filterquery = [""];
  List all = [""];

  void initState() {
    super.initState();
    setState(() {
      filter1 = widget._tripdata.triptype;
      tod = DateTime(year, month, day, 23, 59);
    });
    listcomps().then((value) {
if (value!=null) {
  for (var item in value) {
        setState(() {
          filterquery.add(item["name"].toString());
          all.add(item["name"].toString());
        });
        print(item["name"]);
      }
} else {
  print("Could not fetch");
}
      
    });
  }

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "All trips for this location",
      routes: {"/completebook": (context) => Booking()},
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios, color: Colors.black)),
          centerTitle: true,
          title: Row(
            children: [
              Text(
                "Search Results for  ",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.lightBlue),
              ),
              DecoratedBox(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.red,
                          width: 2,
                          style: BorderStyle.solid)),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      widget._tripdata.triptype,
                      style: TextStyle(color: Colors.red),
                    ),
                  ))
            ],
          ),
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  height: 50,
                  child: FutureBuilder(
                      future: FirebaseFirestore.instance

                          .collection("appstrings")
                          .doc("companynamestrings")
                          .get(),
                          
                      builder: (context, AsyncSnapshot<dynamic> snapshot) {
                        if (!snapshot.hasData &&
                            (snapshot.connectionState ==
                                ConnectionState.waiting)) {
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
                        } else if (snapshot.hasError) {
                          print(snapshot.error.toString());
                          return Text(snapshot.error.toString());
                        }
                        return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                snapshot.data!["companynamestrings"].length,
                            itemBuilder: (lcontext, index) {
                              // filterquery.add(snapshot.data!["companynamestrings"]
                              //     [index]["name"]) ;
                              return snapshot.data!["companynamestrings"][index]
                                          ["type"] ==
                                      filter1
                                  ? Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: niceChips(
                                          Icons.menu,
                                          snapshot.data!["companynamestrings"]
                                              [index]["name"], () {
                                        setState(() {
                                          if (snapshot.data!["companynamestrings"]
                                                  [index]["name"] ==
                                              "All") {
                                            filterquery = all;
                                          } else
                                            filterquery = [
                                              snapshot.data!["companynamestrings"]
                                                  [index]["name"]
                                            ];
                                        });
                                      }),
                                    )
                                  : Text("");
                            });
                      }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: ListTile(
                  title: Center(child: Text("compare",style:TextStyle(fontWeight:FontWeight.bold ) ,)),
                  subtitle: Container(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        niceChips(Icons.bus_alert, "Bus", () {
                          setState(() {
                            filter1 = 'Bus';
                           
                            //filterquery=[""];
                          });
                        }),
                        niceChips(Icons.flight, "Flight", () {
                          setState(() {
                            filter1 = 'Flight';
                            //filterquery=[""];
                          });
                          print(filter1);
                        }),
                        niceChips(Icons.train, "Train", () {
                          setState(() {
                            filter1 = 'Train';
                           // filterquery=[""];
                          });
                        })
                      ],
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                  child: Column(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.red,
                            width: 1,
                            style: BorderStyle.solid)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                          widget._tripdata.triptype +
                              "s " +
                              " from " +
                              widget._tripdata.fromLoc +
                              " to " +
                              widget._tripdata.toLoc,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue,
                          )),
                    ),
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('trips')
                          .where("from", isEqualTo: widget._tripdata.fromLoc)
                          .where("to", isEqualTo: widget._tripdata.toLoc)
                          .where("triptype", isEqualTo: filter1)
                          .where("company", whereIn: filterquery)                     
                          .orderBy("stars",descending:true)                         
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData &&
                            (snapshot.connectionState ==
                                ConnectionState.waiting)) {
                          return Center(
                              child: Card(
                                  elevation: 8,
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text("Loading ...")
                                    ],
                                  )));
                        } else if (snapshot.hasError) {
                          print(snapshot.error);
                          return Text(
                              "Sorry an error occured.Probably may be due to internet issues.Try again later");
                        } else if ((snapshot.connectionState ==
                                ConnectionState.done) &&
                            snapshot.data!.size < 1) {
                          return Text(
                              "Couldnt find matching results .Please try another search or contact us on 0501658160");
                        } else if (snapshot.hasData) {
                          return snapshot.data!.size < 1
                              ? Text(
                                  "No matching results found.Please try again")
                              : SizedBox(
                                  child: ListView(
                                      shrinkWrap: true,
                                      children: snapshot.data!.docs.map((doc) {
                                        return Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          elevation: 5,
                                          child: Column(
                                            children: [
                                              ListTile(
                                                tileColor: doc['seats'] > 0
                                                    ? Colors.lightBlue[50]
                                                    : Colors.pink[100],
                                                leading: Text(doc['date']
                                                            .toDate()
                                                            .toString()
                                                            .split(" ")[0] ==
                                                        DateTime.now()
                                                            .toString()
                                                            .split(" ")[0]
                                                    ? "Today"
                                                    : doc['date']
                                                            .toDate()
                                                            .month
                                                            .toString() +
                                                        "/" +
                                                        doc['date']
                                                            .toDate()
                                                            .weekday
                                                            .toString() +
                                                        getday(
                                                            doc['date']
                                                                .toDate()
                                                                .weekday,
                                                            widget._tripdata
                                                                .date.weekday)),
                                                subtitle: Column(
                                                  children: [
                                                    Row(
                                                      children: [ 
                                          
                                                        Text(doc['date']
                                                            .toDate()
                                                            .toString()
                                                            .split(" ")[1]),
                                                            Text(" GHS "+doc['fare']
                                                           
                                                            .toString()
                                                           ,style:
                                                             TextStyle(fontSize: 26,
                                                             fontWeight:FontWeight.bold,
                                                             color:Colors.lightBlue  ),),
                                                      ],
                                                    ),

                                                   Row(children: [ Padding(
                                                     padding: const EdgeInsets.all(2.0),
                                                     child: Text(
                                                              doc['company']
                                                                  .toString(),style:TextStyle(fontWeight:FontWeight.bold) ,),
                                                   ),
                                                                 Text(doc["stars"]
                                                                    .toString() +
                                                                " stars "),
                                                                ])
                                                  ],
                                                ),
                                                title: DecoratedBox(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25),
                                                        border: Border.all(
                                                            color:
                                                                Colors.green)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Text(doc['seats']
                                                              .toString() +
                                                          "  seats remaining"),
                                                    )),
                                                trailing: doc['seats'] > 0
                                                    ? FloatingActionButton(
                                                        heroTag: "book",
                                                        onPressed: () {
                                                          for (var i = 0;
                                                              i <
                                                                  doc["interoutes"]
                                                                      .length;
                                                              i++) {
                                                            routes.add(Interoutes(
                                                                doc["interoutes"]
                                                                        [i][
                                                                    'routename'],
                                                                doc['interoutes']
                                                                        [i]
                                                                    ['pickup'],
                                                                doc['interoutes']
                                                                        [i]
                                                                    ['stop']));
                                                          }
                                                          seat.vehid =
                                                              doc["vehid"];
                                                          seat.from =
                                                              doc["from"];
                                                          seat.to = doc["to"];
                                                          seat.seats =
                                                              (doc["seats"] +
                                                                  doc["chosen"]
                                                                      .length);
                                                          seat.unitprice =
                                                              doc["fare"];
                                                          seat.tripid =
                                                              doc.id.toString();
                                                          seat.company =
                                                              doc["company"];
                                                          print('clicked');
                                                          Navigator.pushNamed(
                                                              context,
                                                              "/completebook");
                                                        },
                                                        child: Text("Book"))
                                                    : TextButton(
                                                        onPressed: () {},
                                                        child: Text(
                                                            "Notify later")),
                                              ),
                                              Text(TimeOfDay.fromDateTime(
                                                              doc["date"]
                                                                  .toDate())
                                                          .hour >
                                                      12
                                                  ? "Afternoon"
                                                  : "morning")
                                            ],
                                          ),
                                        );
                                      }).toList()),
                                );
                        }

                        return Text(
                          "No data found for search",
                          style: TextStyle(color: Colors.red),
                        );
                      }),
                ],
              )),
              ButtonBar(
                children: [
                  TextButton(onPressed: () {}, child: Text(" Morning ")),
                  TextButton(onPressed: () {}, child: Text("Afternoon ")),
                  TextButton(onPressed: () {}, child: Text(" Evening "))
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}

class TripClass {
  String fromLoc;
  String toLoc;
  DateTime time;
  DateTime date;
  String tripclass;
  String triptype;
  TripClass(this.fromLoc, this.toLoc, this.time, this.date, this.tripclass,
      this.triptype);
}

class Announcements extends StatefulWidget {
  const Announcements({Key? key}) : super(key: key);

  @override
  AnnouncementsState createState() => AnnouncementsState();
}

class AnnouncementsState extends State<Announcements> {
  @override
  Widget build(BuildContext context) {
    return Anounce();
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key, this.restorationId}) : super(key: key);

  final String? restorationId;

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget>
    with RestorationMixin {
  @override
  String? get restorationId => widget.restorationId;

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime(2021));
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2022, 1, 1),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
        time = DateTime(_selectedDate.value.year, _selectedDate.value.month,
            _selectedDate.value.day);
        datecontroller.text = time.toString();
        onetrip.date = DateTime(_selectedDate.value.year,
            _selectedDate.value.month, _selectedDate.value.day);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Selected: ${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}'),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: FloatingActionButton.extended(
      heroTag: "date",
      onPressed: () {
        _restorableDatePickerRouteFuture.present();
      },
      label: const Text('Travel date'),
      icon: Icon(Icons.calendar_today),
    ));
  }
}

class UserInfoClass extends StatefulWidget {
  @override
  UserInfoClassState createState() => UserInfoClassState();
}

class UserInfoClassState extends State<UserInfoClass> {
  Color starredcolor = Colors.red;
  Color unstarredcolor = Colors.grey;
  int starindex = 0;
  int stars = 5;
  int rateval = 5;

  TextEditingController reviewmsg = TextEditingController();
  TextEditingController newname = TextEditingController();
  bool fetch = true;
  var starred = [];
  //var healthinfo = [];
  void getopts() async {
    await FirebaseFirestore.instance
        .collection("appstrings")
        .doc("companynamestrings")
        .get();
  }

  String setname = "Name";
  bool notdone = true;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ButtomNav()),
              );
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut().then((value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => App()),
                  );
                });
              },
              icon: Icon(
                Icons.logout,
                color: Colors.red,
              ))
        ],
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Features(),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
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
                                ),
                                Text("fetching info")
                              ],
                            )));
                  } else if (snapshot.hasError) {
                    print(snapshot.error);
                  }

                  return Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.all(12),
                          child: ListView(shrinkWrap: true, children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              elevation: 10,
                              child: ListTile(
                                  title: Text("Username"),
                                  subtitle: Text("Unknown"),
                                  trailing: IconButton(
                                      onPressed: () {
                                        AlertDialog(
                                          elevation: 10,
                                          title: Text("Enter new name here"),
                                          content: InputFields(
                                              "new name",
                                              newname,
                                              Icons.new_label,
                                              TextInputType.text),
                                        );
                                      },
                                      icon: Icon(Icons.edit_attributes))),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              elevation: 10,
                              child: ListTile(
                                  title: Text("Email"),
                                  subtitle:
                                      Text(snapshot.data["contact"]["email"]),
                                  trailing: IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.edit_attributes))),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              elevation: 10,
                              child: ListTile(
                                  title: Text("Phone"),
                                  subtitle:
                                      Text(snapshot.data["contact"]["phone"]),
                                  trailing: IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.edit_attributes))),
                            ),
                          ])),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }
}

class Seat {
  String vehid;
  int seats;
  int unitprice;
  String from;
  String to;
  String tripid;
  List<Interoutes> routes;
  String company;
  DateTime time;
  Seat(this.vehid, this.seats, this.unitprice, this.from, this.to, this.tripid,
      this.routes, this.company, this.time);
}

class Interoutes {
  String name;
  bool stop;
  bool pickup;

  Interoutes(this.name, this.pickup, this.stop);
}

class User {
  String name;
  Map address;
  Map contact;

  Map healthinfo;
  User(this.name, this.address, this.contact, this.healthinfo);
}

class Primary extends StatefulWidget {
  const Primary({Key? key}) : super(key: key);

  @override
  _PrimaryState createState() => _PrimaryState();
}

class _PrimaryState extends State<Primary> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.green.withOpacity(0.9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.7, 0.8],
            ),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        height: 70,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 3,
                  child: FloatingActionButton.extended(
                      heroTag: "policy",
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
                                  heightFactor: 0.9, child: Policy());
                            });
                      },
                      label: Text("Policy",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)))),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 3,
                  child: FloatingActionButton.extended(
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
                      label: Text(" offers",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)))),
            ),
          ],
        ));
  }
}
