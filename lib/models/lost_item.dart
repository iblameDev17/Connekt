import 'package:cloud_firestore/cloud_firestore.dart';

class LostItem {
  final String itemId;
  final String title;
  final String description;
  final String location;
  final String imageUrl;
  final String postedBy;
  final bool isFound;
  final Timestamp timestamp;

  LostItem({
    required this.itemId,
    required this.title,
    required this.description,
    required this.location,
    required this.imageUrl,
    required this.postedBy,
    this.isFound = false,
    required this.timestamp,
  });

  factory LostItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LostItem(
      itemId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      postedBy: data['postedBy'] ?? '',
      isFound: data['isFound'] ?? false,
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'imageUrl': imageUrl,
      'postedBy': postedBy,
      'isFound': isFound,
      'timestamp': timestamp,
    };
  }
}
