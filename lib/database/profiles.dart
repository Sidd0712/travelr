import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_model.dart';

class ProfilesDatabase {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> addProfile(Profile user) async {
    try {
      await usersCollection.doc(user.uid).set(user.toJson());
      print("Profile added successfully!");
    } catch (e) {
      print("Error adding user: $e");
    }
  }

  Stream<List<Profile>> getProfiles() {
    return usersCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Profile.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> updateProfile(Profile user) async {
    try {
      await usersCollection.doc(user.uid).update(user.toJson());
      print("Profile updated successfully!");
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  Future<void> deleteProfile(String uid) async {
    try {
      await usersCollection.doc(uid).delete();
      print("Profile deleted successfully!");
    } catch (e) {
      print("Error deleting user: $e");
    }
  }
}
