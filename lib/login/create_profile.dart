import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen(
      {super.key, required this.email, required this.password});
  final String email;
  final String password;

  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _startingLocationController =
      TextEditingController();
  final TextEditingController _endingLocationController =
      TextEditingController();
  String? _selectedGender;
  String? _selectedGenderPreference;

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
        leading: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: 38,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create Profile",
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  cursorColor: Colors.black,
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: "Nickname",
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
                ),
                const SizedBox(height: 10),
                TextFormField(
                  cursorColor: Colors.black,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: "Phone Number",
                    //prefixText: "+91 ", // Adds the +91 prefix
                    prefix: Text("+91 "),
                    contentPadding: EdgeInsets.all(15),
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ]),
        ),
      ),
    );
  }
}
