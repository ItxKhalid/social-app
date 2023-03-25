import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/ViewModel/services/session_manager.dart';
import 'package:tech_media/utils/routes/route_name.dart';

class SplashServices {
  void isLogin(BuildContext context) {
    final auth = FirebaseAuth.instance;

    final user = auth.currentUser;

    if (user != null) {
      SessionController().userId = user.uid.toString();
      Timer(
          Duration(seconds: 3),
              () => Navigator.pushNamed(context, RouteName.dashboardView));
    } else {
      Timer(
          Duration(seconds: 3),
              () => Navigator.pushNamed(context, RouteName.loginView));
    }
  }
}
