import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../models/user.dart' as AppUser;
import '../models/lost_item.dart';
import '../models/group_message.dart';
import '../models/anon_message.dart';
import '../models/announcement.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signUp(String email, String password, String name) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _firestore.collection('users').doc(cred.user!.uid).set(
        AppUser.User(uid: cred.user!.uid, name: name, email: email).toFirestore(),
      );
      return cred;
    } catch (e) {
      print('Signup error: $e');
      return null;
    }
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Signin error: $e');
      return null;
    }
  }

  Future<void> signOut() => _auth.signOut();

  // Users
  Future<AppUser.User?> getUser(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? AppUser.User.fromFirestore(doc.data() as Map<String, dynamic>) : null;
  }

  // Lost Items
  Future<void> postLostItem(LostItem item, XFile imageFile) async {
    try {
      // Upload image
      final ref = _storage.ref().child('lost_items/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final bytes = await imageFile.readAsBytes();
      await ref.putData(bytes);
      final imageUrl = await ref.getDownloadURL();

      // Save to Firestore
      final newItem = LostItem(
        itemId: '',
        title: item.title,
        description: item.description,
        location: item.location,
        imageUrl: imageUrl,
        postedBy: item.postedBy,
        timestamp: Timestamp.now(),
      );
      await _firestore.collection('lost_items').add(newItem.toFirestore());
    } catch (e) {
      print('Post lost item error: $e');
    }
  }

  Stream<List<LostItem>> get lostItemsStream => _firestore.collection('lost_items')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => LostItem.fromFirestore(doc)).toList());

  // Group Chat
  Stream<List<GroupMessage>> get groupChatStream => _firestore.collection('group_chat')
      .orderBy('timestamp', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => GroupMessage.fromFirestore(doc)).toList());

  Future<void> sendGroupMessage(String text) async {
    if (_auth.currentUser == null) return;
    final user = await getUser(_auth.currentUser!.uid);
    await _firestore.collection('group_chat').add(GroupMessage(
      messageId: '',
      text: text,
      senderId: _auth.currentUser!.uid,
      senderName: user?.name ?? 'Anonymous',
      timestamp: Timestamp.now(),
    ).toFirestore());
  }

  // Anonymous Chat
  Stream<List<AnonMessage>> get anonChatStream => _firestore.collection('anonymous_chat')
      .orderBy('timestamp', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => AnonMessage.fromFirestore(doc)).toList());

  Future<void> sendAnonMessage(String text) async {
    await _firestore.collection('anonymous_chat').add(AnonMessage(
      messageId: '',
      text: text,
      timestamp: Timestamp.now(),
    ).toFirestore());
  }

  // Announcements (Admin)
  Future<bool> isAdmin() async {
    if (_auth.currentUser == null) return false;
    final userDoc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    return userDoc.data()?['isAdmin'] ?? false;
  }

  Future<void> postAnnouncement(Announcement ann, PlatformFile? file) async {
    String? fileUrl;
    if (file != null) {
      final extension = p.extension(file.name);
      final ref = _storage.ref().child('announcements/${DateTime.now().millisecondsSinceEpoch}$extension');
      await ref.putData(file.bytes!);
      fileUrl = await ref.getDownloadURL();
    }
    await _firestore.collection('announcements').add({
      ...ann.toFirestore(),
      'fileUrl': fileUrl,
      'fileType': file?.extension ?? '',
    });
  }

  Stream<List<Announcement>> get announcementsStream => _firestore.collection('announcements')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Announcement.fromFirestore(doc)).toList());
}

