import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelr/database/profile_model.dart';
import 'package:travelr/database/profiles.dart';
import 'package:travelr/login/login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Profile? user;
  String uid = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  void _signOut(BuildContext context) async {
    final navigator = Navigator.of(context);

    await FirebaseAuth.instance.signOut();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  void fetchUserProfile() async {
    Profile? profile = await ProfilesDatabase.getProfileFromUID(uid);
    setState(() {
      user = profile;
    });
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
              const Text(
                "Profile",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              createTextWithFont(user!.name, 28),
              const SizedBox(height: 5),
              createTextWithFont(user!.gender, 25),
              const SizedBox(height: 5),
              createTextWithFont((user!.phoneNumber).toString(), 25),
              const SizedBox(height: 5),
              createTextWithFont("Travel Preference: ${user!.preference}", 25),
              const SizedBox(height: 5),
              createTextWithFont(
                  "Starting Location: (${user!.start.latitude}, ${user!.start.longitude})",
                  25),
              const SizedBox(height: 5),
              createTextWithFont(
                  "Ending Location: (${user!.end.latitude}, ${user!.end.longitude})",
                  25),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => _signOut(context),
                style: const ButtonStyle(
                  fixedSize: WidgetStatePropertyAll(Size(double.infinity, 50)),
                  padding: WidgetStatePropertyAll(EdgeInsets.zero),
                  backgroundColor: WidgetStatePropertyAll(Colors.red),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
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

  Text createTextWithFont(String data, double? size) {
    return Text(
      data,
      style: TextStyle(
        fontSize: size,
        color: Colors.black,
      ),
    );
  }
}
