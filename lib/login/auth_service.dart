import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelr/database/profile_model.dart';
import 'package:travelr/database/profile_service.dart';
import 'package:travelr/home/home_screen.dart';

class AuthService {
  Future<void> signUp(
      {required Map<String, dynamic> data,
      required BuildContext context}) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data["email"],
        password: data["password"],
      );

      String uid = userCredential.user?.uid ?? "";
      if (uid.isEmpty) {
        throw FirebaseAuthException(
            code: "unknown", message: "User ID not found");
      }

      String name = data['name'] ?? '';
      int phone = int.parse(data['phone']);
      GeoPoint start = data['startingLocation'] ?? GeoPoint(0, 0);
      GeoPoint end = data['endingLocation'] ?? GeoPoint(0, 0);
      String gender = data['gender'];
      String genderPreference = data['genderPreference'];

      Profile newUser = Profile(
        uid: uid,
        name: name,
        gender: gender,
        phoneNumber: phone,
        preference: genderPreference,
        start: start,
        end: end,
      );

      await ProfilesDatabase.addProfile(newUser);

      messenger.showSnackBar(
        const SnackBar(
            backgroundColor: Colors.black,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 5),
                Text("Sign-Up Successful!")
              ],
            )),
      );

      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext newContext) => const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "";
      if (e.code == 'weak-password') {
        message = "Weak Password. Please choose a stronger password.";
      } else if (e.code == 'email-already-in-use') {
        message = "An account already exists with this email.";
      } else {
        message = "An unknown error occurred.";
      }

      messenger.showSnackBar(
        SnackBar(
            backgroundColor: Colors.black,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 5),
                Text(message)
              ],
            )),
      );
    } catch (e) {
      await FirebaseAuth.instance.currentUser?.delete();

      messenger.showSnackBar(
        const SnackBar(
            backgroundColor: Colors.black,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 5),
                Text("Error while creating profile. Please try again.")
              ],
            )),
      );
    }
  }

  Future<void> signIn(
      {required String email,
      required String password,
      required BuildContext context}) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      messenger.showSnackBar(
        const SnackBar(
            backgroundColor: Colors.black,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 5),
                Text("Sign-In Successful!")
              ],
            )),
      );

      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext newContext) => const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "";
      if (e.code == 'invalid-credential') {
        message = "Email or password was incorrect.";
      } else {
        message = "An unknown error occurred.";
      }

      messenger.showSnackBar(
        SnackBar(
            backgroundColor: Colors.black,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 5),
                Text(message)
              ],
            )),
      );
    }
  }
}
