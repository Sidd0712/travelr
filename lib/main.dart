import 'package:flutter/material.dart';
import 'package:travelr/login/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelr/recommender/recommendation_model.dart';
import 'package:travelr/recommender/recommender_carousel.dart';
import 'login/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.

  static final List<Recommendation> mockRecommendations = [
    Recommendation(
      name: "Zeel Bhadra",
      gender: "Female",
      age: 20,
      overlapDist: 2.0,
      overlapPercent: 0.27,
      meetPoint: "Andheri Station",
      splitPoint: "DJSCE",
      etaAtMeetPoint: const TimeOfDay(hour: 8, minute: 10),
      segments: [
        // RouteSegment(
        //   mode: "Auto",
        //   from: "Andheri Station",
        //   to: "DJSCE",
        //   startTime: const TimeOfDay(hour: 07, minute: 45),
        //   endTime: const TimeOfDay(hour: 08, minute: 00),
        // ),
      ],
    ),

    Recommendation(
      name: "Yash Ghogale",
      gender: "Male",
      age: 21,
      overlapDist: 12.1,
      overlapPercent: 0.56,
      meetPoint: "Vikhroli Station",
      splitPoint: "DJSCE",
      etaAtMeetPoint: const TimeOfDay(hour: 7, minute: 15),
      segments: [
        RouteSegment(
          mode: "Train",
          from: "Vikhroli Train Station",
          to: "Ghatkopar",
          startTime: const TimeOfDay(hour: 07, minute: 05),
          endTime: const TimeOfDay(hour: 07, minute: 15),
        ),
        RouteSegment(
          mode: "Metro",
          from: "Ghatkopar",
          to: "Andheri Station",
          startTime: const TimeOfDay(hour: 07, minute: 20),
          endTime: const TimeOfDay(hour: 07, minute: 40),
        ),
        RouteSegment(
          mode: "Auto",
          from: "Andheri Station",
          to: "DJSCE",
          startTime: const TimeOfDay(hour: 07, minute: 45),
          endTime: const TimeOfDay(hour: 08, minute: 00),
        ),
      ],
    ),
    Recommendation(
      name: "Rhea Sanghvi",
      gender: "Female",
      age: 20,
      overlapDist: 17.6,
      overlapPercent: 0.83,
      meetPoint: "Mulund Station",
      splitPoint: "DJSCE",
      etaAtMeetPoint: const TimeOfDay(hour: 7, minute: 15),
      phoneNumber: "+91 9998884456",
      segments: [
        RouteSegment(
          mode: "Train",
          from: "Mulund Station",
          to: "Ghatkopar",
          startTime: const TimeOfDay(hour: 06, minute: 55),
          endTime: const TimeOfDay(hour: 07, minute: 15),
        ),
        RouteSegment(
          mode: "Metro",
          from: "Ghatkopar",
          to: "Andheri Station",
          startTime: const TimeOfDay(hour: 07, minute: 20),
          endTime: const TimeOfDay(hour: 07, minute: 40),
        ),
        RouteSegment(
          mode: "Auto",
          from: "Andheri Station",
          to: "DJSCE",
          startTime: const TimeOfDay(hour: 07, minute: 45),
          endTime: const TimeOfDay(hour: 08, minute: 00),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travelr',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: RecommenderCarousel(recommendations: mockRecommendations),
    );
  }
}
