import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travelr/database/profile_service.dart';
import 'package:travelr/google_api/address_autocomplete.dart';
import 'package:travelr/database/profile_model.dart';

class UpdateProfileScreen extends StatefulWidget {
  final Profile user;

  const UpdateProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _startingLocationController;
  late TextEditingController _endingLocationController;

  String? _selectedGender;
  String? _selectedGenderPreference;

  GeoPoint? startingGeoPoint;
  GeoPoint? endingGeoPoint;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.user.name);
    _phoneController =
        TextEditingController(text: widget.user.phoneNumber.toString());
    _startingLocationController = TextEditingController();
    _endingLocationController = TextEditingController();

    _selectedGender = widget.user.gender;
    _selectedGenderPreference = widget.user.preference;

    startingGeoPoint = widget.user.start;
    endingGeoPoint = widget.user.end;
  }

  void _updateProfile() {
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

    final updatedProfile = Profile(
      uid: widget.user.uid,
      name: _nameController.text.trim(),
      gender: _selectedGender!,
      phoneNumber: int.parse(_phoneController.text.trim()),
      preference: _selectedGenderPreference!,
      start: startingGeoPoint!,
      end: endingGeoPoint!,
      friends: widget.user.friends,
      friendRequests: widget.user.friendRequests,
      friendRequested: widget.user.friendRequested,
    );

    ProfilesDatabase.updateProfile(updatedProfile);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Edit Successful!")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Profile"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Update Profile",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                onPressed: _updateProfile,
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Save Changes",
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

  Widget genderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Gender",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        RadioGroup<String>(
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() => _selectedGender = value);
          },
          child: Column(
            children: ["Male", "Female"].map((gender) {
              return RadioListTile<String>(
                title: Text(gender),
                value: gender,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget genderPreferenceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Companion Gender Preference",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        RadioGroup<String>(
          groupValue: _selectedGenderPreference,
          onChanged: (value) {
            setState(() => _selectedGenderPreference = value);
          },
          child: Column(
            children: ["Male", "Female", "Both"].map((gender) {
              return RadioListTile<String>(
                title: Text(gender),
                value: gender,
              );
            }).toList(),
          ),
        ),
      ],
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
