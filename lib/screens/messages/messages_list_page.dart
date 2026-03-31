import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/screens/messages/chat_page.dart';
import 'package:powerank/screens/messages/create_group_page.dart';
import 'package:powerank/services/workout_share_service.dart';

class MessagesListPage extends StatefulWidget {
  const MessagesListPage({super.key});

  @override
  State<MessagesListPage> createState() => _MessagesListPageState();
}

class _MessagesListPageState extends State<MessagesListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showNewMessageDialog(BuildContext context) {
    final searchController = TextEditingController();
    final currentUser = FirebaseAuth.instance.currentUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          List<Map<String, dynamic>> results = [];

          Future<void> search(String query) async {
            if (query.isEmpty) {
              setState(() => results = []);
              return;
            }

            final snap = await FirebaseFirestore.instance
                .collection('users')
                .where('username', isGreaterThanOrEqualTo: query)
                .where('username', isLessThanOrEqualTo: '$query\uf8ff')
                .get();

            setState(() {
              results = snap.docs
                  .where((d) => d.id != currentUser?.uid)
                  .map((d) => {'uid': d.id, ...d.data()})
                  .toList();
            });
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Nova mensagem',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar utilizador...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: search,
                ),
                const SizedBox(height: 8),
                ...results.map(
                  (user) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        (user['username'] as String).isNotEmpty
                            ? (user['username'] as String)[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text((user['username'] ?? '').toString()),
                    onTap: () async {
                      Navigator.pop(context);
                      final chatId = await WorkoutShareService()
                          .getOrCreateDirectChat(
                            currentUser!.uid,
                            user['uid'].toString(),
                          );
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            chatId: chatId,
                            otherUid: user['uid'].toString(),
                            otherUsername: user['username'].toString(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mensagens'),
        ),
        body: const Center(
          child: Text('Faz login para ver as mensagens'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagens'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Grupos'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () async {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const CreateGroupPage()),
              );
              if (!mounted || created != true) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Grupo criado com sucesso')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showNewMessageDialog(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DirectMessagesTab(currentUserId: currentUser.uid),
          _GroupMessagesTab(currentUserId: currentUser.uid),
        ],
      ),
    );
  }
}

class _DirectMessagesTab extends StatelessWidget {
  final String currentUserId;

  const _DirectMessagesTab({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .snapshots(),
      builder: (context, followSnap) {
        if (!followSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = followSnap.data!.data() as Map<String, dynamic>?;
        final following = List<String>.from(data?['following'] ?? []);

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .where('participants', arrayContains: currentUserId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final chatDocs = snapshot.data!.docs;
            final Map<String, QueryDocumentSnapshot> chatByOtherUid = {};
            final allUids = <String>{...following};

            for (final doc in chatDocs) {
              final chat = doc.data() as Map<String, dynamic>;
              final participants = List<String>.from(chat['participants'] ?? []);
              final otherUid = participants.firstWhere(
                (uid) => uid != currentUserId,
                orElse: () => '',
              );
              if (otherUid.isEmpty) continue;
              chatByOtherUid[otherUid] = doc;
              allUids.add(otherUid);
            }

            final orderedUids = allUids.toList()
              ..sort((a, b) {
                final chatA = chatByOtherUid[a]?.data() as Map<String, dynamic>?;
                final chatB = chatByOtherUid[b]?.data() as Map<String, dynamic>?;
                final timeA = chatA?['lastMessageAt'] as Timestamp?;
                final timeB = chatB?['lastMessageAt'] as Timestamp?;

                if (timeA == null && timeB == null) return 0;
                if (timeA == null) return 1;
                if (timeB == null) return -1;
                return timeB.compareTo(timeA);
              });

            if (orderedUids.isEmpty) {
              return const Center(
                child: Text('Nao segues ninguem e ainda nao tens conversas'),
              );
            }

            return ListView.builder(
              itemCount: orderedUids.length,
              itemBuilder: (context, index) {
                final otherUid = orderedUids[index];
                final chatDoc = chatByOtherUid[otherUid];
                final chatData = chatDoc?.data() as Map<String, dynamic>?;
                final lastMessage = (chatData?['lastMessage'] ?? '').toString();
                final unread = (chatData?['unread_$currentUserId'] ?? 0) as int;

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(otherUid)
                      .get(),
                  builder: (context, userSnap) {
                    if (!userSnap.hasData || !userSnap.data!.exists) {
                      return const SizedBox();
                    }

                    final userData =
                        userSnap.data!.data() as Map<String, dynamic>;
                    final username =
                        (userData['username'] ?? 'Utilizador').toString();

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          username.isNotEmpty ? username[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        username,
                        style: TextStyle(
                          fontWeight:
                              unread > 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        lastMessage.isNotEmpty
                            ? lastMessage
                            : 'Toca para enviar mensagem',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: unread > 0
                          ? CircleAvatar(
                              radius: 10,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(
                                '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            )
                          : null,
                      onTap: () async {
                        final chatId = chatDoc?.id ??
                            await WorkoutShareService()
                                .getOrCreateDirectChat(currentUserId, otherUid);

                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              chatId: chatId,
                              otherUid: otherUid,
                              otherUsername: username,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _GroupMessagesTab extends StatelessWidget {
  final String currentUserId;

  const _GroupMessagesTab({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('workout_groups')
          .where('members', arrayContains: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final groups = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aTs = a.data()['lastMessageAt'] as Timestamp?;
            final bTs = b.data()['lastMessageAt'] as Timestamp?;
            if (aTs == null && bTs == null) return 0;
            if (aTs == null) return 1;
            if (bTs == null) return -1;
            return bTs.compareTo(aTs);
          });

        if (groups.isEmpty) {
          return const Center(
            child: Text('Ainda nao tens grupos de treino'),
          );
        }

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final doc = groups[index];
            final data = doc.data();
            final name = (data['name'] ?? 'Grupo').toString();
            final lastMessage = (data['lastMessage'] ?? '').toString();
            final members = List<String>.from(data['members'] ?? []);
            final unread = (data['unread_$currentUserId'] ?? 0) as int;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.groups, color: Colors.white),
              ),
              title: Text(
                name,
                style: TextStyle(
                  fontWeight:
                      unread > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                lastMessage.isNotEmpty ? lastMessage : '${members.length} membros',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: unread > 0
                  ? CircleAvatar(
                      radius: 10,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        '$unread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPage(
                      chatId: doc.id,
                      otherUid: '',
                      otherUsername: name,
                      isGroupChat: true,
                      groupMembers: members,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
