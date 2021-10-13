import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/screens/homepage.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providersPool/userStateProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

//text widget
class TextWidgets extends StatelessWidget {
  final String text;
  final TextStyle mystyle;
  final Icon icon;
  const TextWidgets(this.text, this.mystyle, this.icon);
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: Colors.transparent, borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text(text, style: mystyle),
      ),
    );
  }
}

//input field
class InputFields extends StatelessWidget {
  final TextEditingController controller;
  final String hintext;
  final IconData iconData;
  final TextInputType inputtype;
  const InputFields(
      this.hintext, this.controller, this.iconData, this.inputtype);
  Widget build(BuildContext context) {
    return ListTile(
      title: TextFormField(
        autocorrect: true,
        style: TextStyle(color: Colors.black),
        keyboardType: inputtype,
        decoration: new InputDecoration(
          border: new OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: const BorderRadius.all(
              const Radius.circular(10.0),
            ),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          hintStyle: new TextStyle(color: Colors.black),
          hintText: hintext,
          labelText: hintext,
        ),
        controller: controller,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter $hintext';
          }
          return null;
        },
      ),
    );
  }
}

Widget niceChips(IconData icondata, String text, void Function() pressed) {
  bool selected = false;
  return InputChip(
    backgroundColor: Colors.red[50],
    side: BorderSide.none,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    selected: selected,
    selectedColor: Colors.red[50],
    label: Text(
      text,
      style: TextStyle(fontSize: 20, color: Colors.red),
    ),
    avatar: Icon(icondata),
    labelPadding: EdgeInsets.all(8),
    onPressed: pressed,
  );
}

class MenuButton extends StatefulWidget {
  const MenuButton({Key? key, required this.regioncontroller})
      : super(key: key);

  final TextEditingController? regioncontroller;

  @override
  State<MenuButton> createState() => _MenuButtonState(regioncontroller);
}

/// This is the private State class that goes with MyStatefulWidget.
class _MenuButtonState extends State<MenuButton> {
  final TextEditingController? regioncontroller;
  _MenuButtonState(this.regioncontroller);
  void initState() {
    super.initState();
  }

  String? dropdownValue = 'ASHANTI';

  var regions = [
    'ASHANTI',
    'CENTRAL',
    'AHAFO',
    'UPPER WEST',
    'UPPER EAST',
    'NORTHERN',
    'WESTERN',
    'OTI',
    'VOLTA',
    'EASTERN',
    'GREATER ACCRA'
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Consumer<UserState>(
        builder: (context, value, child) => Row(
          children: [
            // InputFields("Region", widget.regioncontroller!, Icons.place,
            //     TextInputType.text),
            DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.pin_drop_outlined),
              iconSize: 34,
              elevation: 16,
              style: const TextStyle(color: Colors.black),
              underline: Container(
                height: 1,
              ),
              onChanged: (String? newValue) {
                // widget.regioncontroller!.text = newValue!;
                setState(() {
                  dropdownValue = newValue;
                });
                value.selectregion = dropdownValue;
                print(value.selectregion);
                regioncontroller!.text = dropdownValue!;
              },
              items: regions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Expanded(
                child: TextField(
              controller: regioncontroller,
              decoration: new InputDecoration(
                border: new OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ))
          ],
        ),
      ),
    );
  }
}

TripClass onetrip =
    TripClass("Obuasi", "Obuasi", DateTime.now(), DateTime.now(), "normal", "");
List places = ["Kumasi", "Obuasi", "Accra", "Kasoa", "Mankessim", "Wa"];

class SearchLocs extends StatefulWidget {
  SearchLocs({
    required this.direction,
    required this.locations,
    required this.searchcontrol,
  });
  final TextEditingController searchcontrol;

  final String direction;
  final List locations;
  @override
  SearchLocsState createState() => SearchLocsState();
}

