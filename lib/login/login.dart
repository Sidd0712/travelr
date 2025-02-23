import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _isSignUp = false;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggleSignUp() {
    setState(() {
      _isSignUp = !_isSignUp; // Toggle between Sign-In and Sign-Up
      _emailController.text = "";
      _passwordController.text = "";
      _confirmPasswordController.text = "";
    });
  }

  void _signIn() {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.black,
              content: Center(
                  child: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 5),
                  Text("Please enter the correct credentials!!")
                ],
              ))),
        );
        return;
      }

      print("Email: $email, Password: $password");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.black,
            content: Center(
                child: Row(
              children: [
                const Icon(Icons.info, color: Colors.white),
                const SizedBox(width: 5),
                Text("${_isSignUp ? 'Sign-Up' : 'Sign-In'} Successful!")
              ],
            ))),
      );
    }
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
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _labelText(),
                const SizedBox(height: 10),
                _emailField(),
                const SizedBox(height: 10),
                _passwordField(),
                _confirmPasswordField(),
                const SizedBox(height: 8),
                _btnConfirm(),
                Row(
                  children: [
                    Text(
                      _isSignUp
                          ? "Already have an account?"
                          : "Don't have an account?",
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    _toggleBtn()
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextButton _toggleBtn() {
    return TextButton(
      onPressed: _toggleSignUp,
      style: const ButtonStyle(
          overlayColor: MaterialStatePropertyAll(Colors.transparent),
          padding: MaterialStatePropertyAll(EdgeInsets.fromLTRB(5, 0, 0, 0))),
      child: Text(
        _isSignUp ? "Sign-In" : "Sign-Up",
        style: const TextStyle(
            color: Colors.blue,
            //fontWeight: FontWeight.bold,
            fontSize: 16),
      ),
    );
  }

  TextButton _btnConfirm() {
    return TextButton(
      onPressed: _signIn,
      style: const ButtonStyle(
        fixedSize: MaterialStatePropertyAll(Size(double.infinity, 50)),
        padding: MaterialStatePropertyAll(EdgeInsets.zero),
        backgroundColor: MaterialStatePropertyAll(Colors.blue),
        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)))),
      ),
      child: Center(
        child: Text(
          _isSignUp ? "Sign-Up" : "Sign-In",
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  AnimatedContainer _confirmPasswordField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isSignUp ? 65 : 0,
      curve: Curves.easeInOut,
      child: _isSignUp
          ? Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextFormField(
                cursorColor: Colors.black,
                controller: _confirmPasswordController,
                obscureText: _obscureText,
                decoration: const InputDecoration(
                  filled: true,
                  hintText: "Confirm Password",
                  contentPadding: EdgeInsets.all(15),
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  TextFormField _passwordField() {
    return TextFormField(
      cursorColor: Colors.black,
      controller: _passwordController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        suffixIcon: Padding(
          padding: const EdgeInsets.all(5),
          child: IconButton(
            icon:
                Icon((_obscureText ? Icons.visibility_off : Icons.visibility)),
            onPressed: _toggleVisibility,
          ),
        ),
        filled: true,
        hintText: "Password",
        contentPadding: const EdgeInsets.all(15),
        fillColor: Colors.white,
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide()),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  TextFormField _emailField() {
    return TextFormField(
      cursorColor: Colors.black,
      controller: _emailController,
      decoration: const InputDecoration(
        filled: true,
        hintText: "Email-ID",
        contentPadding: EdgeInsets.all(15),
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide()),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }

  Text _labelText() {
    return Text(
      _isSignUp ? "Sign-Up" : "Sign-In",
      style: const TextStyle(
          fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
    );
  }
}
