import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelr/database/chat_model.dart';
import 'package:travelr/database/message_model.dart';

class ChatService {
  static Future<String> createChat(
      String groupName, List<String> members) async {
    try {
      final chatRoomRef = FirebaseFirestore.instance.collection('chats').doc();

      await chatRoomRef.set({
        'roomID': chatRoomRef.id,
        'groupName': groupName,
        'members': members,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      return chatRoomRef.id;
    } on Exception catch (e) {
      print("Error creating chat: $e");
      return "";
    }
  }

  static Future<void> sendMessage(String roomID, String message) async {
    try {
      final String currentUserID = FirebaseAuth.instance.currentUser!.uid;

      final chatDoc = await FirebaseFirestore.instance
          .collection("chats")
          .doc(roomID)
          .get();
      if (!chatDoc.exists) throw Exception("Chat does not exist");

      final members = List<String>.from(chatDoc.data()?['members'] ?? []);
      if (!members.contains(currentUserID)) {
        throw Exception("User is not a member of this chat");
      }

      final Timestamp timestamp = Timestamp.now();

      Message newMsg = Message(
        senderID: currentUserID,
        message: message,
        timestamp: timestamp,
      );

      final chatRef =
          FirebaseFirestore.instance.collection("chats").doc(roomID);
      final msgRef = chatRef.collection("messages").doc();

      final batch = FirebaseFirestore.instance.batch();

      batch.set(msgRef, newMsg.toMap());
      batch.update(chatRef, {
        'lastMessage': message,
        'lastMessageTime': timestamp,
      });

      await batch.commit();
    } on Exception catch (e) {
      print("Error sending message: $e");
    }
  }

  static Stream<List<Message>> getMessages(String roomID) {
    try {
      return FirebaseFirestore.instance
          .collection("chats")
          .doc(roomID)
          .collection("messages")
          .orderBy("timestamp", descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Message.fromMap(doc.data());
        }).toList();
      });
    } on Exception catch (e) {
      print("Error getting messages: $e");
      return const Stream.empty();
    }
  }

  static Stream<List<ChatRoom>> getChats() {
    try {
      String currentUserID = FirebaseAuth.instance.currentUser!.uid;
      return FirebaseFirestore.instance
          .collection("chats")
          .where("members", arrayContains: currentUserID)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return ChatRoom.fromMap(doc.data());
        }).toList();
      });
    } on Exception catch (e) {
      print("Error getting chats: $e");
      return const Stream.empty();
    }
  }

  static Future<Map<String, String>> getMemberProfiles(String roomId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(roomId)
          .get();
      if (!doc.exists) return {};

      final data = doc.data();
      if (data == null || !data.containsKey('members')) return {};

      final List<String> memberUIDs = List<String>.from(data['members']);

      final futures = memberUIDs.map((uid) {
        return FirebaseFirestore.instance.collection("users").doc(uid).get();
      }).toList();

      final results = await Future.wait(futures);

      Map<String, String> profiles = {};
      for (var userDoc in results) {
        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null && userData.containsKey("name")) {
            profiles[userDoc.id] = userData["name"];
          }
        }
      }

      return profiles;
    } catch (e) {
      print("Error getting member profiles: $e");
      return {};
    }
  }

  static Future<String?> getChatGroupName(String roomID) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(roomID)
          .get();

      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      return data['groupName'] as String?;
    } catch (e) {
      print("Error getting chat group name: $e");
      return null;
    }
  }
}
