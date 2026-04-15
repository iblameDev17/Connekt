import 'package:cloud_firestore/cloud_firestore.dart';

class AnonMessage {
  final String messageId;
  final String text;
  final Timestamp timestamp;

  AnonMessage({
    required this.messageId,
    required this.text,
    required this.timestamp,
  });

  factory AnonMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnonMessage(
      messageId: doc.id,
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'timestamp': timestamp,
    };
  }
}
