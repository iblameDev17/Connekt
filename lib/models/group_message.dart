import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessage {
  final String messageId;
  final String text;
  final String senderId;
  final String senderName;
  final Timestamp timestamp;

  GroupMessage({
    required this.messageId,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  factory GroupMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupMessage(
      messageId: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': timestamp,
    };
  }
}
