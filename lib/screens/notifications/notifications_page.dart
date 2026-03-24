import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/models/workout_post.dart';
import 'package:powerank/screens/comments/comments_page.dart';
import 'package:powerank/screens/messages/chat_page.dart';
import 'package:powerank/screens/social/followers_page.dart';
import 'package:powerank/services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();

  Future<void> _markAllAsRead() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    await _notificationService.markAllAsRead(currentUser.uid);
  }

  Future<WorkoutPost?> _loadWorkout(String workoutId) async {
    final workoutDoc = await FirebaseFirestore.instance
        .collection('workouts')
        .doc(workoutId)
        .get();

    if (!workoutDoc.exists) return null;

    final data = workoutDoc.data();
    if (data == null) return null;

    final post = WorkoutPost.fromFirestore(workoutDoc.id, data);

    final ownerDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(data['userId'])
        .get();

    post.user = (ownerDoc.data()?['username'] ?? 'Utilizador').toString();
    return post;
  }

  Future<void> _handleTap(
    String notificationId,
    Map<String, dynamic> data,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await _notificationService.markAsRead(
      userId: currentUser.uid,
      notificationId: notificationId,
    );

    final type = (data['type'] ?? '').toString();

    if (type == 'follow_request') {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const FollowersPage(initialTabIndex: 1),
        ),
      );
      return;
    }

    if (type == 'message') {
      final chatId = (data['chatId'] ?? '').toString();
      final otherUid = (data['otherUid'] ?? '').toString();
      final otherUsername =
          (data['otherUsername'] ?? data['senderUsername'] ?? 'Utilizador')
              .toString();

      if (chatId.isEmpty || otherUid.isEmpty || !mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            chatId: chatId,
            otherUid: otherUid,
            otherUsername: otherUsername,
          ),
        ),
      );
      return;
    }

    if (type == 'mention' && (data['sourceType'] ?? '') == 'comment') {
      final workoutId = (data['workoutId'] ?? '').toString();
      if (workoutId.isEmpty) return;

      final post = await _loadWorkout(workoutId);

      if (!mounted) return;

      if (post == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O treino desta notificacao ja nao existe.'),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommentsPage(post: post),
        ),
      );
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'follow_request':
        return Icons.person_add_alt_1;
      case 'message':
        return Icons.message;
      case 'mention':
        return Icons.alternate_email;
      default:
        return Icons.notifications_none;
    }
  }

  Color _iconColorForType(String type) {
    switch (type) {
      case 'follow_request':
        return Colors.lightBlueAccent;
      case 'message':
        return Colors.greenAccent;
      case 'mention':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Agora';

    final date = timestamp.toDate();
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inHours < 1) return 'Ha ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Ha ${diff.inHours} h';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = textColor.withOpacity(0.7);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notificacoes'),
        ),
        body: const Center(
          child: Text('Faz login para ver as notificacoes.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notificacoes'),
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all),
            tooltip: 'Marcar tudo como lido',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar notificacoes.',
                style: TextStyle(color: mutedColor),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!.docs;

          if (notifications.isEmpty) {
            return Center(
              child: Text(
                'Ainda nao tens notificacoes.',
                style: TextStyle(color: mutedColor),
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;
              final type = (data['type'] ?? '').toString();
              final isRead = data['isRead'] == true;
              final createdAt = data['createdAt'] is Timestamp
                  ? data['createdAt'] as Timestamp
                  : null;

              return Card(
                color: isRead
                    ? theme.cardColor
                    : theme.colorScheme.primary.withOpacity(0.12),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  onTap: () => _handleTap(doc.id, data),
                  leading: CircleAvatar(
                    backgroundColor: theme.brightness == Brightness.dark
                        ? Colors.white10
                        : Colors.black12,
                    child: Icon(
                      _iconForType(type),
                      color: _iconColorForType(type),
                    ),
                  ),
                  title: Text(
                    (data['title'] ?? 'Notificacao').toString(),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (data['body'] ?? '').toString(),
                          style: TextStyle(color: mutedColor),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatTimestamp(createdAt),
                          style: TextStyle(
                            color: isRead
                                ? mutedColor
                                : const Color(0xFF7DD3FC),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: isRead
                      ? null
                      : Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF7DD3FC),
                            shape: BoxShape.circle,
                          ),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