class SearchLocsState extends State<SearchLocs> {
  final FocusNode focusNode = FocusNode();
  OverlayEntry? myoverlay;
  bool hideoverlay = false;
  bool foundinlist = false;
  var mytripobj = {};
  @override
  void initState() {
    super.initState();

    widget.searchcontrol.addListener(() {
      // widget.searchcontrol.text = widget.searchcontrol.text.substring(0,).toUpperCase()+
      // widget.searchcontrol.text.substring(1);
      suggestions = [];
      for (var i in widget.locations) {
        if ((i
                .toLowerCase()
                .startsWith(widget.searchcontrol.text.toLowerCase()) ||
            i
                .toLowerCase()
                .contains(widget.searchcontrol.text.toLowerCase()))) {
          suggestions.add(i);
        } else
          suggestions.remove(i);
      }
    });

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        this.myoverlay = createOverlay();
        Overlay.of(context)!.insert(this.myoverlay!);
      } else {
        myoverlay!.remove();
      }
    });
  }

  OverlayEntry createOverlay() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
        builder: (context) => Positioned(
              left: offset.dx,
              top: offset.dy + size.height,
              width: size.width,
              child: Material(
                elevation: 4.0,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ListTile(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                key: Key(index.toString()),
                                onTap: () {
                                  this.myoverlay!.remove();

                                  print(index);
                                  mytripobj[widget.direction] =
                                      suggestions[index];
                                  widget.searchcontrol.text =
                                      suggestions[index];

                                  widget.direction == "From"
                                      ? onetrip.fromLoc =
                                          widget.searchcontrol.text
                                      : onetrip.toLoc =
                                          widget.searchcontrol.text;
                                  suggestions = [];
                                  print(suggestions);
                                  print(mytripobj);
                                },
                                title: Text(
                                  suggestions[index],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                )),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<String> suggestions = [];

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextFormField(
        decoration: InputDecoration(
            labelText: "Travel ${widget.direction}",
            fillColor: Colors.pink,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none)),
        controller: widget.searchcontrol,
        focusNode: this.focusNode,
      ),
    );
  }
}

//options menu
class OptionButton extends StatefulWidget {
  const OptionButton(
      {Key? key,
      required this.options,
      required this.onchange,
      required this.dropdownValue})
      : super(key: key);
  final List<String> options;
  final String dropdownValue;
  final void Function(String? change) onchange;
  @override
  State<OptionButton> createState() => _OptionButtonState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _OptionButtonState extends State<OptionButton> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Center(
            child: SizedBox(
              height: 40,
              child: DropdownButton<String>(
                value: widget.dropdownValue,
                icon: const Icon(Icons.pin_drop_outlined),
                iconSize: 34,
                elevation: 16,
                style: const TextStyle(color: Colors.black),
                underline: Container(
                  height: 1,
                ),
                onChanged: widget.onchange,
                items: widget.options
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? imgUrl;

class UploadPic extends StatefulWidget {
  const UploadPic({
    Key? key,
    required this.foldername,
    required this.imagename,
  }) : super(key: key);

  final String foldername, imagename;

  @override
  _UploadPicState createState() => _UploadPicState();
}

class _UploadPicState extends State<UploadPic> {
  bool notdone = false;
  void upLoadimg() async {
    print("starting upload");
    final picker = ImagePicker();
    XFile? image;
    image = await picker.pickImage(source: ImageSource.gallery);

    var file = File(image!.path);
    print(file);
    // ignore: unnecessary_null_comparison
    if (file != null) {
      print("file is not nul");
      var snapshot = await FirebaseStorage.instance
          .ref(FirebaseAuth.instance.currentUser!.uid.substring(0, 5))
          .child(widget.foldername + "/" + widget.imagename)
          .putFile(file)
          .whenComplete(() {
        setState(() {
          notdone = false;
        });
        print("done");
      });
      var geturl = await snapshot.ref.getDownloadURL();
      setState(() {
        imgUrl = geturl;
      });
    } else {
      print("no image chosen");
    }
  }

  @override
  Widget build(BuildContext context) {
    return notdone
        ? CircularProgressIndicator()
        : Container(
            child: Center(
                child: Column(
            children: [
              (imgUrl != null)
                  ? Image.network(imgUrl!, cacheHeight: 120, cacheWidth: 120)
                  : Placeholder(
                      fallbackHeight: 120,
                      fallbackWidth: 120,
                    ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton.extended(
                backgroundColor: Colors.white,
                onPressed: () {
                  setState(() {
                    notdone = true;
                  });
                  upLoadimg();
                },
                label: Text(
                  "Choose image",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 5)
            ],
          )));
  }
}

class Policy extends StatefulWidget {
  const Policy({Key? key}) : super(key: key);

  @override
  _PolicyState createState() => _PolicyState();
}

class _PolicyState extends State<Policy> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Container(
        height: height,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                    title: Text("Usage policy"),
                    subtitle: Text(
                        "Respect all rules laid down on this app.Amy malicious ...")),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                    title: Text("Refund policy"),
                    subtitle: Text(
                        "Refunds will be done under the following conditions")),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                    title: Text("Transfer policy"),
                    subtitle: Text(
                        "Users who have bought tickets ,also called transactors can transfer their tickets to other accounts")),
              ),
            ]),
          ),
        ));
  }
}

