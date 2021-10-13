import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:myapp/components/ticket.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'completebook.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

const AndroidNotificationChannel Channel = AndroidNotificationChannel(
    "interval", "sendinterval", "channel for sending at interval",
    importance: Importance.high, playSound: true, enableLights: true);
const AndroidNotificationChannel Channel1 = AndroidNotificationChannel(
    "future", "sendfuture", "channel for sending infuture",
    importance: Importance.high, playSound: true, enableLights: true);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Ticketinfo info = Ticketinfo(
    "from", "to", "busid", "tripid", DateTime.now(), [], 100, "booker", "", "");
void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
      .createNotificationChannel(Channel);
  runApp(WebViewpg(pageurl: 'flutter.dev', ref: 'ref', ticketinfo: info));
}

class WebViewpg extends StatefulWidget {
  WebViewpg(
      {required this.pageurl, required this.ref, required this.ticketinfo});
  final String pageurl;
  final String ref;
  final Ticketinfo ticketinfo;
  @override
  WebViewpgState createState() => WebViewpgState();
}

class WebViewpgState extends State<WebViewpg> {
  bool hide = true;
  late tz.Location ghana;
  int yr = DateTime.now().year;
  int mnt = DateTime.now().month;
  int day = DateTime.now().day;
  int hour = TimeOfDay.now().hour;
  int min = TimeOfDay.now().minute;
  Future<void> inittz() async {
    tz.initializeTimeZones();
    ghana = tz.local;
  }

  @override
  void initState() {
    super.initState();
    inittz().then((value) {
      print("Time zone initiallzed");
    });
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: hide
            ? Text("")
            : FloatingActionButton.extended(
                label: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("See Ticket"),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Ticket(
                              ticketinfo: widget.ticketinfo,
                            )),
                  );
                }),
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios)),
          centerTitle: true,
          title: Text("Make payment"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Card(
            elevation: 5,
            child: WebView(
              debuggingEnabled: true,
              initialUrl: widget.pageurl,
              javascriptMode: JavascriptMode.unrestricted,
              navigationDelegate: (navigation) {
                print(navigation.url);
                setState(() {
                  if (TimeOfDay.fromDateTime(widget.ticketinfo.time!).minute >
                      30) {
                    hour = TimeOfDay.fromDateTime(widget.ticketinfo.time!).hour;
                    min =
                        TimeOfDay.fromDateTime(widget.ticketinfo.time!).minute -
                            30;
                    print("$hour: $min");
                  } else {
                    hour = TimeOfDay.fromDateTime(widget.ticketinfo.time!).hour;
                    min =
                        TimeOfDay.fromDateTime(widget.ticketinfo.time!).minute -
                            hour;
                    hour = 0;
                  }
                });
                flutterLocalNotificationsPlugin.show(
                    1,
                    "Payment status",
                    "Your payment was successful.See bookings menu for details.",
                    NotificationDetails(
                        android: AndroidNotificationDetails(
                            Channel.id, Channel.name, Channel.description,
                            color: Colors.lightBlue,
                            playSound: true,
                            icon: '@mipmap/ic_launcher')),
                    payload: "payment");
                showDialog(
                    context: context,
                    builder: (builder) {
                      return AlertDialog(
                          content: Column(
                        children: [
                          Text("You wiil be notified 30 minutes to trip."),
                          Text(
                              "You can set different reminders on profile menu"),
                        ],
                      ));
                    });
                flutterLocalNotificationsPlugin.zonedSchedule(
                    2,
                    "Reminder",
                    "Hi ,please be reminded of your trip",
                    tz.TZDateTime.from(
                        DateTime(yr, mnt, day, hour, min), ghana),
                    NotificationDetails(
                        android: AndroidNotificationDetails(
                            Channel1.id, Channel1.name, Channel1.description,
                            color: Colors.lightBlue,
                            playSound: true,
                            icon: '@mipmap/ic_launcher')),
                    uiLocalNotificationDateInterpretation:
                        UILocalNotificationDateInterpretation.absoluteTime,
                    androidAllowWhileIdle: true);
                FirebaseFirestore.instance.collection("bookings").add({
                  "tripid": widget.ticketinfo.tripid,
                  "transactor": widget.ticketinfo.booker,
                  "seats": widget.ticketinfo.chosen,
                  "total": widget.ticketinfo.total,
                  "date": widget.ticketinfo.time,
                  "pickup": widget.ticketinfo.pickup,
                  "from": widget.ticketinfo.from,
                  "to": widget.ticketinfo.to,
                  "company": widget.ticketinfo.company,
                }).then((value) {
                  print("Data added in document : " + value.id);
                  setState(() {
                    hide = false;
                  });
                });

                FirebaseFirestore.instance
                    .collection("trips")
                    .doc(widget.ticketinfo.tripid)
                    .update({
                  "booked": FieldValue.arrayUnion(widget.ticketinfo.chosen)
                });
                if (navigation.url.contains('https://successful.com')) {
                  print("yes");

                  verifytransaction(widget.ref,
                          "sk_test_a310b10d73f4449db22b02c96c28be222a6f4351")
                      .then((value) {
                    print(value.status.toString() + " " + value.message);
                  });
                  //Navigator.of(context).pop();
                } else
                  print("no we just navigated");
                return NavigationDecision.navigate;
              },
            ),
          ),
        ),
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

Future<Initresponse> verifytransaction(String key, String ref) async {
  final response = await http.get(
      Uri.parse("https://api.paystack.co/transaction/verify/" + ref),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $key',
      });

  if (response.statusCode == 200) {
// If the server did return a 201 CREATED response,
// then parse the JSON.
    return Initresponse.fromJson(jsonDecode(response.body));
  } else {
// If the server did not return a 201 CREATED response,
// then throw an exception.
    throw Exception('Failed to create album.');
  }
}
