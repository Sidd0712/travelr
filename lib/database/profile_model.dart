import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  String uid;
  String name;
  int phoneNumber;
  String preference;
  GeoPoint start;
  GeoPoint end;

  Profile({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.preference,
    required this.start,
    required this.end,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'phoneNumber': phoneNumber,
        'preference': preference,
        'start': start,
        'end': end,
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        uid: json['uid'],
        name: json['name'],
        phoneNumber: json['phoneNumber'],
        preference: json['preference'],
        start: json['start'],
        end: json['end'],
      );
}
