# Firebase Backend Integration for Connekt (Flutter)

## Approved Plan Progress Tracker (User confirmed Flutter impl)

**Overall Status: Setup Phase**

### Phase 1: Firebase Dependencies & Init (Current)
- [ ] 1. Add Firebase plugins to pubspec.yaml
- [ ] 2. Run `flutter pub get`
- [ ] 3. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
- [ ] 4. User runs: `flutterfire configure` (select/create Firebase project 'connekt-[random]', download google-services.json & firebase_options.dart)
- [ ] 5. Commit firebase_options.dart to lib/

### Phase 2: Core Services & Models
- [ ] 6. Create lib/services/firebase_service.dart (auth, firestore utils)
- [ ] 7. Create lib/models/user.dart, lost_item.dart, group_message.dart, anon_message.dart, announcement.dart

### Phase 3: Authentication
- [ ] 8. Update lib/screens/auth/signup_screen.dart (Firebase signup + users doc)
- [ ] 9. Update lib/screens/auth/login_screen.dart (Firebase login)
- [ ] 10. Update lib/main.dart (Firebase.initializeApp + auth state routing)

### Phase 4: Lost & Found
- [ ] 11. Update lib/screens/lost_found/post_lost_item_screen.dart (image_picker + Storage + Firestore)
- [ ] 12. Update lib/screens/lost_found/lost_found_tab.dart (StreamBuilder list)

### Phase 5: Group Chat
- [ ] 13. Create global 'group_chat' collection
- [ ] 14. Update lib/screens/chat/chat_tab.dart & chat_detail_screen.dart (single global StreamBuilder, send)

### Phase 6: Anonymous Chat (ghost/ → anonymous)
- [ ] 15. Create 'anonymous_chat' collection (NO sender)
- [ ] 16. Update lib/screens/ghost/ghost_tab.dart (StreamBuilder anon messages)

### Phase 7: Announcements (Admin, notes/ → admin)
- [ ] 17. Manual: Add isAdmin: true to your UID in Firebase Console users/
- [ ] 18. Update lib/screens/notes/upload_note_screen.dart → Admin post (file_picker Storage + Firestore)
- [ ] 19. Create lib/screens/announcements_tab.dart (list + download)

### Phase 8: Security & Test
- [ ] 20. Set Firestore rules (copy from plan)
- [ ] 21. `flutter run` + end-to-end test all features
- [ ] 22. attempt_completion

**Next Action: Complete Phase 1 → Reply 'Phase 1 done' after step 5.**
