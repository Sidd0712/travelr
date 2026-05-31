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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
    ));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              "travelr",
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
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
            const EdgeInsets.only(left: 32, right: 32, top: 16, bottom: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Profile",
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              nameField(),
              const SizedBox(height: 8),
              phoneField(),
              const SizedBox(height: 8),
              locationField(_startingLocationController, "Starting Location"),
              const SizedBox(height: 8),
              locationField(_endingLocationController, "Ending Location"),
              const SizedBox(height: 16),
              genderField(),
              const SizedBox(height: 16),
              genderPreferenceField(),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _signUp,
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Sign-Up",
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Gender",
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        Column(
          children: ["Male", "Female"].map((gender) {
            return RadioListTile<String>(
              title: Text(
                gender,
                style: textTheme.bodyLarge,
              ),
              value: gender,
              groupValue: _selectedGender,
              activeColor: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Companion Gender Preference",
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        Column(
          children: ["Male", "Female", "Both"].map((gender) {
            return RadioListTile<String>(
              title: Text(
                gender,
                style: textTheme.bodyLarge,
              ),
              value: gender,
              groupValue: _selectedGenderPreference,
              activeColor: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 10,
      cursorColor: colorScheme.primary,
      decoration: InputDecoration(
        hintText: "Phone Number",
        counterText: "",
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            "+91",
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 32),
      ),
    );
  }

  TextFormField nameField() {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: _nameController,
      cursorColor: colorScheme.primary,
      decoration: const InputDecoration(
        hintText: "Name",
      ),
    );
  }
}
