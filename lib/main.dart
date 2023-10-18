import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:tech_media/res/color.dart';
import 'package:tech_media/view/splash/splash_screen.dart';

import 'ViewModel/Autheticate.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.dividedColor,
        // backgroundColor: AppColors.dividedColor,
        appBarTheme: const AppBarTheme(color: AppColors.dividedColor,iconTheme: IconThemeData(color: Colors.white38)),
        fontFamily: 'TiltNeon-Regular',
      ),
      home: const SplashScreen(),
    );
  }
}
