import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  String uid;
  String name;
  String gender;
  int phoneNumber;
  String preference;
  GeoPoint start;
  GeoPoint end;
  List<String> friends;
  List<String> friendRequests;
  List<String> friendRequested;

  Profile({
    required this.uid,
    required this.name,
    required this.gender,
    required this.phoneNumber,
    required this.preference,
    required this.start,
    required this.end,
    required this.friends,
    required this.friendRequests,
    required this.friendRequested,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'gender': gender,
        'phoneNumber': phoneNumber,
        'preference': preference,
        'start': start,
        'end': end,
        'friends': friends,
        'friendRequests': friendRequests,
        'friendRequested': friendRequested
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        uid: json['uid'],
        name: json['name'],
        gender: json['gender'],
        phoneNumber: json['phoneNumber'],
        preference: json['preference'],
        start: json['start'],
        end: json['end'],
        friends: (json['friends'] as List<dynamic>)
            .map((e) => e.toString())
            .toList(),
        friendRequests: (json['friendRequests'] as List<dynamic>)
            .map((e) => e.toString())
            .toList(),
        friendRequested: (json['friendRequested'] as List<dynamic>)
            .map((e) => e.toString())
            .toList(),
      );
}
