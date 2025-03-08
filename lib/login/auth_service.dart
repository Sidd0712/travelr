import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelr/home/home_screen.dart';

class AuthService {
  Future<void> signUp(
      {required String email,
      required String password,
      required BuildContext context}) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
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
          builder: (BuildContext newContext) => HomeScreen(userName: email),
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
          builder: (BuildContext newContext) => HomeScreen(userName: email),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "";
      if (e.code == 'user-not-found') {
        message = "No user found for this email.";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect Password.";
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
    }
  }
}
