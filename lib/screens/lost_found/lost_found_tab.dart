import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../theme/avatar_helper.dart';
import '../../services/firebase_service.dart';
import '../../models/lost_item.dart';
import 'post_lost_item_screen.dart';
import 'item_detail_screen.dart';

class LostFoundTab extends StatefulWidget {
  const LostFoundTab({super.key});

  @override
  State<LostFoundTab> createState() => _LostFoundTabState();
}

class _LostFoundTabState extends State<LostFoundTab> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Lost', 'Found'];

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'now';
    final dateTime = timestamp as DateTime;
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  IconData _getItemIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('charger') || lowerTitle.contains('power')) {
      return Icons.power;
    } else if (lowerTitle.contains('id') || lowerTitle.contains('card')) {
      return Icons.card_membership;
    } else if (lowerTitle.contains('umbrella')) {
      return Icons.umbrella;
    } else if (lowerTitle.contains('earbuds') || lowerTitle.contains('headphones')) {
      return Icons.headset;
    } else if (lowerTitle.contains('laptop') || lowerTitle.contains('book')) {
      return Icons.laptop;
    }
    return Icons.inventory_2;
  }

  Widget _buildItemCard(BuildContext context, LostItem item) {
    final isFound = item.isFound;
    final statusColor = isFound ? Colors.green : Colors.orange;
    final statusLabel = isFound ? 'FOUND' : 'LOST';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItemDetailScreen(
              title: item.title,
              description: item.description,
              location: item.location,
              time: _formatTime(item.timestamp),
              status: statusLabel,
              statusColor: statusColor,
              imageUrl: item.imageUrl,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: item.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: item.imageUrl,
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                            placeholder: (context, url) => Container(
                              color: statusColor.withOpacity(0.3),
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              _getItemIcon(item.title),
                              size: 32,
                              color: statusColor,
                            ),
                          ),
                        )
                      : Icon(
                          _getItemIcon(item.title),
                          size: 32,
                          color: statusColor.withOpacity(0.8),
                        ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: avatarColor(item.postedBy),
                          child: Text(
                            initials(item.postedBy),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.postedBy,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(_formatTime(item.timestamp), style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                Expanded(child: TextField(decoration: InputDecoration(hintText: 'Search items', prefixIcon: Icon(Icons.search)))),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<LostItem>>(
              stream: FirebaseService().lostItemsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No items found'),
                        Text('Post the first lost item!'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) => _buildItemCard(context, items[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PostLostItemScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Post Item'),
      ),
    );
  }
}

