import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelr/login/login.dart';

class HomeScreen extends StatelessWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  void _signOut(BuildContext context) async {
    final navigator = Navigator.of(context);

    await FirebaseAuth.instance.signOut();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(children: [
          SizedBox(
            height: 20,
          ),
          Text(
            "travelr",
            style: TextStyle(
                fontFamily: "Northlane", fontSize: 38, color: Colors.black),
          ),
        ]),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome ${userName.split("@")[0]}!",
                textAlign: TextAlign.justify,
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => _signOut(context),
                style: const ButtonStyle(
                  fixedSize:
                      MaterialStatePropertyAll(Size(double.infinity, 50)),
                  padding: MaterialStatePropertyAll(EdgeInsets.zero),
                  backgroundColor: MaterialStatePropertyAll(Colors.red),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
                ),
                child: const Center(
                  child: Text(
                    "Sign Out",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
