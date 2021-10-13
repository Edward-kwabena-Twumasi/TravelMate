import 'package:flutter/material.dart';
import 'package:myapp/components/applicationwidgets.dart';
import 'package:myapp/providersPool/userStateProvider.dart';
import 'package:myapp/screens/agentlogin.dart';
import 'package:myapp/screens/homepage.dart';
import 'package:myapp/screens/signup.dart';

//irebase

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
      create: (context) => UserState(), builder: (context, _) => App()));
}

/// We are using a StatefulWidget such that we only create the [Future] once,
/// no matter how many times our widget rebuild.
/// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire and make our application re-enter loading state,
/// which is undesired.
class App extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return MaterialApp(
              home: Container(
                  child: Text(snapshot.error.toString() +
                      "App encountering some network errors.Please call 0552489602 for assistance")));
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Container(width: 10.0, height: 10.0);
      },
    );
  }
}
//firebase

// void main() {
//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {

 
  final style = TextStyle(
    color: Colors.blueAccent,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
    backgroundColor: Colors.white,
    fontSize: 30,
  );

   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/home": (context) => ButtomNav(),
        "/agentlogin": (context) => MyCompApp()
      },
      title: 'Flutter layout demo',
      theme: new ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Travellers Mobile App'),
          centerTitle: true,
        ),
        body: Center(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 4,
            color: Colors.white,
            child: Consumer<UserState>(
              builder: (context, value, child) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(children: [
                  MyForm(),
                  Positioned(
                      top: 0,
                      right: 0,
                      child: RawMaterialButton(
                        fillColor: Colors.amber,
                        onPressed: () {
                          Navigator.pushNamed(context, '/agentlogin');
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text("Companies",
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        shape: StadiumBorder(),
                      ))
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//MyForm
class MyForm extends StatefulWidget {
  MyFormState createState() => MyFormState();
}

class MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  bool allowlogin = false;
  bool retry = true;
  var correctLogin = "";

  // final String hint, hint1, hint2;
  // final TextEditingController controller;
  // final TextEditingController controller1;
  // final TextEditingController controller2;
  // MyFormState(this.hint, this.hint1, this.hint2, this.controller,
  //     this.controller1, this.controller2);

  final username = TextEditingController();
  final usermail = TextEditingController();
  final userpass = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    // myController.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    userpass.dispose();
    super.dispose();
  }

  // void _printLatestValue() {
  //   print('Second text field: ${myController.text}');
  // }

  bool checkStatus(userStates? state) {
    if (state == userStates.registerNow) {
      setState(() {
        retry = false;
        correctLogin = "You are not a registered user!";
      });
    } else if (state == userStates.wrongPassword) {
      setState(() {
        correctLogin = "You entered wrong password for this account";
      });
    } else if (state == userStates.successful) {
      setState(() {
        allowlogin = true;
      });
    }
    return allowlogin;
  }

  @override
  Widget build(BuildContext context) {
    return retry
        ? Consumer<UserState>(
            builder: (context, value, child) => Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text("Login  ", style: TextStyle(fontFamily: "serif")),
                  InputFields("Enter Username", username, Icons.input,
                      TextInputType.text),
                  SizedBox(
                    height: 5,
                  ),
                  InputFields("Enter Email", usermail, Icons.email,
                      TextInputType.emailAddress),
                  SizedBox(
                    height: 5,
                  ),
                  InputFields("Enter Password", userpass, Icons.password,
                      TextInputType.visiblePassword),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: RawMaterialButton(
                        fillColor: Colors.white,
                        //padding:  EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        onPressed: () {
                          // Validate will return true if the form is valid, or false if
                          // the form is invalid.

                          if (_formKey.currentState!.validate()) {
                            // if (checkStatus(myController1.text)) {
                            //   Navigator.push(context, MaterialPageRoute(
                            //     builder: (context) {
                            //       return TabBarDemo();
                            //     },
                            //   ));
                            // }
                            print(value.signinstate);
                            value
                                .signInWithMPass(usermail.text, userpass.text)
                                .then((registedstate) {
                              checkStatus(registedstate);
                            }).then((value) {
                              if (allowlogin) {
                                Navigator.pushNamed(context, '/home');
                              }
                            });
                          }
                        },

                        child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text('Sign In',
                                style: TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 25,
                                    fontStyle: FontStyle.italic))),
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      children: [
                        Text("Dont have an account?",
                            style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.w100)),
                        TextButton(
                            onPressed: () {
                              // value.setaction("Signup");
                              setState(() {
                                allowlogin = false;
                                retry = false;
                              });
                            },
                            child: Text(' Sign Up ',
                                style: TextStyle(fontStyle: FontStyle.italic))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      correctLogin,
                      style: TextStyle(
                          backgroundColor: Colors.white,
                          color: Colors.red,
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                  TextButton(
                      child: Text("go home"),
                      onPressed: () {
                        Navigator.pushNamed(context, '/home');
                      }),
                ],
              ),
            ),
          )
        : SignupForm();
  }
}
