import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String roomID;
  final String groupName;
  final List<String> members;
  final String lastMessage;
  final Timestamp lastMessageTime;

  ChatRoom({
    required this.roomID,
    required this.groupName,
    required this.members,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> data) {
    return ChatRoom(
      roomID: data['roomID'] ?? '',
      groupName: data['groupName'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: data['lastMessageTime'] ?? Timestamp.now(),
    );
  }
}