class Paymenu extends StatefulWidget {
  const Paymenu({Key? key}) : super(key: key);

  @override
  PaymenuState createState() => PaymenuState();
}

class PaymenuState extends State<Paymenu> {
  String? email = FirebaseAuth.instance.currentUser!.email;

  int amount = 0;
  TextEditingController amnt = TextEditingController();
  TextEditingController tid = TextEditingController();
  String url = "";
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
          height: height * 0.4,
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(children: [
                  Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: FloatingActionButton.extended(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Mypays()),
                            );
                          },
                          label: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Payment History"),
                            ),
                          ))),
                  Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: FloatingActionButton.extended(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (builder) {
                                  return AlertDialog(
                                    content: Column(
                                      children: [
                                        TextField(
                                          controller: amnt,
                                          decoration: InputDecoration(
                                              hintText: "Enter amount"),
                                        ),
                                        TextField(
                                          controller: tid,
                                          decoration: InputDecoration(
                                              hintText: "Trip id"),
                                        ),
                                        TextButton(
                                            onPressed: () {
                                              setState(() {
                                                amount = int.parse(amnt.text);
                                              });
                                            },
                                            child: Text("Ok"))
                                      ],
                                    ),
                                  );
                                }).then((value) {
                              if (amnt.text.isNotEmpty && tid.text.isNotEmpty) {
                                _getAccessCodeFrmInitialization(
                                        amount * 100,
                                        "sk_test_a310b10d73f4449db22b02c96c28be222a6f4351",
                                        email!)
                                    .then((value) {
                                  setState(() {
                                    url = value.data["authorization_url"]
                                            .toString() +
                                        "/" +
                                        value.data["access_code"].toString();
                                  });
                                  showDialog(
                                      context: context,
                                      builder: (builder) {
                                        return AlertDialog(
                                            content: Text(
                                                "Payment for Luggage successful"));
                                      });
                                });
                              }
                            });
                          },
                          label: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Pay for Luggage"),
                            ),
                          ))),
                ]),
              ),
            ),
          )),
    );
  }
}

class Compareprice extends StatefulWidget {
  const Compareprice({Key? key}) : super(key: key);

  @override
  _ComparepriceState createState() => _ComparepriceState();
}

class _ComparepriceState extends State<Compareprice> {
  TextEditingController origin = TextEditingController();
  TextEditingController destin = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      height: height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                    child: InputFields("from", origin, Icons.location_city,
                        TextInputType.text)),
                Expanded(
                    child: InputFields(
                        "to", destin, Icons.location_city, TextInputType.text))
              ],
            ),
          ),
          ButtonBar(
            children: [
              TextButton(onPressed: () {}, child: Text("List comparisons"))
            ],
          ),
          Card(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("20 GHS"),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("30 GHS"),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("100 GHS"),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class FindateTrips extends StatefulWidget {
  const FindateTrips({Key? key}) : super(key: key);

  @override
  _FindateTripsState createState() => _FindateTripsState();
}

class _FindateTripsState extends State<FindateTrips> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Container(
      height: height,
    );
  }
}

class Offers extends StatefulWidget {
  const Offers({Key? key}) : super(key: key);

  @override
  _OffersState createState() => _OffersState();
}

class _OffersState extends State<Offers> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [Text("Offers appear here")],
      ),
    );
  }
}

class Mybooks extends StatefulWidget {
  const Mybooks({Key? key}) : super(key: key);

  @override
  MybooksState createState() => MybooksState();
}

String contact = "";

