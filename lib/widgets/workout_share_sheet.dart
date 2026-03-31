import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/models/workout_post.dart';
import 'package:powerank/services/workout_share_service.dart';

class WorkoutShareSheet extends StatelessWidget {
  final WorkoutPost post;

  const WorkoutShareSheet({
    super.key,
    required this.post,
  });

  Future<String> _getCurrentUsername(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return (doc.data()?['username'] ?? 'Utilizador').toString();
  }

  Future<void> _shareToUser(
    BuildContext context, {
    required String targetUid,
    required String targetUsername,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final service = WorkoutShareService();
    final chatId =
        await service.getOrCreateDirectChat(currentUser.uid, targetUid);
    final myUsername = await _getCurrentUsername(currentUser.uid);
    final ownerIsPrivate =
        await service.isWorkoutOwnerPrivate(post.userId);

    await service.sendWorkoutToDirectChat(
      chatId: chatId,
      fromUid: currentUser.uid,
      fromUsername: myUsername,
      targetUid: targetUid,
      post: post,
      ownerIsPrivate: ownerIsPrivate,
    );

    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Treino enviado para $targetUsername')),
    );
  }

  Future<void> _shareToGroup(
    BuildContext context, {
    required String groupId,
    required String groupName,
    required List<String> memberIds,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final service = WorkoutShareService();
    final myUsername = await _getCurrentUsername(currentUser.uid);
    final ownerIsPrivate =
        await service.isWorkoutOwnerPrivate(post.userId);

    await service.sendWorkoutToGroup(
      groupId: groupId,
      fromUid: currentUser.uid,
      fromUsername: myUsername,
      post: post,
      ownerIsPrivate: ownerIsPrivate,
      memberIds: memberIds,
    );

    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Treino enviado para o grupo $groupName')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: SizedBox(
          height: 420,
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text(
                'Enviar treino',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const TabBar(
                tabs: [
                  Tab(text: 'Pessoas'),
                  Tab(text: 'Grupos'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.uid)
                          .snapshots(),
                      builder: (context, userSnap) {
                        final following = List<String>.from(
                          (userSnap.data?.data() as Map<String, dynamic>?)?['following'] ??
                              [],
                        );

                        if (following.isEmpty) {
                          return const Center(
                            child: Text('Ainda nao segues ninguem.'),
                          );
                        }

                        return ListView.builder(
                          itemCount: following.length,
                          itemBuilder: (context, index) {
                            final uid = following[index];
                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .get(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData || !snapshot.data!.exists) {
                                  return const SizedBox();
                                }

                                final data =
                                    snapshot.data!.data() as Map<String, dynamic>;
                                final username =
                                    (data['username'] ?? 'Utilizador').toString();

                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      username.isNotEmpty
                                          ? username[0].toUpperCase()
                                          : '?',
                                    ),
                                  ),
                                  title: Text(username),
                                  trailing: const Icon(Icons.send),
                                  onTap: () => _shareToUser(
                                    context,
                                    targetUid: uid,
                                    targetUsername: username,
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('workout_groups')
                          .where('members', arrayContains: currentUser.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        final docs = snapshot.data?.docs ?? [];

                        if (docs.isEmpty) {
                          return const Center(
                            child: Text('Ainda nao tens grupos de treino.'),
                          );
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data();
                            final name = (data['name'] ?? 'Grupo').toString();
                            final members =
                                List<String>.from(data['members'] ?? []);

                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.groups),
                              ),
                              title: Text(name),
                              subtitle: Text('${members.length} membros'),
                              trailing: const Icon(Icons.send),
                              onTap: () => _shareToGroup(
                                context,
                                groupId: doc.id,
                                groupName: name,
                                memberIds: members,
                              ),
                            );
                          },
                        );
                      },
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
}
