import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging_platform_interface/src/remote_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travelr/home/main_fragment.dart';
import 'package:travelr/login/login.dart';
import 'package:travelr/notifications/notification_router.dart';
import 'package:travelr/notifications/notification_service.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key, required this.title});

  final String title;

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();

    Future.wait(
            [Future.delayed(const Duration(seconds: 3)), _checkAuthStatus()])
        .then((results) async {
      final isLoggedIn = results[1] as bool;

      if (isLoggedIn) {
        await NotificationService().init(
          onForeground: NotificationRouter.handleForegroundNotification,
          onTap: NotificationRouter.handleNotificationTap,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomeScreen(parent: "Sign-In")),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  Future<bool> _checkAuthStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
      // Change to match your app background
      //systemNavigationBarIconBrightness: Brightness.dark, // Change icon color if needed
    ));

    return const Scaffold(
      body: Center(
        child: Text(
          "travelr",
          style: TextStyle(
            fontFamily: "Northlane",
            fontSize: 52,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
