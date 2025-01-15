import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderUsername;
  final String receiverUsername;
  final String text;
  final Timestamp timestamp;

  Message({
    required this.senderUsername,
    required this.receiverUsername,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> data) {
    return Message(
      senderUsername: data['senderUsername'],
      receiverUsername: data['receiverUsername'],
      text: data['text'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderUsername': senderUsername,
      'receiverUsername': receiverUsername,
      'text': text,
      'timestamp': timestamp,
    };
  }
}
