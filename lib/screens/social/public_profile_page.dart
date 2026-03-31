import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/screens/social/user_connections_page.dart';
import 'package:powerank/services/firestore_service.dart';
import 'package:powerank/services/notification_service.dart';
import 'package:powerank/widgets/progress_area_chart.dart';

class PublicProfilePage extends StatelessWidget {
  final String userId;

  const PublicProfilePage({
    super.key,
    required this.userId,
  });

  String _performanceLabel(List<Map<String, dynamic>> progress) {
    if (progress.length < 2) return 'A começar';
    final first = (progress.first['weight'] ?? 0).toDouble();
    final last = (progress.last['weight'] ?? 0).toDouble();

    if (last > first * 1.1) return 'Indo bem';
    if (last >= first * 0.95) return 'Mais ou menos';
    return 'Indo mal';
  }

  Future<void> _toggleFollow(BuildContext context, String targetUid) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.uid == targetUid) return;

    final currentDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final currentUsername =
        (currentDoc.data()?['username'] ?? 'Utilizador').toString();

    final targetDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(targetUid)
        .get();
    final targetData = targetDoc.data() ?? {};
    final isPrivate = targetData['isPrivate'] == true;

    final myFollowing = List<String>.from(currentDoc.data()?['following'] ?? []);
    final alreadyFollowing = myFollowing.contains(targetUid);

    if (alreadyFollowing) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'following': FieldValue.arrayRemove([targetUid])});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUid)
          .update({'followers': FieldValue.arrayRemove([currentUser.uid])});
      return;
    }

    if (isPrivate) {
      final existing = await FirebaseFirestore.instance
          .collection('followRequests')
          .where('fromId', isEqualTo: currentUser.uid)
          .where('toId', isEqualTo: targetUid)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existing.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('followRequests').add({
          'fromId': currentUser.uid,
          'fromUsername': currentUsername,
          'toId': targetUid,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        await NotificationService().sendFollowRequestNotification(
          targetUserId: targetUid,
          senderId: currentUser.uid,
          senderUsername: currentUsername,
        );
      }
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({'following': FieldValue.arrayUnion([targetUid])});
    await FirebaseFirestore.instance
        .collection('users')
        .doc(targetUid)
        .update({'followers': FieldValue.arrayUnion([currentUser.uid])});
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final username = (data['username'] ?? 'Utilizador').toString();
          final photoUrl = (data['photoUrl'] ?? '').toString();
          final followers = List<String>.from(data['followers'] ?? []).length;
          final following = List<String>.from(data['following'] ?? []).length;
          final isPrivate = data['isPrivate'] == true;
          final followersList = List<String>.from(data['followers'] ?? []);
          final amIFollowing =
              currentUser != null && followersList.contains(currentUser.uid);

          return FutureBuilder<List<dynamic>>(
            future: Future.wait([
              firestore.getUserCheckInCount(userId),
              firestore.getUserTotalWeight(userId),
              firestore.getUserPoints(userId),
              firestore.getUserProgress(userId),
              firestore.getUserPublishedWorkoutCount(userId),
              firestore.getUserTotalExerciseCount(userId),
            ]),
            builder: (context, statsSnapshot) {
              if (!statsSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final streak = statsSnapshot.data![0] as int;
              final totalWeight = statsSnapshot.data![1] as double;
              final points = statsSnapshot.data![2] as int;
              final progress =
                  List<Map<String, dynamic>>.from(statsSnapshot.data![3] as List);
              final publishedCount = statsSnapshot.data![4] as int;
              final totalExercises = statsSnapshot.data![5] as int;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundImage:
                          photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: photoUrl.isEmpty
                          ? Text(
                              username.isNotEmpty
                                  ? username[0].toUpperCase()
                                  : '?',
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(isPrivate ? 'Conta privada' : 'Conta publica'),
                    if (currentUser != null && currentUser.uid != userId) ...[
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () => _toggleFollow(context, userId),
                        child: Text(
                          amIFollowing
                              ? 'A seguir'
                              : (isPrivate ? 'Pedir para seguir' : 'Seguir'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(
                          label: 'Dias',
                          value: '$streak',
                        ),
                        _ClickableStatItem(
                          label: 'Seguidores',
                          value: '$followers',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserConnectionsPage(
                                  userId: userId,
                                  username: username,
                                  initialTabIndex: 0,
                                ),
                              ),
                            );
                          },
                        ),
                        _ClickableStatItem(
                          label: 'A seguir',
                          value: '$following',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserConnectionsPage(
                                  userId: userId,
                                  username: username,
                                  initialTabIndex: 1,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _StatChip(
                          label: 'Treinos publicados',
                          value: '$publishedCount',
                        ),
                        _StatChip(
                          label: 'Exercicios totais',
                          value: '$totalExercises',
                        ),
                        _StatChip(
                          label: 'Peso total',
                          value: '${totalWeight.toStringAsFixed(0)} kg',
                        ),
                        _StatChip(
                          label: 'Pontuacao',
                          value: '$points',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Evolucao: ${_performanceLabel(progress)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 220,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Theme.of(context).cardColor,
                      ),
                      child: ProgressAreaChart(progress: progress),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }
}

class _ClickableStatItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ClickableStatItem({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(label),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
