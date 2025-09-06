import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'senderID': senderID,
        'message': message,
        'timestamp': timestamp,
      };

  factory Message.fromMap(Map<String, dynamic> data) => Message(
        senderID: data['senderID'] ?? '',
        message: data['message'] ?? '',
        timestamp: data['timestamp'] ?? Timestamp.now(),
      );
}
