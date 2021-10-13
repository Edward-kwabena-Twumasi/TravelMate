import 'dart:async';
import 'dart:convert';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:geocoding/geocoding.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/components/applicationwidgets.dart';
import 'package:myapp/providersPool/userStateProvider.dart';
import 'package:myapp/screens/homepage.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

const AndroidNotificationChannel Channel = AndroidNotificationChannel(
    "interval", "sendinterval", "channel for sending at interval",
    importance: Importance.high, playSound: true);
const AndroidNotificationChannel Channel1 = AndroidNotificationChannel(
    "future", "sendfuture", "channel for sending infuture",
    importance: Importance.high, playSound: true);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebasehandlebackgroundmessage(
    RemoteMessage remotemessage) async {
  await Firebase.initializeApp();
  print("You just received a background message $remotemessage");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebasehandlebackgroundmessage);

  if (kIsWeb) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
      .createNotificationChannel(Channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  runApp(Notifies());
}

int messagecount = 0;
String constructFCMPayload(String token) {
  messagecount++;
  return jsonEncode({
    'token': token,
    'data': {
      'via': 'FlutterFire Cloud Messaging!!!',
      'count': messagecount.toString(),
    },
    'notification': {
      'title': 'Hello user!',
      'body': 'This notification (#$messagecount) was created via FCM!',
    },
  });
}

class Notifies extends StatefulWidget {
  const Notifies({Key? key}) : super(key: key);

  @override
  _NotifiesState createState() => _NotifiesState();
}

class _NotifiesState extends State<Notifies> {
  String address = "";
  int yr = DateTime.now().year;
  int mnt = DateTime.now().month;
  int day = DateTime.now().day;
  int hour = TimeOfDay.now().hour;
  int min = TimeOfDay.now().minute;
  String? token;
  double diff = 0;
  String statemsg = "";
  String statemsg1 = "";
  bool cancelperiod = false;
  DateTime now = DateTime.now();
  DateTime future = DateTime.now();
  TextEditingController body = TextEditingController();
  TextEditingController body1 = TextEditingController();
  late tz.Location ghana;
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
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (value != null) {
        print(value.data);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? androidNotification = message.notification!.android;

      if (notification != null && androidNotification != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(
                    Channel.id, Channel.name, Channel.description,
                    color: Colors.lightBlue,
                    playSound: true,
                    icon: '@mipmap/ic_launcher')));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? androidNotification = message.notification!.android;
      if (notification != null && androidNotification != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title.toString()),
                content: SingleChildScrollView(
                  child: Column(
                    children: [Text(notification.body.toString())],
                  ),
                ),
              );
            });
      }
    });
    if (FirebaseAuth.instance.currentUser != null) {
      getToken(FirebaseAuth.instance.currentUser!.uid).then((value) {
        setState(() {
          token = value;
        });
        print(token);
      });
    }
  }

  Future<void> sendPushMessage() async {
    if (token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(token!),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

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
            icon: Icon(Icons.arrow_back_ios, color: Colors.black)),
      ),
      body: Container(
        height: 700,
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50))),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //periodic reminders here
                  Center(child: Text("Set periodic reminders")),

                  InputFields("Add reminder title ", body, Icons.message,
                      TextInputType.multiline),
                  SizedBox(),

                  ButtonBar(children: [
                    TextButton(
                        onPressed: () {
                          flutterLocalNotificationsPlugin.cancel(1);
                          setState(() {
                            cancelperiod = true;
                          });
                        },
                        child: Text("Cancel")),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            cancelperiod = false;
                          });
                          setState(() {
                            statemsg = "You will be notified at" +
                                (TimeOfDay.now().hour + 1).toString() +
                                ":" +
                                TimeOfDay.now().minute.toString();
                          });
                          flutterLocalNotificationsPlugin.periodicallyShow(
                              1,
                              body.text,
                              "Hello ,I am reminding you ",
                              RepeatInterval.hourly,
                              NotificationDetails(
                                  android: AndroidNotificationDetails(
                                      Channel.id,
                                      Channel.name,
                                      Channel.description,
                                      color: Colors.lightBlue,
                                      playSound: true,
                                      icon: '@mipmap/ic_launcher')),
                              payload: "received");
                        },
                        child: Text("Notify hourly")),
                  ]),
                  TextButton(
                      onPressed: () async {
                        setState(() {
                          statemsg = "You will be notified at" +
                              DateTime.now().add(Duration(days: 1)).toString();
                        });
                        flutterLocalNotificationsPlugin.periodicallyShow(
                            1,
                            body.text,
                            "Hello ,I am reminding you ",
                            RepeatInterval.daily,
                            NotificationDetails(
                                android: AndroidNotificationDetails(Channel.id,
                                    Channel.name, Channel.description,
                                    color: Colors.lightBlue,
                                    playSound: true,
                                    icon: '@mipmap/ic_launcher')),
                            payload: "received");
                      },
                      child: Text("Notify daily")),
                  SizedBox(
                    height: 15,
                  ),
                  Divider(),
                  //single reminders code here
                  Center(child: Text("Single reminders")),
                  InputFields("Title reminder", body1, Icons.message,
                      TextInputType.multiline),
                  FloatingActionButton.extended(
                      label: Text("Choose time"),
                      onPressed: () async {
                        showTimePicker(
                                context: context, initialTime: TimeOfDay.now())
                            .then((value) {
                          setState(() {
                            hour = value!.hour;
                            min = value.minute;
                          });
                        });
                      }),

                  ButtonBar(children: [
                    TextButton(
                        onPressed: () {
                          flutterLocalNotificationsPlugin.cancel(2);
                        },
                        child: Text("cancel")),
                    TextButton(
                        onPressed: () async {
                          setState(() {
                            ghana = tz.local;
                          });

                          await flutterLocalNotificationsPlugin.zonedSchedule(
                              2,
                              body1.text,
                              "Hi the time for your reminder is due",
                              tz.TZDateTime.from(DateTime(yr,mnt,day,hour,min), ghana),
                              NotificationDetails(
                                  android: AndroidNotificationDetails(
                                      Channel1.id,
                                      Channel1.name,
                                      Channel1.description,
                                      color: Colors.lightBlue,
                                      playSound: true,
                                      icon: '@mipmap/ic_launcher')),
                              uiLocalNotificationDateInterpretation:
                                  UILocalNotificationDateInterpretation
                                      .absoluteTime,
                              androidAllowWhileIdle: true);

                          setState(() {
                            statemsg1 = "Reminder schedule for $hour:$min";
                          });
                        },
                        child: Text("Remind later")),
                  ]),

                  SizedBox(),
                  // InputFields(
                  //     "Alert me", body, Icons.message, TextInputType.multiline),
                  // SizedBox(),
                  ListTile(
                      title: Text("Periodic notifications"),
                      subtitle: Text(
                        statemsg,
                        style: TextStyle(color: Colors.lightBlue),
                      )),
                  Divider(),
                  ListTile(
                      title: Text("One time notifications"),
                      subtitle: Text(
                        statemsg1,
                        style: TextStyle(color: Colors.lightBlue),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


//set timer