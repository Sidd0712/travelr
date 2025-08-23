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

  static Stream<List<Profile>> getProfiles() {
    return usersCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Profile.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  static Future<void> updateProfile(Profile user) async {
    try {
      await usersCollection.doc(user.uid).update(user.toJson());
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
}
