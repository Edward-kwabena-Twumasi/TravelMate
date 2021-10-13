import 'dart:convert';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/homepage.dart';
//import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/screens/payweb.dart';

Ticketinfo ticket = Ticketinfo("from", "to", "busid", "tripid", time, [], 100,
    "booker", "pickup", "company");

void main() {
  runApp(Booking());
}

class Booking extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Book(
        seat: seat,
      ),
    );
  }
}

class Book extends StatefulWidget {
  final Seat seat;
  Book({required this.seat});
  BookState createState() => BookState();
}

class BookState extends State<Book> {
  String pickup = "";
  bool bookingsuccess = false;
  String transactor = FirebaseAuth.instance.currentUser!.uid;
  String? transactormail = FirebaseAuth.instance.currentUser!.email;
  bool showlist = false;
  bool ischosen = true;
  var accesscode;
  var seatids = [];
  int unitprice = 10;
  int chosen = 0;
  int total = 0;
  Color? seatcolor;
  Color? chosencolor;
  @override
  void initState() {
    seatcolor = Colors.grey;
    unitprice = widget.seat.unitprice;
    chosen = 0;
    total = chosen * unitprice;
    //plugin.initialize(publicKey: publicKey);
    super.initState();
  }

  get gridDelegate => null;
  Color color = Colors.grey;
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            floatingActionButton: seatids.length < 1
                ? Text("Select seats to book")
                : Center(
                    child: ButtonBar(children: [
                      FloatingActionButton.extended(
                          onPressed: () {
                            _getAccessCodeFrmInitialization(
                                    double.parse(total.toString()) * 100,
                                    "sk_test_a310b10d73f4449db22b02c96c28be222a6f4351",
                                    transactormail!)
                                .then((value) {
                              setState(() {
                                accesscode =
                                    value.data["authorization_url"].toString() +
                                        "/" +
                                        value.data["access_code"].toString();
                              });

                              ticket.from = widget.seat.from;
                              ticket.to = widget.seat.to;
                              ticket.booker = transactor;
                              ticket.time = widget.seat.time;
                              ticket.tripid = widget.seat.tripid;
                              ticket.vehid = widget.seat.vehid;
                              ticket.company = widget.seat.company;
                              ticket.total = total * 100;
                              ticket.chosen = seatids;
                              ticket.pickup = pickup;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WebViewpg(
                                            pageurl: accesscode,
                                            ref: value.data["reference"],
                                            ticketinfo: ticket,
                                          )));
                              print(accesscode +
                                  " " +
                                  value.data["authorization_url"].toString());
                            }).catchError((e) {
                              print(e.toString());
                            });
                          },
                          label: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text("Pay now"),
                          )),
                    ]),
                  ),
            appBar: AppBar(
                leading: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ButtomNav()),
                      );
                    },
                    icon: Icon(Icons.arrow_back_ios, color: Colors.black)),
                backgroundColor: Colors.white,
                centerTitle: true,
                title: ListTile(
                  title: Center(
                    child: Text(
                      "Complete booking",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  subtitle: Center(
                      child: Container(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            "Chosen",
                            style: TextStyle(backgroundColor: Colors.green),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            "Booked",
                            style: TextStyle(backgroundColor: Colors.red),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            "Empty",
                            style: TextStyle(backgroundColor: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  )),
                ),
                bottom: TabBar(tabs: [
                  Tab(
                    child: Text(
                      "Seating",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Tab(
                    child: Text("Pickup points",
                        style: TextStyle(color: Colors.black)),
                  ),
                  Tab(
                    child: Text("Trip overview ",
                        style: TextStyle(color: Colors.black)),
                  ),
                ])),
            body: TabBarView(children: [
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("trips")
                    .doc(widget.seat.tripid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshots) {
                  if (!snapshots.hasData) {
                    return Text("Loading seats");
                  } else if (snapshots.hasData) {
                    print(snapshots.data!["chosen"]);
                  }
                  return GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 120,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10),
                      itemCount: widget.seat.seats,
                      itemBuilder: (BuildContext ctx, index) {
                        String selected = index.toString() + "_";
                        Color? color;
                        switch (match(snapshots.data!["chosen"],
                            snapshots.data!["booked"], selected)) {
                          case 0:
                            color = Colors.grey;
                            break;
                          case 1:
                            color = Colors.lightGreen;
                            break;
                          case 2:
                            color = Colors.red;
                        }

                        return SizedBox(
                          height: 110,
                          width: 110,
                          child: FloatingActionButton.extended(
                            label: snapshots.data!["chosen"].contains(
                                    index.toString() + "_" + transactor)
                                ? Text((index + 1).toString() + "You")
                                : Text((index + 1).toString()),
                            icon: Icon(
                              Icons.chair,
                              color: Colors.white,
                            ),
                            heroTag: index.toString(),
                            key: Key("Seat numbers" + index.toString()),
                            backgroundColor: color,
                            onPressed: () {
                              String find = index.toString() + "_" + transactor;
                              String noselct = index.toString() + "_";
                              if (!snapshots.data!["chosen"].contains(find)) {
                                if (snapshots.data!["seats"] > 0 &&
                                    match(
                                            snapshots.data!["chosen"],
                                            snapshots.data!["booked"],
                                            noselct) <
                                        1) {
                                  setState(() {
                                    chosen += 1;
                                    total = (chosen * unitprice);
                                  });
                                  FirebaseFirestore.instance
                                      .runTransaction((transaction) async {
                                    DocumentSnapshot freshap = await transaction
                                        .get(snapshots.data!.reference);
                                    transaction.update(freshap.reference, {
                                      "seats": (freshap["seats"] - 1),
                                      "chosen": FieldValue.arrayUnion([find])
                                    });
                                  }).then((value) {
                                    setState(() {
                                      showlist = true;
                                      seatids.add(find);
                                    });
                                  });
                                }
                              } else if (snapshots.data!["chosen"]
                                  .contains(find)) {
                                if (match(snapshots.data!["chosen"],
                                        snapshots.data!["booked"], noselct) <
                                    2) {
                                  setState(() {
                                    chosen -= 1;
                                    total = (chosen * unitprice);
                                  });
                                  FirebaseFirestore.instance
                                      .runTransaction((transaction) async {
                                    DocumentSnapshot freshap = await transaction
                                        .get(snapshots.data!.reference);
                                    transaction.update(freshap.reference, {
                                      "seats": (freshap["seats"] + 1),
                                      "chosen": FieldValue.arrayRemove([find])
                                    });
                                  }).then((value) {
                                    setState(() {
                                      showlist = true;
                                      seatids.remove(find);
                                    });
                                  });
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (builder) {
                                        return AlertDialog(
                                            content:
                                                Text("Seat has been booked"));
                                      });
                                }
                              }
                              showModalBottomSheet(
                                  backgroundColor: Colors.indigo[100],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(50),
                                          topRight: Radius.circular(50))),
                                  context: context,
                                  builder: (BuildContext context) {
                                    return FractionallySizedBox(
                                      heightFactor: 0.99,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                "Ticket Details",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25)),
                                                elevation: 10,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                          "Number of seats : " +
                                                              chosen.toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18,
                                                              color: Colors
                                                                  .white)),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: ListTile(
                                                          title: Text("Seats"),
                                                          subtitle:
                                                              SingleChildScrollView(
                                                            child: Column(
                                                              children: [
                                                                ListView
                                                                    .builder(
                                                                        shrinkWrap:
                                                                            true,
                                                                        itemCount: snapshots
                                                                            .data![
                                                                                "chosen"]
                                                                            .length,
                                                                        itemBuilder:
                                                                            (BuildContext context,
                                                                                indx) {
                                                                          return snapshots.data!["chosen"][indx].split("_")[1] == transactor
                                                                              ? Padding(
                                                                                  padding: const EdgeInsets.all(3.0),
                                                                                  child: ListTile(
                                                                                    tileColor: Colors.grey[200],
                                                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                                                    title: Text((int.parse(snapshots.data!["chosen"][indx].split("_")[0]) + 1).toString()),
                                                                                    trailing: IconButton(
                                                                                        onPressed: () {
                                                                                          setState(() {
                                                                                            snapshots.data!["chosen"].remove((indx));
                                                                                          });
                                                                                          print("cancel");
                                                                                        },
                                                                                        icon: Icon(
                                                                                          Icons.cancel,
                                                                                          size: 30,
                                                                                          color: Colors.red,
                                                                                        )),
                                                                                  ),
                                                                                )
                                                                              : Text("");
                                                                        }),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                          ),
                        );
                      });
                },
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text("Select pickup point"),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.seat.routes.length,
                          itemBuilder: (BuildContext context, index) {
                            return DecoratedBox(
                              decoration:BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border:Border.all(
                                  width: 2,
                                  color: Colors.green
                                ),
                                color: Colors.lightGreen[50]
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        pickup = widget.seat.routes[index].name;
                                      });
                            showDialog(
              context: context,
              builder: (builder) {
                return AlertDialog(
                    content: Container(
                      height:60,
                      child: Column(
                        children: [
                          Text(
                              "You chose  "+pickup +" as pickup point"),
                               Center(
                                 child: Text(
                              "Keep track of bus"),
                               ),
                        ],
                      ),
                    ));
              });
                                      print(widget.seat.routes[index].name +
                                          "  is your pickup point");
                                    },
                                    child: Text(widget.seat.routes[index].name,style:TextStyle(color:Colors.green,fontWeight:FontWeight.bold ))),
                              ),
                            );
                          })
                    ],
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(children: [
                      Text("Overview and Info",style: TextStyle(fontWeight:FontWeight.bold ),),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(),
                  
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 6,
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("appstrings")
                                  .doc("resstops")
                                  .collection("reststops")
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshots) {
                                if (!snapshots.hasData) {
                                  return CircularProgressIndicator();
                                } else if (snapshots.hasError) {
                                  return Text("fix errors");
                                }
                                return snapshots.data!.size<1?Text("No rest stops"): ListView(
                                    shrinkWrap: true,
                                    children: snapshots.data!.docs.map((doc) {
                        
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Card(
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(3.0),
                                                child: DecoratedBox(
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(25)),
                                                    child: Image.network(
                                                        doc["image"])),
                                              ),
                                              ListTile(
                                                  title: Text(doc["name"]),
                                                  subtitle: Text("5 km ahead")),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList());
                              }),
                        ),
                      )
                    ]),
                  ),
                ),
              )
            ])));
  }

  Widget itemBuilder(BuildContext context, int index) {
    return IconButton(
        color: color,
        onPressed: () {
          print(index);
          setState(() {
            color = Colors.green;
          });
        },
        icon: Icon(Icons.chair));
  }
}

