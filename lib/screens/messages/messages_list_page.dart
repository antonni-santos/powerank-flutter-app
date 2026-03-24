import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';

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

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Mensagens"),
        ),
        body: const Center(
          child: Text("Faz login para ver as mensagens"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mensagens"),
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

          if (following.isEmpty) {
            return const Center(
              child: Text("Nao segues ninguem ainda"),
            );
          }

          return ListView.builder(
            itemCount: following.length,
            itemBuilder: (context, index) {
              final otherUid = following[index];

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
                      ),
                    ),
                    title: Text(username),
                    onTap: () async {
                      final chatId =
                          await _getOrCreateChat(currentUser.uid, otherUid);

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
      ),
    );
  }
}
