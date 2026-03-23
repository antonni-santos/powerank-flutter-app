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

    final newChat =
        await FirebaseFirestore.instance.collection('chats').add({
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

          void search(String query) async {
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
                const Text("Nova mensagem",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Pesquisar utilizador...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: search,
                ),
                const SizedBox(height: 8),
                ...results.map((user) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text(
                          (user['username'] as String).isNotEmpty
                              ? (user['username'] as String)[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(user['username'] ?? ''),
                      onTap: () async {
                        Navigator.pop(context);
                        final chatId = await _getOrCreateChat(
                            currentUser!.uid, user['uid']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              chatId: chatId,
                              otherUid: user['uid'],
                              otherUsername: user['username'],
                            ),
                          ),
                        );
                      },
                    )),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mensagens"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showNewMessageDialog(context),
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUser?.uid)
            // .orderBy('lastMessageAt', descending: true) 
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message, color: Colors.grey, size: 60),
                  SizedBox(height: 16),
                  Text("Sem mensagens ainda",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  SizedBox(height: 8),
                  Text("Começa uma conversa!",
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            );
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index].data() as Map<String, dynamic>;
              final chatId = chats[index].id;
              final participants =
                  List<String>.from(chat['participants'] ?? []);
              final otherUid = participants.firstWhere(
                (uid) => uid != currentUser?.uid,
                orElse: () => '',
              );

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUid)
                    .get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) return const SizedBox();
                  final userData =
                      userSnap.data?.data() as Map<String, dynamic>?;
                  final username = userData?['username'] ?? 'Utilizador';
                  final lastMessage = chat['lastMessage'] ?? '';
                  final unread =
                      (chat['unread_${currentUser?.uid}'] ?? 0) as int;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(
                        username.isNotEmpty ? username[0].toUpperCase() : '?',
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
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: unread > 0 ? Colors.green : Colors.grey,
                      ),
                    ),
                    trailing: unread > 0
                        ? CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.green,
                            child: Text(
                              '$unread',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11),
                            ),
                          )
                        : null,
                    onTap: () {
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