class Ticketinfo {
  String booker;
  String tripid;
  String vehid;
  String from;
  String to;
  List<dynamic> chosen;
  DateTime? time;
  int total;
  String pickup;
  String company;
  Ticketinfo(this.from, this.to, this.vehid, this.tripid, this.time,
      this.chosen, this.total, this.booker, this.pickup, this.company);
}

class Initresponse {
  String message;
  Map<String, dynamic> data;
  bool status;
  Initresponse(
      {required this.message, required this.data, required this.status});

  factory Initresponse.fromJson(Map<String, dynamic> json) {
    return Initresponse(
        message: json["message"], data: json["data"], status: json["status"]);
  }
}

Future<Initresponse> _getAccessCodeFrmInitialization(
    double amount, String key, String email) async {
  final response = await http.post(
    Uri.parse("https://api.paystack.co/transaction/initialize"),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      HttpHeaders.authorizationHeader: 'Bearer $key',
    },
    body: jsonEncode(<String, dynamic>{'amount': amount, "email": email}),
  );

  if (response.statusCode == 200) {
// If the server did return a 200 ok response,
// then parse the JSON.
    return Initresponse.fromJson(jsonDecode(response.body));
  } else {
// If the server did not return a 201 CREATED response,
// then throw an exception.match
    throw Exception('Failed to initialise transaction.');
  }
}

int match(List<dynamic> arr, List<dynamic> booked, String startwt) {
  int on = 0;

  arr.forEach((element) {
    if (element.toString().contains(startwt) &&
        element.toString().startsWith(startwt)) {
      on += 1;
      print(on);
    }
  });
  booked.forEach((element) {
    if (element.toString().contains(startwt) &&
        element.toString().startsWith(startwt)) {
      on += 1;
      print(on);
    }
  });

  return on;
}
