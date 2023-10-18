import 'dart:async';

import 'package:flutter/material.dart';
import '../../ViewModel/Autheticate.dart';
import '../../ViewModel/services/SplashServices.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  // SplashServices services = SplashServices();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // services.isLogin(context);
    Timer(
        Duration(seconds: 3),
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => Authenticate(),)));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/chat_icon.png'),
              const Text(
                'BBF Chat App',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40.0,
                    color: Colors.white38),
              ),
              const CircularProgressIndicator()
            ],
          ),
        ));
  }
}
