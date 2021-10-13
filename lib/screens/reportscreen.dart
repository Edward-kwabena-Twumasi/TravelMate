import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/providersPool/userStateProvider.dart';
import 'package:myapp/components/applicationwidgets.dart';
import 'package:myapp/screens/homepage.dart';
import 'package:provider/provider.dart';
//import 'package:rate_my_app/rate_my_app.dart';

void main() {
  runApp(Reporter());
}

class Reports extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Reporter(),
    );
  }
}

class Reporter extends StatefulWidget {
  ReporterState createState() => ReporterState();
}

class ReporterState extends State<Reporter> {
  final _formKey = GlobalKey<FormState>();

  final condition = TextEditingController();
  final time = TextEditingController();
  final helphow = TextEditingController();
  final tripid = TextEditingController();
  final itemdescribe = TextEditingController();
  final describe = TextEditingController();
  final recipient = TextEditingController();
  final pgcontrol = PageController();
  var options = ["Health", "Lost Item", "General"];
  String? initialval;

  @override
  void initState() {
    super.initState();
    initialval = options[0];
  }

  void changed(String? value) {
    setState(() {
      initialval = value;
    });
    if (value == options[0]) {
      pgcontrol.animateToPage(0,
          duration: Duration(milliseconds: 50), curve: Curves.easeIn);
    }
    if (value == options[1]) {
      pgcontrol.animateToPage(1,
          duration: Duration(milliseconds: 50), curve: Curves.easeIn);
    }
    if (value == options[2]) {
      pgcontrol.animateToPage(2,
          duration: Duration(milliseconds: 50), curve: Curves.easeIn);
    }
  }

  @override
  void dispose() {
    super.dispose();
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
                    MaterialPageRoute(builder: (context) =>UserInfoClass() ),
                  );
            },
            icon: Icon(Icons.arrow_back_ios ,color:Colors.black )),
       centerTitle:true,
          title: Text("Reports",style: TextStyle(fontWeight:FontWeight.bold ), ),
          elevation: 0,
        
      ),
      body: Consumer<UserState>(
        builder: (context, value, child) => Scaffold(
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Make a report",
                          style: TextStyle(fontFamily: "serif", fontSize: 30))),
                  OptionButton(
                      options: options,
                      onchange: changed,
                      dropdownValue: initialval!),
                  SizedBox(
                    height: 5,
                  ),
                  InputFields("trip id", tripid, Icons.password,
                      TextInputType.visiblePassword),
                  InputFields("report to", recipient, Icons.password,
                      TextInputType.visiblePassword),
                  InputFields("time of incidence", time, Icons.password,
                      TextInputType.visiblePassword),
                  Container(
                    height: 300,
                    child: PageView(
                      controller: pgcontrol,
                      children: [
                        ListView(
                          shrinkWrap: true,
                          children: [
                            InputFields("Describe condition", condition,
                                Icons.password, TextInputType.multiline),
                            InputFields("How may we help you?", helphow,
                                Icons.password, TextInputType.text),
                          ],
                        ),
                        ListView(
                          shrinkWrap: true,
                          children: [
                            UploadPic(
                                foldername: "Reports",
                                imagename: FirebaseAuth
                                    .instance.currentUser!.uid
                                    .substring(2, 2)),
                            InputFields("Describe item", itemdescribe,
                                Icons.password, TextInputType.multiline),
                          ],
                        ),
                        ListView(
                          shrinkWrap: true,
                          children: [
                            InputFields("Give description", describe,
                                Icons.password, TextInputType.multiline),
                            UploadPic(
                                foldername: "Reports",
                                imagename: FirebaseAuth
                                    .instance.currentUser!.uid
                                    .substring(2, 2)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: RawMaterialButton(
                        shape: StadiumBorder(),
                        fillColor: Colors.white,
                        //padding:  EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        onPressed: () {
                          // Validate will return true if the form is valid, or false if
                          // the form is invalid.
                          var reptype = {};
                          if (_formKey.currentState!.validate()) {
                            if (initialval == options[0]) {
                              reptype = {
                                "type": options[0],
                                "condition": condition.text,
                                "helphow": helphow.text
                              };
                            } else if (initialval == options[1]) {
                              reptype = {
                                "type": options[1],
                                "describe": itemdescribe.text,
                                "imageurl": imgUrl
                              };
                            } else if (initialval == options[2]) {
                              reptype = {
                                "type": options[2],
                                "describe": describe.text,
                                "imageurl": imgUrl
                              };
                            }
                            FirebaseFirestore.instance
                                .collection("Reports")
                                .add({
                              "id": tripid.text,
                              "receipient": recipient.text,
                              "attime": time.text,
                              "report": reptype
                            });
                          }
                        },

                        child: Padding(
                            padding: EdgeInsets.all(4),
                            child: Text('Submit report',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ))),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
