import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:myapp/components/notifications.dart';
 
void main() => runApp(const Admin());

class Admin extends StatelessWidget {
  const Admin({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    const title = 'Admin';
    return MaterialApp(
      title: title,
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text("Admin panel"),
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios)),
          ),
          body: AdminPage()),
    );
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool isverified = false;
  String pattern = "12859610";
  String key = "9IAMTHEADMIN81";
  String match = "";
  String msg = "";
  int track = 0;
  void handlelogin() {
    if (track == 7) {
      print(match);
      if (match == key) {
        setState(() {
          isverified = true;
        });
      } else {
        setState(() {
          msg = "Wrong admin password";
          match = "";
          track = 0;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isverified == false
        ? Container(
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("ADMIN LOGIN",style:TextStyle(fontWeight:FontWeight.bold  ) ,),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Card(
                        child: ListView(shrinkWrap: true, children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Login with your pin"),
                        ),
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.2,
                        children: [
                          SizedBox(
                            height:40,
                            width:60,
                            child: FloatingActionButton.extended(
                               label:Text("1"),
                                heroTag: "b1",
                                onPressed: () {
                                  setState(() {
                                    match += "9";
                                    track += 1;
                                    handlelogin();
                                  });
                                }),
                          ),
                          SizedBox(
                            height:40,
                            width:60,
                            child: FloatingActionButton.extended(

                               label:Text("2"),
                                heroTag: "b2",
                                onPressed: () {
                                  setState(() {
                                    match += "I";
                                    track += 1;
                                    handlelogin();
                                  });
                                }),
                          ),
                          SizedBox(
                            height:40,
                            width:60,
                            child: FloatingActionButton.extended(
                               label:Text("3"),
                              heroTag: "b3", onPressed: () {
                               setState(() {
                                track += 1;
                              });
                            })),
                          SizedBox(
                            height:60,
                            width:60,
                            child: FloatingActionButton.extended(
                               label:Text("4"),
                              heroTag: "b4", onPressed: () {
                               setState(() {
                                track += 1;
                              });
                            })),
                          SizedBox(
                            height:60,
                            width:60,
                            child: FloatingActionButton.extended(
                               label:Text("5"),
                                heroTag: "b5",
                                onPressed: () {
                                  setState(() {
                                    match += "THE";
                                    track += 1;
                                    handlelogin();
                                  });
                                }),
                          ),
                          SizedBox(
                            height:60,
                            width:60,
                            child: FloatingActionButton.extended(
                               label:Text("6"),
                              heroTag: "b6", onPressed: () {
                              setState(() {
                                track += 1;
                              });
                            })),
                          SizedBox(
                            height:60,
                            width:60,
                            child: FloatingActionButton.extended(
                               label:Text("7"),
                                heroTag: "b7",
                                onPressed: () {
                                  setState(() {
                                    match += "8";
                                    track += 1;
                                    handlelogin();
                                  });
                                }),
                          ),
                          SizedBox(
                            height:60,
                            width:60,
                            child: FloatingActionButton.extended(
                               label:Text("8"),
                                heroTag: "b8",
                                onPressed: () {
                                  setState(() {
                                    match += "AM";
                                    track += 1;
                                    handlelogin();
                                  });
                                }),
                          ),
                          SizedBox(
                            height:60,
                            width:60,
                            child: FloatingActionButton.extended(
                               label:Text("9"),
                                heroTag: "b9",
                                onPressed: () {
                                  setState(() {
                                    match += "ADMIN";
                                    track += 1;
                                    handlelogin();
                                  });
                                }),
                          ),
                          SizedBox(
                            height:60,
                            width:60,
                            child: FloatingActionButton.extended(
                               label:Text("10"),
                                heroTag: "b10",
                                onPressed: () {
                                  setState(() {
                                    match += "1";
                                    track += 1;
                                    handlelogin();
                                  });
                                }),
                          ),
                           SizedBox(
                            height:60,
                            width:60,
                            child: FloatingActionButton.extended(
                               label:Text("11"),
                              heroTag: "b11", onPressed: () {
                               setState(() {
                                track += 1;
                              });
                            })),
                             SizedBox(
                            height:60,
                            width:60,
                            child: FloatingActionButton.extended(
                              label:Text("12"),
                              heroTag: "b12", onPressed: () {
                               setState(() {
                                track += 1;
                              });
                            })),
                        ],
                      ),
                      Center(
                        child: Text(msg),
                      )
                    ])),
                  ),
                ],
              ),
            ),
          )
        : PageView(children: [
            
            ShedulesInfo(companytype: "Bus"),
            ShedulesInfo(companytype: "Flight"),
            ShedulesInfo(companytype: "Train")
          ]);
  }
}

class ShedulesInfo extends StatefulWidget {
  final String companytype;

  const ShedulesInfo({Key? key, required this.companytype}) : super(key: key);
  @override
  _ShedulesInfoState createState() => _ShedulesInfoState();
}

class _ShedulesInfoState extends State<ShedulesInfo> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
                title: Text(
                    "Registered companies for " + widget.companytype + "s",
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('companies')
                  .doc(widget.companytype)
                  .collection('Registered Companies')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading companies");
                }

                return new ListView(
                  shrinkWrap: true,
                  children: snapshot.data!.docs.map((data) {
                    return Column(
                      children: [
                        new ListTile(
                          title: new Text("ID :" + data.id),
                          subtitle:Text(data["registered_name"])
                        ),
                        ListTile(
                          title: new Text("Status"),
                          subtitle:Text("Not verified/Authorized"),
                        ),
                        ButtonBar(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: TextButton.icon(onPressed: (){

                              }, icon: Icon(Icons.verified), label: Text("Verify")),
                            ),
                             Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: TextButton.icon(onPressed: (){

                              }, icon: Icon(Icons.security),label: Text("Authorize")),
                            )
                          ],
                        )
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
