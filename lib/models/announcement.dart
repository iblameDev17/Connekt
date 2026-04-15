import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String announcementId;
  final String title;
  final String content;
  final String? fileUrl;
  final String fileType;
  final Timestamp timestamp;

  Announcement({
    required this.announcementId,
    required this.title,
    required this.content,
    this.fileUrl,
    required this.fileType,
    required this.timestamp,
  });

  factory Announcement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Announcement(
      announcementId: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      fileUrl: data['fileUrl'],
      fileType: data['fileType'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'timestamp': timestamp,
    };
  }
}
