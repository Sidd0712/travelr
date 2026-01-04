import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travelr/google_api/address_autocomplete.dart';
import 'package:travelr/login/auth_service.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({
    super.key,
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _startingLocationController =
      TextEditingController();
  final TextEditingController _endingLocationController =
      TextEditingController();

  String? _selectedGender;
  String? _selectedGenderPreference;

  GeoPoint? startingGeoPoint;
  GeoPoint? endingGeoPoint;

  Future<void> _signUp() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.length != 10 ||
        startingGeoPoint == null ||
        endingGeoPoint == null ||
        _selectedGender == null ||
        _selectedGenderPreference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields correctly")),
      );
      return;
    }

    await AuthService().signUp(
      data: toMap(),
      context: context,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'startingLocation': startingGeoPoint,
      'endingLocation': endingGeoPoint,
      'gender': _selectedGender,
      'genderPreference': _selectedGenderPreference,
      'email': widget.email,
      'password': widget.password,
    };
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            SizedBox(height: 20),
            Text(
              "travelr",
              style: TextStyle(
                fontFamily: "Northlane",
                fontSize: 38,
                color: Colors.black,
              ),
            ),
          ],
        ),
        forceMaterialTransparency: true,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            iconSize: 38,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create Profile",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              nameField(),
              const SizedBox(height: 10),
              phoneField(),
              const SizedBox(height: 10),
              locationField(_startingLocationController, "Starting Location"),
              const SizedBox(height: 10),
              locationField(_endingLocationController, "Ending Location"),
              const SizedBox(height: 10),
              genderField(),
              const SizedBox(height: 10),
              genderPreferenceField(),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _signUp,
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Sign-Up",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget genderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Gender",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Column(
          children: ["Male", "Female"].map((gender) {
            return RadioListTile<String>(
              title: Text(
                gender,
                style: TextStyle(fontSize: 16), // Keep text size consistent
              ),
              value: gender,
              groupValue: _selectedGender,
              activeColor: Colors.blue,
              dense: true,
              visualDensity: VisualDensity.compact,
              onChanged: (value) {
                setState(() => _selectedGender = value);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget genderPreferenceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Companion Gender Preference",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Column(
          children: ["Male", "Female", "Both"].map((gender) {
            return RadioListTile<String>(
              title: Text(
                gender,
                style: TextStyle(fontSize: 16),
              ),
              value: gender,
              groupValue: _selectedGenderPreference,
              activeColor: Colors.blue,
              dense: true,
              visualDensity: VisualDensity.compact,
              onChanged: (value) {
                setState(() => _selectedGenderPreference = value);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget locationField(TextEditingController controller, String hintText) {
    return AddressAutocomplete(
      controller: controller,
      hintText: hintText,
      onLocationSelected: (locationData) {
        GeoPoint geoPoint = GeoPoint(locationData["lat"], locationData["lng"]);
        setState(() {
          if (controller == _startingLocationController) {
            startingGeoPoint = geoPoint;
          } else {
            endingGeoPoint = geoPoint;
          }
        });
      },
    );
  }

  TextFormField phoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 10,
      decoration: const InputDecoration(
        filled: true,
        hintText: "Phone Number",
        counterText: "",
        contentPadding: EdgeInsets.all(15),
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 15),
          child: Text(
            "+91",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 30),
      ),
    );
  }

  TextFormField nameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        filled: true,
        hintText: "Name",
        contentPadding: EdgeInsets.all(15),
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}
