import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_model.dart';

class ProfilesDatabase {
  static final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  static Future<void> addProfile(Profile user) async {
    try {
      await usersCollection.doc(user.uid).set(user.toJson());
      print("Profile added successfully!");
    } catch (e) {
      print("Error adding user: $e");
    }
  }

  static Stream<Map<String, String>> getProfilesPartial() {
    return usersCollection.snapshots().map((snapshot) {
      final Map<String, String> partialProfiles = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final uid = data['uid'] as String;
        final name = data['name'] as String;
        partialProfiles[uid] = name;
      }
      return partialProfiles;
    });
  }

  static Future<Profile?> getProfileFromUID(String uid) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return Profile.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        print("Profile not found for UID: $uid");
        return null;
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

  static Future<Map<String, String>> getProfilePartialFromUID(
      String uid) async {
    try {
      final doc = await usersCollection.doc(uid).get();
      if (!doc.exists || doc.data() == null) return {};

      final data = doc.data() as Map<String, dynamic>;
      final name = data['name'] as String;

      return {uid: name};
    } catch (e) {
      print("Error fetching partial profile: $e");
      return {};
    }
  }

  static Future<void> updateProfile(Profile user) async {
    try {
      await usersCollection.doc(user.uid).update(user.toJson());
      final CollectionReference userFormCollection =
          FirebaseFirestore.instance.collection('userForms');
      Map<String, dynamic> convertedJson = convert(user);
      await userFormCollection.doc(user.uid).update(convertedJson);
      print("Profile updated successfully!");
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  static Future<void> deleteProfile(String uid) async {
    try {
      await usersCollection.doc(uid).delete();
      print("Profile deleted successfully!");
    } catch (e) {
      print("Error deleting user: $e");
    }
  }

  static Future<void> sendFriendRequest(String fromUID, String toUID) async {
    try {
      await usersCollection.doc(toUID).update({
        'friendRequests': FieldValue.arrayUnion([fromUID])
      });
    } catch (e) {
      print("Error sending friend request: $e");
    }
    try {
      await usersCollection.doc(fromUID).update({
        'friendRequested': FieldValue.arrayUnion([toUID])
      });

      print("Friend request sent from $fromUID to $toUID");
    } catch (e) {
      print("Error sending friend request: $e");
    }
  }

  static Future<void> acceptFriendRequest(
      String currentUID, String fromUID) async {
    try {
      await usersCollection.doc(currentUID).update({
        'friendRequests': FieldValue.arrayRemove([fromUID]),
        'friends': FieldValue.arrayUnion([fromUID])
      });

      await usersCollection.doc(fromUID).update({
        'friendRequested': FieldValue.arrayRemove([currentUID]),
        'friends': FieldValue.arrayUnion([currentUID])
      });

      print("$currentUID accepted friend request from $fromUID");
    } catch (e) {
      print("Error accepting friend request: $e");
    }
  }

  static Future<void> rejectFriendRequest(
      String currentUID, String fromUID) async {
    try {
      await usersCollection.doc(currentUID).update({
        'friendRequests': FieldValue.arrayRemove([fromUID])
      });

      await usersCollection.doc(fromUID).update({
        'friendRequested': FieldValue.arrayRemove([currentUID])
      });

      print("$currentUID rejected friend request from $fromUID");
    } catch (e) {
      print("Error rejecting friend request: $e");
    }
  }

  static convert(Profile data) {
    return {
      "age": 20,
      "arrivalTime": "08:00 AM",
      "name": data.name,
      "number": data.phoneNumber,
      "gender": data.gender,
      "genderPreference": data.preference,
      "location1": data.start,
      "location2": data.end,
      "submittedAt": FieldValue.serverTimestamp(),
      "transportType": "Private",
    };
  }
}
