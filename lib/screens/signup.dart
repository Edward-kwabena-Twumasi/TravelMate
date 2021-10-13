import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/components/applicationwidgets.dart';
import 'package:myapp/providersPool/userStateProvider.dart';
import 'package:myapp/screens/homepage.dart';
import 'package:provider/provider.dart';

//MyForm
class SignupForm extends StatefulWidget {
  SignupFormState createState() => SignupFormState();
}

class SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();

  bool tonext = false;
  bool ok = false;
  String errors = "";
  int currentindex = 0;
  TextEditingController email = TextEditingController();
  TextEditingController passwd = TextEditingController();
  TextEditingController passwd1 = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController house = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController regioncontroller = TextEditingController();
  PageController pgecontroller = PageController();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.7,
      child: Column(
        children: [
          Text(
              "Email & password",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Verdana"),
            ),
            Consumer<UserState>(
              builder: (context, value, child) => Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      InputFields("Registeration Email", email, Icons.email,
                          TextInputType.emailAddress),
                      SizedBox(
                        height: 4,
                      ),
                      InputFields(
                          "Phone", phone, Icons.email, TextInputType.phone),
                      SizedBox(
                        height: 4,
                      ),
                      InputFields("Password", passwd, Icons.password,
                          TextInputType.text),
                      SizedBox(
                        height: 4,
                      ),
                      InputFields("Password confirmation", passwd1,
                          Icons.password, TextInputType.text),
                      SizedBox(
                        height: 4,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: RawMaterialButton(
                          fillColor: Colors.white,
                          shape: StadiumBorder(),
                          onPressed: () {
                            // Validate will return true if the form is valid, or false if
                            // the form is invalid.
                            if (_formKey.currentState!.validate() &&
                                passwd.text == passwd1.text) {
                              // Process data.
                              // Navigator.pop(context);
                              value
                                  .registerwithMPass(email.text, passwd.text)
                                  .then((rvalue) {
                                if (rvalue == userStates.successful) {
                                  value
                                      .addUser(email.text, phone.text)
                                      .then((value) {
                                    setState(() {
                                      errors = "Signup successful";

                                      tonext = true;
                                    });

                                    FirebaseAuth.instance.currentUser!
                                        .sendEmailVerification();
                                    showDialog(
                                        context: context,
                                        builder: (builder) {
                                          return AlertDialog(
                                              content: Text(
                                                  "Signup successful .Please check and verify your email"));
                                        });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ButtomNav()),
                                    );
                                  });
                                } else {
                                  print(value);
                                  setState(() {
                                    errors = rvalue.toString();
                                  });
                                }
                              });
                            } else {
                              print("Two passwords must match");
                              setState(() {
                                errors = "Two passwords must match";
                              });
                            }
                          },
                          child: Text(' Submit '),
                        ),
                      ),
                      Center(child: Text(errors))
                    ],
                  ),
                ),
              ),
            ),
          
        ],
      ),
    );
  }
}