class MybooksState extends State<Mybooks> {
  TextEditingController newowner = TextEditingController();
  Future userdata() async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
  }

  void initState() {
    super.initState();
    userdata().then((value) {
      setState(() {
        contact = value["contact"]["phone"];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserInfoClass()),
              );
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
      ),
      body: DecoratedBox(
          decoration: BoxDecoration(),
          child: SingleChildScrollView(
              child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Padding(
                    padding: EdgeInsets.all(5),
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text("My bookings",
                            style: TextStyle(
                                color: Colors.lightBlue, fontSize: 30)),
                      ),
                    )),
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("bookings")
                      .where("transactor",
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                    } else if (snapshot.hasError) {
                      print(snapshot.error.toString());
                      return Text(snapshot.error.toString());
                    }
                    return snapshot.data!.size < 1
                        ? Text("No booking history")
                        : SingleChildScrollView(
                            child: Column(
                                children: snapshot.data!.docs.map((doc) {
                              return Padding(
                                padding: const EdgeInsets.all(9.0),
                                child: Card(
                                  color: Colors.grey[300],
                                  child: ExpansionTile(
                                      children: [
                                        Center(
                                          child: Text(
                                            "Ticket details",
                                            style: TextStyle(
                                                color: Colors.lightBlue),
                                          ),
                                        ),
                                        Divider(color: Colors.lightBlue),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: ListTile(
                                                      title:
                                                          Text(doc["company"]),
                                                      subtitle:
                                                          Text("Company"))),
                                              Expanded(
                                                  child: ListTile(
                                                title: Text(doc["tripid"]),
                                                subtitle: Text("Tripid"),
                                              )),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: ListTile(
                                                      title: Text(doc["seats"]
                                                          .toString()),
                                                      subtitle: Text("Seats"))),
                                              Expanded(
                                                  child: ListTile(
                                                title: Text(doc["transactor"]),
                                                subtitle: Text("Booker id"),
                                              )),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: ListTile(
                                                      title: Text(doc["from"]),
                                                      subtitle: Text("From"))),
                                              Expanded(
                                                  child: ListTile(
                                                title: Text(doc["to"]),
                                                subtitle: Text("To"),
                                              )),
                                            ],
                                          ),
                                        ),
                                        Center(
                                            child: ListTile(
                                                title: Text("QR code"),
                                                subtitle: QrImage(
                                                  data: doc["transactor"],
                                                  version: QrVersions.auto,
                                                  size: 100.0,
                                                ))),
                                      ],
                                      title: Text(
                                        doc["date"]
                                                    .toDate()
                                                    .difference(DateTime.now())
                                                    .inDays >
                                                0
                                            ? "Starting on " +
                                                doc["date"].toDate().toString()
                                            : "Booked  on " +
                                                doc["date"].toDate().toString(),
                                      ),
                                      subtitle: ButtonBar(children: [
                                        TextButton(
                                            onPressed: () {
                                              String refund = "";
                                              var bookt =
                                                  TimeOfDay.fromDateTime(
                                                      doc["date"].toDate());
                                              var nowt = TimeOfDay.fromDateTime(
                                                  DateTime.now());

                                              int diff = (bookt.hour * 60 +
                                                      bookt.minute) -
                                                  (nowt.hour * 60 +
                                                      nowt.minute);

                                              if (diff >= 60) {
                                                setState(() {
                                                  refund =
                                                      "Cancelled about an hour to time,you get full refund";
                                                });
                                              } else if (diff > 30) {
                                                setState(() {
                                                  refund =
                                                      "Cancelled more than 30 mins to time,you 75% full refund";
                                                });
                                              } else
                                                setState(() {
                                                  refund =
                                                      "Cancelled in  30 mins to time,you get 50% refund";
                                                });

                                              FirebaseFirestore.instance
                                                  .collection("bookings")
                                                  .doc(doc.id)
                                                  .delete()
                                                  .then((value) {
                                                showDialog(
                                                    context: context,
                                                    builder: (builder) {
                                                      return AlertDialog(
                                                        content: Column(
                                                          children: [
                                                            Text(
                                                                "Ticket cancelled succesfully"),
                                                            Text(refund),
                                                            Text(
                                                                "Refer to usage policy for more")
                                                          ],
                                                        ),
                                                      );
                                                    });
                                              });
                                            },
                                            child: Text("Cancel")),
                                        TextButton(
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection("announcements")
                                                  .doc(doc.id)
                                                  .set({
                                                "message": "Ticket for sale",
                                                "call": contact,
                                                "interested": [],
                                                "transactor": FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                "type": "Ticketsale"
                                              });
                                            },
                                            child: Text("Sell")),
                                        TextButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (builder) {
                                                    return AlertDialog(
                                                        content: Column(
                                                      children: [
                                                        Text(
                                                          "Fill reschedule info",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        InputFields(
                                                            "New owner id",
                                                            newowner,
                                                            Icons.chair,
                                                            TextInputType
                                                                .number),
                                                        TextButton(
                                                            onPressed: () {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "trips")
                                                                  .doc(doc.id)
                                                                  .update({
                                                                "transactor":
                                                                    newowner
                                                                        .text
                                                              });
                                                            },
                                                            child: Text("Endorse"))
                                                      ],
                                                    ));
                                                  });
                                            },
                                            icon: Icon(Icons.price_change),
                                            label: Text("New owner"))
                                      ])),
                                ),
                              );
                            }).toList()),
                          );
                  })
            ],
          ))),
    );
  }
}

