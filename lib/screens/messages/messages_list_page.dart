import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/screens/messages/chat_page.dart';

class MessagesListPage extends StatelessWidget {
  const MessagesListPage({super.key});

  Future<String> _getOrCreateChat(String myUid, String otherUid) async {
    final existing = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: myUid)
        .get();

    for (final doc in existing.docs) {
      final parts = List<String>.from(doc.data()['participants'] ?? []);
      if (parts.contains(otherUid)) return doc.id;
    }

    final newChat = await FirebaseFirestore.instance.collection('chats').add({
      'participants': [myUid, otherUid],
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unread_$myUid': 0,
      'unread_$otherUid': 0,
    });

    return newChat.id;
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
                      final chatId =
                          await _getOrCreateChat(currentUser!.uid, user['uid']);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showNewMessageDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
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
                .where('participants', arrayContains: currentUser.uid)
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
                  (uid) => uid != currentUser.uid,
                  orElse: () => '',
                );
                if (otherUid.isEmpty) continue;
                chatByOtherUid[otherUid] = doc;
                allUids.add(otherUid);
              }

              final orderedUids = allUids.toList()
                ..sort((a, b) {
                  final chatA =
                      chatByOtherUid[a]?.data() as Map<String, dynamic>?;
                  final chatB =
                      chatByOtherUid[b]?.data() as Map<String, dynamic>?;
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
                  final unread =
                      (chatData?['unread_${currentUser.uid}'] ?? 0) as int;

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
                            username.isNotEmpty
                                ? username[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          username,
                          style: TextStyle(
                            fontWeight: unread > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
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
                              await _getOrCreateChat(currentUser.uid, otherUid);

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
      ),
    );
  }
}
