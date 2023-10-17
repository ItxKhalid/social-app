import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/ViewModel/services/session_manager.dart';
import '../../utils/routes/route_name.dart';
import '../../utils/utils.dart';
import '../../view/login/login_screen.dart';

class LogInController with ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('user');
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void login(BuildContext context,String email,
      String password) async {
    setLoading(true);
    try {
      auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        SessionController().userId = value.user!.uid.toString();
        Navigator.pushNamed(context, RouteName.dashboardView);
        Utils().toastMassage('LogIn Successfully',false);
        setLoading(false);
      }).onError((error, stackTrace) {
        Utils().toastMassage(error.toString(),true);
        setLoading(false);
      });
    } catch (e) {
      Utils().toastMassage(e.toString(),true);
      setLoading(false);
    }
  }


  Future<User?> createAccount(String name, String email, String password) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      UserCredential userCrendetial = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      print("Account created Succesfull");

      userCrendetial.user!.updateDisplayName(name);

      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        "name": name,
        "email": email,
        "status": "Unavalible",
        "uid": _auth.currentUser!.uid,
      });

      return userCrendetial.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> logIn(BuildContext context ,String email, String password) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      print("Login Sucessfull");
      _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get()
          .then((value) {
        userCredential.user!.updateDisplayName(value['name']);
        SessionController().userId = _auth.currentUser!.uid;
        Navigator.pushNamed(context, RouteName.dashboardView);
        Utils().toastMassage('LogIn Successfully',false);
        setLoading(
        false
        );
      });

      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future logOut(BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      await _auth.signOut().then((value) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      });
    } catch (e) {
      print("error");
    }
  }
}

