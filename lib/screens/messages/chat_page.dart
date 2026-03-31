import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/services/notification_service.dart';
import 'package:powerank/services/workout_share_service.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String otherUid;
  final String otherUsername;
  final bool isGroupChat;
  final List<String> groupMembers;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.otherUid,
    required this.otherUsername,
    this.isGroupChat = false,
    this.groupMembers = const [],
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final NotificationService _notificationService = NotificationService();
  final WorkoutShareService _workoutShareService = WorkoutShareService();

  CollectionReference<Map<String, dynamic>> get _messagesCollection =>
      FirebaseFirestore.instance
          .collection(widget.isGroupChat ? 'workout_groups' : 'chats')
          .doc(widget.chatId)
          .collection('messages');

  DocumentReference<Map<String, dynamic>> get _chatDoc =>
      FirebaseFirestore.instance
          .collection(widget.isGroupChat ? 'workout_groups' : 'chats')
          .doc(widget.chatId);

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

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

    await _chatDoc.update({'unread_${currentUser.uid}': 0});

    if (!widget.isGroupChat) {
      await _notificationService.markChatNotificationsAsRead(
        userId: currentUser.uid,
        chatId: widget.chatId,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final text = _controller.text.trim();
    _controller.clear();

    final myUsername = await _getCurrentUsername(currentUser.uid);

    await _messagesCollection.add({
      'type': 'text',
      'text': text,
      'senderId': currentUser.uid,
      'senderUsername': myUsername,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _chatDoc.update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      if (widget.isGroupChat)
        for (final uid in widget.groupMembers)
          if (uid != currentUser.uid) 'unread_$uid': FieldValue.increment(1),
      if (!widget.isGroupChat)
        'unread_${widget.otherUid}': FieldValue.increment(1),
    });

    if (!widget.isGroupChat) {
      await _notificationService.sendMessageNotification(
        targetUserId: widget.otherUid,
        senderId: currentUser.uid,
        senderUsername: myUsername,
        chatId: widget.chatId,
        messageText: text,
      );
    }
  }

  Future<bool> _canViewWorkout(Map<String, dynamic> workout) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;
    final ownerId = (workout['ownerId'] ?? '').toString();
    if (ownerId.isEmpty) return false;
    return _workoutShareService.canViewerAccessWorkout(
      ownerId: ownerId,
      viewerId: currentUser.uid,
    );
  }

  Future<String> _followLabel(String ownerId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.uid == ownerId) return 'Tu';

    final currentDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final following = List<String>.from(currentDoc.data()?['following'] ?? []);
    if (following.contains(ownerId)) return 'A seguir';

    final ownerDoc =
        await FirebaseFirestore.instance.collection('users').doc(ownerId).get();
    final isPrivate = ownerDoc.data()?['isPrivate'] == true;
    return isPrivate ? 'Pedir para seguir' : 'Seguir';
  }

  Future<void> _toggleFollowOwner(
    BuildContext context,
    Map<String, dynamic> workout,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final ownerId = (workout['ownerId'] ?? '').toString();
    if (ownerId.isEmpty || ownerId == currentUser.uid) return;

    final currentDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final currentUsername =
        (currentDoc.data()?['username'] ?? 'Utilizador').toString();
    final following = List<String>.from(currentDoc.data()?['following'] ?? []);
    final ownerDoc =
        await FirebaseFirestore.instance.collection('users').doc(ownerId).get();
    final isPrivate = ownerDoc.data()?['isPrivate'] == true;

    if (following.contains(ownerId)) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'following': FieldValue.arrayRemove([ownerId])});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ownerId)
          .update({'followers': FieldValue.arrayRemove([currentUser.uid])});
    } else if (isPrivate) {
      final existing = await FirebaseFirestore.instance
          .collection('followRequests')
          .where('fromId', isEqualTo: currentUser.uid)
          .where('toId', isEqualTo: ownerId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existing.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('followRequests').add({
          'fromId': currentUser.uid,
          'fromUsername': currentUsername,
          'toId': ownerId,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        await _notificationService.sendFollowRequestNotification(
          targetUserId: ownerId,
          senderId: currentUser.uid,
          senderUsername: currentUsername,
        );
      }
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'following': FieldValue.arrayUnion([ownerId])});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ownerId)
          .update({'followers': FieldValue.arrayUnion([currentUser.uid])});
    }

    if (!context.mounted) return;
    Navigator.pop(context);
    setState(() {});
  }

  Future<void> _copyWorkoutToHistory(
    BuildContext context,
    Map<String, dynamic> workout,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final myDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final myUsername = (myDoc.data()?['username'] ?? 'Utilizador').toString();

    await FirebaseFirestore.instance.collection('workout_templates').add({
      'title': (workout['title'] ?? 'Treino copiado').toString(),
      'userId': currentUser.uid,
      'username': myUsername,
      'exercises': List<Map<String, dynamic>>.from(
        (workout['exercises'] ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      'imageUrls': <String>[],
      'videoUrls': <String>[],
      'totalWeight': (workout['totalWeight'] ?? 0).toDouble(),
      'likes': 0,
      'likedBy': <String>[],
      'comments': 0,
      'createdAt': Timestamp.now(),
      'copiedFromUserId': (workout['ownerId'] ?? '').toString(),
      'copiedFromUsername': (workout['ownerUsername'] ?? '').toString(),
    });

    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Treino copiado para o History')),
    );
  }

  Future<void> _openWorkoutDetails(BuildContext context, Map<String, dynamic> workout) async {
    final canView = await _canViewWorkout(workout);
    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => FutureBuilder<String>(
        future: _followLabel((workout['ownerId'] ?? '').toString()),
        builder: (context, followSnapshot) {
          final followLabel = followSnapshot.data ?? 'Seguir';

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    (workout['ownerUsername'] ?? 'Utilizador').toString(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if ((workout['ownerId'] ?? '').toString() !=
                    FirebaseAuth.instance.currentUser?.uid)
                  TextButton(
                    onPressed: () => _toggleFollowOwner(dialogContext, workout),
                    child: Text(followLabel),
                  ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: canView
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (workout['title'] ?? 'Treino').toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ...List<Map<String, dynamic>>.from(
                          (workout['exercises'] ?? []).map(
                            (e) => Map<String, dynamic>.from(e as Map),
                          ),
                        ).map(
                          (exercise) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '${exercise['name'] ?? ''} - ${(exercise['weight'] ?? 0)}kg x ${(exercise['sets'] ?? 0)} x ${(exercise['reps'] ?? 0)}',
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'O utilizador que publicou este treino tem a conta privada e voce nao o segue.',
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Fechar'),
              ),
              if (canView)
                ElevatedButton(
                  onPressed: () => _copyWorkoutToHistory(dialogContext, workout),
                  child: const Text('Copiar'),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWorkoutMessage(
    BuildContext context,
    Map<String, dynamic> msg,
    bool isMe,
  ) {
    final theme = Theme.of(context);
    final workout = Map<String, dynamic>.from(msg['workout'] ?? {});

    return FutureBuilder<bool>(
      future: _canViewWorkout(workout),
      builder: (context, snapshot) {
        final canView = snapshot.data ?? false;

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openWorkoutDetails(context, workout),
          child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          decoration: BoxDecoration(
            color: isMe
                ? theme.colorScheme.primary.withOpacity(0.12)
                : theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isMe
                  ? theme.colorScheme.primary.withOpacity(0.35)
                  : theme.dividerColor,
            ),
          ),
          child: canView
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.fitness_center,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (workout['title'] ?? 'Treino').toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'de ${(workout['ownerUsername'] ?? 'Utilizador').toString()}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${workout['exerciseCount'] ?? 0} exercicios',
                    ),
                    if ((workout['totalWeight'] ?? 0).toDouble() > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Peso total: ${(workout['totalWeight'] ?? 0).toDouble().toStringAsFixed(0)} kg',
                      ),
                    ],
                    if (List<String>.from(workout['imageUrls'] ?? []).isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.photo_library_outlined, size: 18),
                            SizedBox(width: 6),
                            Text('Contem imagens'),
                          ],
                        ),
                      ),
                    if (List<String>.from(workout['videoUrls'] ?? []).isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(Icons.videocam_outlined, size: 18),
                            SizedBox(width: 6),
                            Text('Contem videos'),
                          ],
                        ),
                      ),
                  ],
                )
              : const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock_outline),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Treino privado',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'O utilizador que publicou este treino tem a conta privada e voce nao o segue.',
                    ),
                  ],
                ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                widget.isGroupChat ? Icons.groups : Icons.person,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.otherUsername),
                  if (widget.isGroupChat)
                    Text(
                      '${widget.groupMembers.length} membros',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _messagesCollection.orderBy('createdAt').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Sem mensagens ainda'),
                  );
                }

                final messages = snapshot.data!.docs;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController
                        .jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data();
                    final isMe = msg['senderId'] == currentUser?.uid;
                    final type = (msg['type'] ?? 'text').toString();

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment:
                            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (widget.isGroupChat && !isMe)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4, left: 4),
                              child: Text(
                                (msg['senderUsername'] ?? 'Utilizador').toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      theme.colorScheme.onSurface.withOpacity(0.65),
                                ),
                              ),
                            ),
                          if (type == 'workout')
                            _buildWorkoutMessage(context, msg, isMe)
                          else
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7,
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
                                ),
                              ),
                              child: Text(
                                (msg['text'] ?? '').toString(),
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: widget.isGroupChat
                          ? 'Escreve para o grupo...'
                          : 'Escreve uma mensagem...',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
