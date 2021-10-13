import 'package:flutter/material.dart';
import 'package:myapp/components/applicationwidgets.dart';
import 'package:myapp/providersPool/agentStateProvider.dart';
import 'package:myapp/screens/dashboard.dart';
import 'package:myapp/screens/homepage.dart';
import 'package:myapp/screens/companysignup.dart';

//irebase

// Import the firebase_core plugin
//import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => CompanyState(),
    ),
  ], child: MyCompApp()));
}

/// We are using a StatefulWidget such that we only create the [Future] once,
/// no matter how many times our widget rebuild.
/// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire and make our application re-enter loading state,
/// which is undesired.

//firebase

// void main() {
//   runApp(MyApp());
// }
String companytype = "";

class MyCompApp extends StatelessWidget {
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
        "/companyinfo": (context) => DashApp(companytype: companytype)
      },
      title: 'For companies',
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios)),
          title: ListTile(
            title: Text(
              "Travelling Companies",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: AgentForm(),
        ),
      ),
    );
  }
}

//MyForm
class AgentForm extends StatefulWidget {
  AgentFormState createState() => AgentFormState();
}

class AgentFormState extends State<AgentForm> {
  final _formKey = GlobalKey<FormState>();
  bool allowlogin = false;
  bool retry = true;
  bool request = false;
  var correctLogin = "";
  bool select2 = false;
  bool select1 = false;
  bool select3 = false;

  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  TextEditingController regioncontroller = TextEditingController();
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
    name.dispose();
    super.dispose();
  }

  // void _printLatestValue() {
  //   print('Second text field: ${myController.text}');
  // }

  void checkStatus(companyStates? state) {
    if (state == companyStates.registerNow) {
      setState(() {
        // retry = false;
        correctLogin = "You are not a registered user!";
      });
    } else if (state == companyStates.wrongPassword) {
      setState(() {
        correctLogin = "You entered wrong password for this account";
      });
    } else {
      setState(() {
        allowlogin = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return retry
        ? Consumer<CompanyState>(
            builder: (context, value, child) => Container(
              height: 800,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize:MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ListTile(
                            title: Center(
                          child: Text(" Login ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30)),
                        )),
                      ),
                      ListTile(
                        tileColor: Colors.grey[100],
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InputChip(
                              side: BorderSide.none,
                              selected: select1,
                              labelPadding: EdgeInsets.all(5),
                              selectedColor: Colors.lightBlue[100],
                              onPressed: () {
                                setState(() {
                                  companytype = "Bus";
                                  print(companytype);
                                  select1 = true;
                                  select3 = false;
                                  select2 = false;
                                });
                              },
                              label: Text("Bus"),
                              avatar: CircleAvatar(
                                child: Text("B"),
                              ),
                            ),
                            InputChip(
                                side: BorderSide.none,
                                selected: select2,
                                labelPadding: EdgeInsets.all(5),
                                selectedColor: Colors.lightBlue[100],
                                onPressed: () {
                                  setState(() {
                                    companytype = "Flight";
                                    print(companytype);
                                    select2 = true;
                                    select1 = false;
                                    select3 = false;
                                  });
                                },
                                label: Text("Flight"),
                                avatar: CircleAvatar(
                                  child: Text("F"),
                                )),
                            InputChip(
                                side: BorderSide.none,
                                selected: select3,
                                labelPadding: EdgeInsets.all(5),
                                selectedColor: Colors.lightBlue[100],
                                onPressed: () {
                                  setState(() {
                                    companytype = "Train";
                                    print(companytype);
                                    select3 = true;
                                    select1 = false;
                                    select2 = false;
                                  });
                                },
                                label: Text("Train"),
                                avatar: CircleAvatar(
                                  child: Text("T"),
                                )),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      InputFields("Company Email", email, Icons.email,
                          TextInputType.emailAddress),
                      SizedBox(
                        height: 5,
                      ),
                      InputFields(" Password", password, Icons.password,
                          TextInputType.text),
                      Center(
                        child:Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: RawMaterialButton(
                                shape: StadiumBorder(),
                                fillColor: Colors.white,
                                //padding:  EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                onPressed: () {
                                  // Validate will return true if the form is valid, or false if
                                  // the form is invalid.

                                  if (_formKey.currentState!.validate() && companytype.isNotEmpty) {
                                    setState(() {
                                      request = true;
                                    });
                                    value
                                        .signInWithMPass(
                                            email.text, password.text)
                                        .then((registedstate) {
                                      if (registedstate ==
                                          companyStates.successful) {
                                        Navigator.pushNamed(
                                            context, '/companyinfo');
                                      } else if (registedstate ==
                                          companyStates.registerNow) {
                                        setState(() {
                                          correctLogin =
                                              "You are not registered";
                                        });
                                      } else if (registedstate ==
                                          companyStates.wrongPassword) {
                                        setState(() {
                                          correctLogin =
                                              "You entered wrong password";
                                        });
                                      }
                                    });
                                  }
                                  else
                                  {
                                     showDialog(
                                        context: context,
                                        builder: (builder) {
                                          return AlertDialog(
                                              content: Text(
                                                  "Choose companytype to log in"));
                                        });
                                  }
                                },

                                child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(' Login ',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ))),
                              ),
                            ),
                             request == true
                              ? CircularProgressIndicator()
                              : Text("")
                          ],
                        ),
                      ),
                      Text(correctLogin),
                      Center(
                        child: Row(
                          children: [
                            Text(" No account ? "),
                            TextButton(
                              onPressed: () {
                                // value.setaction("Signup");
                                setState(() {
                                  allowlogin = false;
                                  retry = false;
                                });
                              },
                              child: Text('Sign up'),
                            ),
                          ],
                        ),
                      ),
                      //dsiplay any login errors here
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          correctLogin,
                          style: TextStyle(
                              backgroundColor: Colors.white,
                              color: Colors.red,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : CompanySignupForm();
  }
}
