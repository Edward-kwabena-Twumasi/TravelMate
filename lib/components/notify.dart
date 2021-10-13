import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(Notify());
}

FirebaseMessaging messaging = FirebaseMessaging.instance;

class Notify extends StatefulWidget {
  const Notify({Key? key}) : super(key: key);

  @override
  _NotifyState createState() => _NotifyState();
}

class _NotifyState extends State<Notify> {
  bool checked = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late bool note = false;
//user preferences to show them notice
  Future<bool> shownote() async {
    final SharedPreferences prefs = await _prefs;

    return prefs.getBool('note') ?? true;
  }

  @override
  void initState() {
    shownote().then((value) {
      setState(() {
        note = value;
      });
    });
    // shownote().then((value) {
    //   note = value;
    // });
    super.initState();
  }

  void timer() {}

  var height = 200.0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Column(children: [
        SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 15,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: note == true
                ? AnimatedContainer(
                    duration: Duration(seconds: 1),
                    height: height,
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Text("! Quick note ",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      Divider(color: Colors.lightBlue),
                      Center(
                          child: Text(
                              "Welcome to travel mates.Please be sure to check out our privacy policy,special offers and check out notifications",
                              style: TextStyle(
                                  color: Colors.black, fontSize: 17))),
                      Divider(color: Colors.lightBlue),
                      Row(
                        children: [
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Checkbox(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                side: BorderSide(color: Colors.red, width: 3),
                                checkColor: Colors.lightBlue,
                                activeColor: Colors.lightBlue,
                                value: checked,
                                onChanged: (bool? val)  {
                                  setState(() {
                                    checked = val!;
                                   
                                  });
                                 
                                }),
                          )),
                          Expanded(
                              child: TextButton(
                                  onPressed: ()async {
                                    setState(() {
                                      note = false;
                                    });
                                     final SharedPreferences prefs = await _prefs;
                                  prefs.setBool("note", note);
                                  },
                                  child: Text("Ok Got it ")))
                        ],
                      )
                    ]),
                  )
                : Text(" "),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Center(
            child: ListTile(
                leading: Icon(Icons.watch_later),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: Text("Set Reminders and notices"),
                subtitle: Column(
                  children: [
                    ListTile(
                      title: Text("Remind me"),
                      subtitle:TextField(

                      )
                    ),
                     ListTile(
                        title: Text("Price matches"),
                      subtitle: TextField(),
                    ),
                     ListTile(
                        title: Text("Notify availability"),
                      subtitle: TextField(),
                    ),

                  ],
                )),
          ),
        )
      ]),
    ));
  }
}
