import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelr/chat/chat_page.dart';
import 'package:travelr/database/profile_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String getOtherUserId({
    required String roomId,
    required String currentUserId,
  }) {
    // dm_uid1_uid2
    final parts = roomId.split('_');

    if (parts.length != 3) {
      throw Exception("Invalid roomId format: $roomId");
    }

    final uid1 = parts[1];
    final uid2 = parts[2];

    return uid1 == currentUserId ? uid2 : uid1;
  }

  Future<String> getChatDisplayName({
    required String roomId,
    required String currentUserId,
  }) async {
    final otherUid = getOtherUserId(
      roomId: roomId,
      currentUserId: currentUserId,
    );

    final profile = await ProfilesDatabase.getProfilePartialFromUID(otherUid);
    return profile["name"] ?? "Unknown User";
  }

  @override
  Widget build(BuildContext context) {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('members', arrayContains: currentUserID)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No groups available.'));
        } else {
          final groups = snapshot.data!.docs;

          //Random Insane Big-Brain Calcs Here

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index].data();
              final roomId = groups[index].id;
              final groupName = group['groupName'] ?? "Unnamed Group";
              final lastMessage = group['lastMessage'] ?? "Start a chat...";
              final Timestamp? ts = group['lastMessageTime'];
              final String lastMessageTime = ts != null
                  ? ts
                      .toDate()
                      .toLocal()
                      .toString()
                      .split(' ')[1]
                      .substring(0, 5)
                  : "";

              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: ListTile(
                  title: Text(
                    groupName,
                    style: const TextStyle(fontSize: 20),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(lastMessageTime),
                    ],
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade700,
                    child: Icon(Icons.group, color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          roomID: roomId,
                          groupName: groupName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}
