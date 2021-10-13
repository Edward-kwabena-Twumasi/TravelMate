import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum userStates {
  signedIn,
  signedOut,
  isRegistered,
  registerNow,
  wrongPassword,
  weakpassword,
  successful
}

enum userAdded { successful, failed }

class UserState extends ChangeNotifier {
  userStates? signinstate;
  userStates? registedstate;
  String? selectregion;
  String? loggedInAs;
  String? loggedinmail;
  String? registedmail;
  userStates userState() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentuser;

    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        signinstate = userStates.signedOut;

        print('User is currently signed out!');
      } else {
        signinstate = userStates.successful;
        loggedinmail = currentuser!.email;
        //currentuser.getIdToken();
        print('User is signed in!');
      }
    });

    notifyListeners();
    return signinstate!;
  }

  Future<userStates?> signInWithMPass(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      print(userCredential.additionalUserInfo);
      signinstate = userStates.successful;

      print("we done");
      loggedinmail = email;
      print(loggedinmail);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        signinstate = userStates.registerNow;
        print(registedstate);
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        signinstate = userStates.wrongPassword;
      }
    }
    notifyListeners();
    return signinstate;
  }

  Future<userStates?> registerwithMPass(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      print(userCredential.additionalUserInfo);
      registedstate = userStates.successful;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');

        registedstate = userStates.weakpassword;
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        registedstate = userStates.isRegistered;
      }
    } catch (e) {
      print(e);
    }
    notifyListeners();
    return registedstate;
  }

  userAdded isadded = userAdded.successful;
  Future<void> addUser( String email, String phone) {
    //FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    // Call the user's CollectionReference to add a new user

    return users.doc(FirebaseAuth.instance.currentUser!.uid).set({

      'email': email,
      'phone': phone,
     

      // 42
    }).then((value) {
      print("User Added");
    }).catchError((error) {
      isadded = userAdded.failed;
      print("Failed to add user: $error");
    });
  } //adduser
} //end class

Future<void> saveTokenToDatabase(String token) async {
  // Assume user is logged in for this example+
  String userId = FirebaseAuth.instance.currentUser!.uid;

  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'tokens': FieldValue.arrayUnion([token]),
  });
}

Future<String> getToken(String id) async {
  // Assume user is logged in for this example
  //String userId = FirebaseAuth.instance.currentUser!.uid;
  String token="";
  await FirebaseFirestore.instance
      .collection('users')
      .doc(id)
      .get()
      .then((value) {
    token = value["tokens"][(value["tokens"].length-1)];
  });
  return token;
}
