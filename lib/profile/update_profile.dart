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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Update Profile",
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
                onPressed: _updateProfile,
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Save Changes",
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
        RadioGroup<String>(
          groupValue: _selectedGender,
          onChanged: (value) {
            setState(() => _selectedGender = value);
          },
          child: Column(
            children: ["Male", "Female"].map((gender) {
              return RadioListTile<String>(
                title: Text(gender, style: textTheme.bodyLarge),
                value: gender,
                activeColor: colorScheme.primary,
              );
            }).toList(),
          ),
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
          "Companion Gender Preference",
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        RadioGroup<String>(
          groupValue: _selectedGenderPreference,
          onChanged: (value) {
            setState(() => _selectedGenderPreference = value);
          },
          child: Column(
            children: ["Male", "Female", "Both"].map((gender) {
              return RadioListTile<String>(
                title: Text(gender, style: textTheme.bodyLarge),
                value: gender,
                activeColor: colorScheme.primary,
              );
            }).toList(),
          ),
        ),
      ],
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
