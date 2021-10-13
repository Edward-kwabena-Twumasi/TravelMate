//import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/components/applicationwidgets.dart';
import 'package:myapp/components/notifications.dart';

import 'package:myapp/screens/googlemap.dart';
import 'package:myapp/screens/reportscreen.dart';

List reviewtokens = [
  "nice",
  "good",
  "great",
  "bad",
  "enjoyed",
  "like",
  "dislike",
  "not",
  "worse",
  "awesome",
  "very",
  "soo"
];
List<int> tokenweights = [2, 2, 3, -3, 4, 2, -2, -3, -4, 5, 2, 3];
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Features());
}

class Features extends StatefulWidget {
  const Features({Key? key}) : super(key: key);

  @override
  _FeaturesState createState() => _FeaturesState();
}

class _FeaturesState extends State<Features> {
  var starred = [];
  List<String> options = [""];
  int starindex = -1;
  int stars = 5;
  String dropval = "";
  String temp = "";
  var weigts = [];
  var tokens = [];
  var docids = [];
  int result = 0;
  Future<List<dynamic>> cities() async {
    var docs = await FirebaseFirestore.instance
        .collection("appstrings")
        .doc("companynamestrings")
        .get();
    return docs["companynamestrings"];
  }

  Future<List<dynamic>> tripstar(String company) async {
    var docs = await FirebaseFirestore.instance
        .collection("trips")
        .where("company", isEqualTo: company)
        .get();
    return docs.docs;
  }

  void initState() {
    super.initState();
    cities().then((value) {
      options = [];
      for (var item in value) {
        setState(() {
          options.add(item["name"].toString() + "-" + item["type"].toString());
        });
        print(item["name"]);
      }
      print(options.length);
      setState(() {
        dropval = options[0];
      });
    });
  }

  TextEditingController reviewtext = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      child: Card(
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            SizedBox(
              height: 50,
              width: 50,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  heroTag: "1",
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                  onPressed: () {
                    showModalBottomSheet(
                        backgroundColor: Colors.amber[100],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10))),
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return FractionallySizedBox(
                              heightFactor: 0.5, child: Paymenu());
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Pay",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 25)),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 70,
              width: 70,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Mybooks()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Bookings",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 25),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 70,
              width: 70,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  heroTag: "2",
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (buildContext) {
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                OptionButton(
                                    options: options,
                                    onchange: (val) {
                                      print(val);
                                      setState(() {
                                        dropval = val!;
                                      });
                                    },
                                    dropdownValue: dropval),
                                ListTile(
                                    leading: Text((starindex+1).toString()+ "stars"),
                                    trailing: IconButton(
                                        onPressed: () async {
                                          temp = dropval;
                                          temp = temp.split("-")[0];
                                          showDialog(
                                              context: context,
                                              builder: (builder) {
                                                return AlertDialog(
                                                  content: Text(
                                                      "You rated $temp " +
                                                          (starindex + 1)
                                                              .toString() +
                                                          "stars"),
                                                );
                                              });

                                          tripstar(temp)
                                              .then((value) {
                                            for (var i in value) {
                                              FirebaseFirestore.instance
                                                  .collection("trips")
                                                  .doc(i.id)
                                                  .update({
                                                "stars": FieldValue.increment(
                                                    (starindex + 1))
                                              });
                                              docids.add(i.id);
                                              print(i.id);
                                            }
                                          });
                                        },
                                        icon: Icon(
                                          Icons.send,
                                        )),
                                    subtitle: Container(
                                        height: 80,
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemCount: stars,
                                            itemBuilder: (context, index) {
                                              print(index);
                                              return StatefulBuilder(
                                                builder: (context, setState) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            starindex = index;
                                                          });
                                                          print(
                                                              "You choose $starindex+1 stars");
                                                          print(starindex);
                                                          starred = [];
                                                          for (var i = 0;
                                                              i < (index + 1);
                                                              i++) {
                                                            setState(() {
                                                              starred.add(i);
                                                            });
                                                          }
                                                        },
                                                        icon: Icon(Icons.star,
                                                            size: 30,
                                                            color: index <=
                                                                        starindex ||
                                                                    starred
                                                                        .contains(
                                                                            index)
                                                                ? Colors.red
                                                                : Colors.grey)),
                                                  );
                                                },
                                              );
                                            }))),
                              ],
                            ),
                          );
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Rate",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 25)),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 70,
              width: 70,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (buildcontext) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                             border: Border(
                               top: BorderSide(color:Colors.red,width: 20 )
                             ),
                              // borderRadius: BorderRadius.only(
                              //   topLeft: Radius.circular(20),
                              //   topRight: Radius.circular(5)
                              // )
                            ),
                            child: Column(children: [
                              StatefulBuilder(builder: (context, setState) {
                                return OptionButton(
                                    options: options,
                                    onchange: (val) {
                                      print(val);
                                      setState(() {
                                        dropval = val!;
                                      });
                                    },
                                    dropdownValue: dropval);
                              }),
                              TextField(
                                controller: reviewtext,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                    icon: Icon(Icons.reviews),
                                    hintText: "Write review here",
                                     border: new OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(20.0),
                                        
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.lightBlue[50],
                                    ),
                                    
                                    
                                    
                              ),
                              TextButton(
                                  onPressed: () async {
                                    weigts = [];
                                    result = 1;
                                    tokens = reviewtext.text.split(" ");
                                    for (var t in tokens) {
                                      if (reviewtokens
                                          .contains(t.toString().toLowerCase())) {
                                        weigts.add(reviewtokens.indexOf(t));
                                        result *=
                                            tokenweights[reviewtokens.indexOf(t)];
                                      }
                                    }
                          
                                    print("found " +
                                        weigts.length.toString() +
                                        "relevant words  $weigts");
                                    showDialog(
                                        context: context,
                                        builder: (builder) {
                                          return AlertDialog(
                                            content: Text(result > 0
                                                ? "Feedback is positive.Thank you for the review."
                                                : "Feedback is negative.Thank you for the review."),
                                          );
                                        });
                                  },
                                  child: Text("Submit review"))
                            ]),
                          );
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Review",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 25)),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 70,
              width: 70,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Reports()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Report",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 25)),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 70,
              width: 70,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Mymap()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.location_on,
                      size: 35,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 70,
              width: 70,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Notifies()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.watch_later,
                      size: 35,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