class Mypays extends StatefulWidget {
  const Mypays({Key? key}) : super(key: key);

  @override
  MypaysState createState() => MypaysState();
}

class MypaysState extends State<Mypays> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserInfoClass()),
              );
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(color: Colors.grey[50]),
        child: Center(
            child: SingleChildScrollView(
                child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("My payments",
                      style: TextStyle(color: Colors.lightBlue)),
                ),
              )),
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("bookings")
                    .where("transactor",
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  } else if (snapshot.hasError) {
                    print(snapshot.error.toString());
                    return Text(snapshot.error.toString());
                  }
                  return snapshot.data!.size < 1
                      ? Text("No payment history")
                      : ListView(
                          shrinkWrap: true,
                          children: snapshot.data!.docs.map((doc) {
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ExpansionTile(
                                backgroundColor: Colors.white,
                                children: [
                                  Center(
                                    child: Text(
                                      "Payment History",
                                      style: TextStyle(color: Colors.lightBlue),
                                    ),
                                  ),
                                  Divider(color: Colors.lightBlue),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: ListTile(
                                                title: Text(doc["from"]),
                                                subtitle: Text("From"))),
                                        Expanded(
                                            child: ListTile(
                                          title: Text(doc["to"]),
                                          subtitle: Text("To"),
                                        )),
                                      ],
                                    ),
                                  ),
                                  Center(
                                    child: ListTile(
                                      title: Text("Company"),
                                      subtitle: Text(doc['company'].toString()),
                                    ),
                                  ),
                                  Center(
                                    child: ListTile(
                                      title: Text("Amount paid"),
                                      subtitle: Text(
                                          (doc['total'] / 100).toString() +
                                              " GHS"),
                                    ),
                                  ),
                                ],
                                title: Text(
                                  "Happened  on " +
                                      doc["date"].toDate().toString(),
                                ),
                              ),
                            );
                          }).toList());
                })
          ],
        ))),
      ),
    );
  }
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

class Anounce extends StatefulWidget {
  const Anounce({Key? key}) : super(key: key);

  @override
  _AnounceState createState() => _AnounceState();
}

class _AnounceState extends State<Anounce> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("Announcements",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                    )),
              ),
            ),
            SizedBox(
              height: 35,
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("announcements")
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  } else if (snapshot.hasError) {
                    print(snapshot.error.toString());
                    return Text(snapshot.error.toString());
                  }
                  return snapshot.data!.size < 1
                      ? Text("No announcements")
                      : ListView(
                          shrinkWrap: true,
                          children: snapshot.data!.docs.map((doc) {
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Card(
                                color: Colors.lightBlue[200],
                                child: ExpansionTile(
                                  backgroundColor: Colors.white,
                                  children: [
                                    Center(
                                      child: ListTile(
                                        title: Text("Message"),
                                        subtitle:
                                            Text(doc['message'].toString()),
                                      ),
                                    ),
                                    Center(
                                      child: ListTile(
                                        title: Text("By :"),
                                        subtitle: Text(doc['transactor'] ==
                                                FirebaseAuth
                                                    .instance.currentUser!.uid
                                            ? "You"
                                            : "Unknown"),
                                      ),
                                    ),
                                    Center(
                                        child: Text("Phone : " + doc["call"])),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                          doc["interested"].length.toString() +
                                              " interests expressed",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                  title: doc['transactor'] ==
                                          FirebaseAuth.instance.currentUser!.uid
                                      ? TextButton(
                                          onPressed: () {},
                                          child: Text("Remove"))
                                      : TextButton(
                                          onPressed: () {},
                                          child: Text("Express interest")),
                                ),
                              ),
                            );
                          }).toList());
                })
          ],
        ),
      ),
    );
  }
}
