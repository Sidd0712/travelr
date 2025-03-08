import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelr/home/home_screen.dart';
import 'package:travelr/login/login.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    Future.wait(
            [Future.delayed(const Duration(seconds: 3)), _checkAuthStatus()])
        .then((results) {
      final isLoggedIn = results[1] as bool;

      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
                userName: FirebaseAuth.instance.currentUser?.email ?? 'User'),
          ),
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
