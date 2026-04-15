import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/avatar_helper.dart';
import '../../services/firebase_service.dart';
import '../../models/group_message.dart';
import 'GlobalGroupChatScreen.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    final date = timestamp;
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${date.hour}:${date.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Group Chat', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: const Icon(Icons.group_add, color: AppTheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search messages...',
                        prefixIcon: Icon(Icons.search_rounded),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<GroupMessage>>(
                stream: FirebaseService().groupChatStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final messages = snapshot.data ?? [];
                  if (messages.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No messages yet'),
                          Text('Messages appear here'),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: messages.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: avatarColor(msg.senderName),
                          child: Text(initials(msg.senderName)),
                        ),
                        title: Text(msg.senderName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(msg.text, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Text(_formatTime(msg.timestamp), style: TextStyle(color: Colors.grey, fontSize: 12)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlobalGroupChatScreen())),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}

