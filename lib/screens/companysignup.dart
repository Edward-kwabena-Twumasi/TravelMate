import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/components/applicationwidgets.dart';
import 'package:myapp/providersPool/agentStateProvider.dart';
import 'package:myapp/providersPool/userStateProvider.dart';
import 'package:provider/provider.dart';

//MyForm
class CompanySignupForm extends StatefulWidget {
  @override
  CompanySignupFormState createState() => CompanySignupFormState();
}

class CompanySignupFormState extends State<CompanySignupForm> {
  TextEditingController? chooseregion;
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  String companytype = "";
  String errormesg = "";
  int currentstep = 0;
  bool tonext = false;
  bool select2 = false;
  bool select1 = false;
  bool select3 = false;
  TextEditingController email = TextEditingController();
  TextEditingController passwd = TextEditingController();
  TextEditingController passwd1 = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController aptmnt = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController regioncontroller = TextEditingController();
  PageController pgecontroller = PageController();

  @override
  void initState() {
    super.initState();
    regioncontroller.text = "ASHANTI";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Stepper(
        type: StepperType.horizontal,
        currentStep: currentstep,
        onStepContinue: () {
          setState(() {
            tonext == true ? currentstep++ : currentstep += 0;
          });
        },
        onStepTapped: (int step) {
          currentstep = step;
        },
        steps: [
          Step(
            title: Text("Email and password"),
            content: Consumer<UserState>(
              builder: (context, value, child) => Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Sign Up",
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: " Serif "),
                      ),
                      InputFields("Company Email", email, Icons.email,
                          TextInputType.emailAddress),
                      SizedBox(
                        height: 5,
                      ),
                      InputFields("Password", passwd, Icons.password,
                          TextInputType.text),
                      SizedBox(
                        height: 5,
                      ),
                      InputFields("Password confirmation", passwd1,
                          Icons.password, TextInputType.text),
                      SizedBox(
                        height: 4,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: RawMaterialButton(
                          fillColor: Colors.green,
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
                                  //Navigator.pushNamed(context, '/home');
                                  setState(() {
                                    tonext = true;
                                    errormesg = "Register successful";
                                  });
                                } else
                                  print(rvalue);
                              });
                            } else
                              print("Two passwords must match");
                          },
                          child: Text('Register'),
                        ),
                      ),
                      Text(errormesg),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Step(
            title: Text("Company info"),
            content: Consumer<CompanyState>(
              builder: (context, value, child) => Form(
                key: _formKey2,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text("Fill form below",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700)),
                      SizedBox(
                        height: 7,
                      ),
                      Text("Company type..."),
                      SizedBox(
                        height: 7,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InputChip(
                            selected: select1,
                            labelPadding: EdgeInsets.all(5),
                            selectedColor: Colors.green,
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
                              selected: select2,
                              labelPadding: EdgeInsets.all(5),
                              selectedColor: Colors.green,
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
                              selected: select3,
                              labelPadding: EdgeInsets.all(5),
                              selectedColor: Colors.green,
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
                      SizedBox(
                        height: 7,
                      ),
                      InputFields("Registered Name", name, Icons.input,
                          TextInputType.name),
                      SizedBox(
                        height: 3,
                      ),
                      InputFields(
                          "Phone ", phone, Icons.phone, TextInputType.phone),
                      SizedBox(
                        height: 3,
                      ),
                      Container(
                          margin: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Text("HQ Location Address",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700)),
                              SizedBox(
                                height: 10,
                              ),
                              Text("Region..."),
                              MenuButton(regioncontroller: regioncontroller),
                              SizedBox(
                                height: 3,
                              ),
                              InputFields("City... ", city, Icons.location_city,
                                  TextInputType.streetAddress),
                              SizedBox(
                                height: 3,
                              ),
                              InputFields(
                                  "Apt Address... ",
                                  aptmnt,
                                  Icons.home_filled,
                                  TextInputType.streetAddress),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            // Validate will return true if the form is valid, or false if
                            // the form is invalid.
                            if (_formKey2.currentState!.validate()) {
                              // Proceed with registration process.

                              value
                                  .addCompany(
                                companytype,
                                name.text,
                                phone.text,
                                email.text,
                                regioncontroller.text,
                                city.text,
                                aptmnt.text,
                              )
                                  .then((val) {
                                if (val == companyStates.successful) {
                                  FirebaseFirestore.instance
                                      .collection("appstrings")
                                      .doc("companynamestrings")
                                      .update({
                                    "companynamestrings":
                                        FieldValue.arrayUnion([
                                      {
                                        "name": name.text.toString(),
                                        "type": companytype,
                                        "stars": 0
                                      }
                                    ])
                                  });
                                  setState(() {
                                    errormesg =
                                        "Info Addition complete.Lets get through verification";
                                  });
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                            content: Text(
                                                "Registration completeted.Please check and verify your email"));
                                      });
                                  Navigator.pushNamed(context, "/companyinfo");
                                }
                              });
                            }
                          },
                          child: Text('Complete signup'),
                        ),
                      ),
                      Text(errormesg),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
