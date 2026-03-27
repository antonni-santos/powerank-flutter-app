import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _notificationsRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }

  Future<void> createNotification({
    required String targetUserId,
    required String type,
    required String title,
    required String body,
    String? senderId,
    String? senderUsername,
    String? chatId,
    String? otherUid,
    String? otherUsername,
    String? workoutId,
    String? sourceType,
  }) async {
    if (targetUserId.isEmpty) return;

    await _notificationsRef(targetUserId).add({
      'type': type,
      'title': title,
      'body': body,
      'senderId': senderId,
      'senderUsername': senderUsername,
      'chatId': chatId,
      'otherUid': otherUid,
      'otherUsername': otherUsername,
      'workoutId': workoutId,
      'sourceType': sourceType,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendFollowRequestNotification({
    required String targetUserId,
    required String senderId,
    required String senderUsername,
  }) async {
    await createNotification(
      targetUserId: targetUserId,
      type: 'follow_request',
      title: 'Novo pedido de seguir',
      body: '$senderUsername pediu para te seguir.',
      senderId: senderId,
      senderUsername: senderUsername,
    );
  }

  Future<void> sendMessageNotification({
    required String targetUserId,
    required String senderId,
    required String senderUsername,
    required String chatId,
    required String messageText,
  }) async {
    await createNotification(
      targetUserId: targetUserId,
      type: 'message',
      title: 'Nova mensagem',
      body: '$senderUsername: ${_preview(messageText)}',
      senderId: senderId,
      senderUsername: senderUsername,
      chatId: chatId,
      otherUid: senderId,
      otherUsername: senderUsername,
    );
  }

  Future<void> sendMentionNotificationsFromText({
    required String text,
    required String senderId,
    required String senderUsername,
    required String sourceType,
    String? workoutId,
  }) async {
    final mentionedUsernames = _extractMentionedUsernames(text);
    if (mentionedUsernames.isEmpty) return;

    for (final username in mentionedUsernames) {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) continue;

      final targetDoc = snapshot.docs.first;
      if (targetDoc.id == senderId) continue;

      final contextText =
          sourceType == 'comment' ? 'num comentario' : 'num treino';

      await createNotification(
        targetUserId: targetDoc.id,
        type: 'mention',
        title: 'Foste marcado',
        body: '$senderUsername marcou-te $contextText: ${_preview(text)}',
        senderId: senderId,
        senderUsername: senderUsername,
        workoutId: workoutId,
        sourceType: sourceType,
      );
    }
  }

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    await _notificationsRef(userId).doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _notificationsRef(userId).get();
    await _setMatchingNotificationsAsRead(
      snapshot.docs.where((doc) {
        final data = doc.data();
        return data['isRead'] != true;
      }).toList(),
    );
  }

  Future<void> markChatNotificationsAsRead({
    required String userId,
    required String chatId,
  }) async {
    final snapshot = await _notificationsRef(userId).get();
    await _setMatchingNotificationsAsRead(
      snapshot.docs.where((doc) {
        final data = doc.data();
        return data['isRead'] != true &&
            data['type'] == 'message' &&
            data['chatId'] == chatId;
      }).toList(),
    );
  }

  Future<void> markFollowRequestNotificationsAsRead(String userId) async {
    final snapshot = await _notificationsRef(userId).get();
    await _setMatchingNotificationsAsRead(
      snapshot.docs.where((doc) {
        final data = doc.data();
        return data['isRead'] != true && data['type'] == 'follow_request';
      }).toList(),
    );
  }

  Future<void> _setMatchingNotificationsAsRead(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    if (docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Set<String> _extractMentionedUsernames(String text) {
    final matches = RegExp(r'@([A-Za-z0-9_\.]+)').allMatches(text);
    return matches
        .map((match) => match.group(1)?.trim() ?? '')
        .where((username) => username.isNotEmpty)
        .toSet();
  }

  String _preview(String text) {
    final cleaned = text.trim().replaceAll('\n', ' ');
    if (cleaned.length <= 80) return cleaned;
    return '${cleaned.substring(0, 80)}...';
  }
}
