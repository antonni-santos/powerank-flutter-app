<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/services/notification_service.dart';
=======
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

class ChatPage extends StatefulWidget {
  final String chatId;
  final String otherUid;
  final String otherUsername;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.otherUid,
    required this.otherUsername,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
<<<<<<< HEAD
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final NotificationService _notificationService = NotificationService();
=======

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

<<<<<<< HEAD
  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<String> _getCurrentUsername(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return (doc.data()?['username'] ?? 'Utilizador').toString();
  }

  Future<void> _markAsRead() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

=======
  void _markAsRead() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .update({'unread_${currentUser.uid}': 0});
<<<<<<< HEAD

    await _notificationService.markChatNotificationsAsRead(
      userId: currentUser.uid,
      chatId: widget.chatId,
    );
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

=======
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final text = _controller.text.trim();
    _controller.clear();

<<<<<<< HEAD
    final myUsername = await _getCurrentUsername(currentUser.uid);

=======
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': currentUser.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unread_${widget.otherUid}': FieldValue.increment(1),
    });
<<<<<<< HEAD

    await _notificationService.sendMessageNotification(
      targetUserId: widget.otherUid,
      senderId: currentUser.uid,
      senderUsername: myUsername,
      chatId: widget.chatId,
      messageText: text,
    );
=======
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
<<<<<<< HEAD
    final theme = Theme.of(context);
=======
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
<<<<<<< HEAD
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                widget.otherUsername[0].toUpperCase(),
=======
              backgroundColor: Colors.green,
              radius: 18,
              child: Text(
                widget.otherUsername.isNotEmpty
                    ? widget.otherUsername[0].toUpperCase()
                    : '?',
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.otherUsername),
          ],
        ),
      ),
<<<<<<< HEAD
      body: Column(
        children: [
=======

      body: Column(
        children: [

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
<<<<<<< HEAD
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

=======
                  .orderBy('createdAt')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Sem mensagens ainda",
                        style: TextStyle(color: Colors.grey)),
                  );
                }

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                final messages = snapshot.data!.docs;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
<<<<<<< HEAD
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
=======
                    _scrollController
                        .jumpTo(_scrollController.position.maxScrollExtent);
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
<<<<<<< HEAD
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isMe = msg['senderId'] == currentUser?.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 16),
=======
                    final msg =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe = msg['senderId'] == currentUser?.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isMe ? Colors.green : Colors.grey[800],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft:
                                Radius.circular(isMe ? 16 : 4),
                            bottomRight:
                                Radius.circular(isMe ? 4 : 16),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                          ),
                        ),
                        child: Text(
                          msg['text'] ?? '',
<<<<<<< HEAD
                          style: TextStyle(
                            color: isMe
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                          ),
=======
                          style: const TextStyle(color: Colors.white),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
<<<<<<< HEAD
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.dividerColor),
              ),
=======

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border:
                  Border(top: BorderSide(color: Colors.grey[800]!)),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
<<<<<<< HEAD
                    decoration: InputDecoration(
                      hintText: 'Escreve uma mensagem...',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant,
=======
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Escreve uma mensagem...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[800],
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
<<<<<<< HEAD
                        horizontal: 16,
                        vertical: 10,
                      ),
=======
                          horizontal: 16, vertical: 10),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
<<<<<<< HEAD
                  backgroundColor: theme.colorScheme.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
=======
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: const Icon(Icons.send,
                        color: Colors.white, size: 18),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
<<<<<<< HEAD
=======

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
        ],
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
