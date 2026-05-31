import 'package:flutter/material.dart';
import 'package:travelr/core/theme/app_theme.dart';
import 'package:travelr/live_travel/live_travel_model.dart';
import 'package:travelr/login/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  // This widget is the root of your application.
  LiveTravelSession lts = LiveTravelSession.mock();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travelr',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: SplashScreenPage(title: "travelr"),
    );
  }
}
