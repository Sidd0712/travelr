import 'package:firebase_auth/firebase_auth.dart';
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
        .then((results) {
      if (!mounted) return;
      final isLoggedIn = results[1] as bool;

      if (isLoggedIn) {
        NotificationService().init(
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
    final user = await FirebaseAuth.instance.authStateChanges().first;
    return user != null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
      // Change to match your app background
      //systemNavigationBarIconBrightness: Brightness.dark, // Change icon color if needed
    ));

    return Scaffold(
      body: Center(
        child: Text(
          "travelr",
          style: textTheme.displayLarge?.copyWith(
            fontSize: 52,
            color: colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
