/// Notifications Screen: admin announcements only.
library;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/repository.dart';
import '../services/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repo = DemoPromptRepository();
  List<NotificationItem> _items = [];
  List<Prompt> _prompts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final notifications = await _repo.getNotifications();
    final prompts = await _repo.getPrompts(limit: 50);
    if (!mounted) return;
    setState(() {
      _items = notifications;
      _prompts = prompts;
      _loading = false;
    });
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'featured':
        return Icons.star;
      case 'trending':
        return Icons.trending_up;
      case 'category':
        return Icons.category;
      default:
        return Icons.post_add;
    }
  }

  Future<void> _delete(NotificationItem item) async {
    setState(() => _items.remove(item));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await AppServices.state.markAllNotificationsRead(_items);
              setState(() {});
            },
            child: const Text('Mark All Read', style: TextStyle(fontSize: 12)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _items.clear());
            },
            child: const Text('Clear All', style: TextStyle(fontSize: 12, color: AppColors.danger)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_none,
                  title: 'No Notifications',
                  subtitle: 'New announcements will appear here.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final n = _items[i];
                    final isRead = AppServices.state.isNotificationRead(n.id);
                    return Dismissible(
                      key: Key(n.id),
                      background: Container(
                        color: AppColors.danger,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _delete(n),
                      child: Card(
                        color: isRead ? AppColors.surface : AppColors.surfaceHigh,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            child: Icon(_iconFor(n.type), color: AppColors.accent, size: 20),
                          ),
                          title: Text(n.title,
                              style: TextStyle(
                                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                          subtitle: Text(n.message,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          onTap: () async {
                            await AppServices.state.markNotificationRead(n.id);
                            if (n.relatedPromptId != null) {
                              final prompt = _prompts.where((p) => p.id == n.relatedPromptId).firstOrNull;
                              if (prompt != null && mounted) {
                                Navigator.of(context)
                                    .pushNamed('/prompt-details', arguments: prompt);
                              }
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
