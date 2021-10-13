import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:myapp/providersPool/userStateProvider.dart';
//import 'package:firebase_core/firebase_core.dart';

enum companyStates {
  signedIn,
  signedOut,
  isRegistered,
  registerNow,
  wrongPassword,
  weakpassword,
  successful,
  failed
}

class CompanyState extends ChangeNotifier {
  companyStates? signinstate;
  companyStates? registedstate;
  companyStates? addedstate;
  String signupmsg = "";
  String? selectregion;
  Future<User?> userState() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentuser;

    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        signinstate = companyStates.signedOut;

        print('User is currently signed out!');
      } else {
        signinstate = companyStates.successful;
        currentuser = auth.currentUser;

        //currentuser.getIdToken();
        print('User is signed in!');
      }
    });

    notifyListeners();
    return currentuser;
  }

  Future<companyStates?> signInWithMPass(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      print(userCredential.additionalUserInfo);
      signinstate = companyStates.successful;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        signinstate = companyStates.registerNow;
        print(registedstate);
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        signinstate = companyStates.wrongPassword;
      }
    }

    notifyListeners();
    return signinstate;
  }

  Future<companyStates?> registerwithMPass(
      String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
           print(userCredential.additionalUserInfo);
      registedstate = companyStates.successful;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        registedstate = companyStates.weakpassword;
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        registedstate = companyStates.isRegistered;
      }
    } catch (e) {
      print(e);
    }
    notifyListeners();
    return registedstate;
  }

  Future<companyStates> addCompany(
      String comptype,
      String compname,
      String phone,
      String email,
      String region,
      String city,
      String apartment) async {
    //FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference companies = FirebaseFirestore.instance
        .collection('companies')
        .doc(comptype)
        .collection("Registered Companies");
    // Call the user's CollectionReference to add a new user

    companies.doc(FirebaseAuth.instance.currentUser!.uid).set({
      'type': comptype,
      'registered_name': compname, // John Doe
      'contact': {'phone': phone, 'email': email}, // Stokes and Sons
      'address': {'region': region, 'city': city, 'apartment': apartment},
      'regions': [region],
      'stations': [],
      'vehicles': [],
      'drivers': [],
      'id': FirebaseAuth.instance.currentUser!.uid,
      'ratings':0,
      'reviewpnts':0
      // 42
    }).then((value) {
      addedstate = companyStates.successful;
    }).catchError((error) {
      addedstate = companyStates.failed;
    });
    return addedstate!;
  } //adduser
} //end class
