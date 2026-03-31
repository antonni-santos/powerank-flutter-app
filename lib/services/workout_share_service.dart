import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:powerank/models/workout_post.dart';
import 'package:powerank/services/notification_service.dart';

class WorkoutShareService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  Future<String> getOrCreateDirectChat(String myUid, String otherUid) async {
    final existing = await _db
        .collection('chats')
        .where('participants', arrayContains: myUid)
        .get();

    for (final doc in existing.docs) {
      final parts = List<String>.from(doc.data()['participants'] ?? []);
      if (parts.contains(otherUid)) return doc.id;
    }

    final newChat = await _db.collection('chats').add({
      'participants': [myUid, otherUid],
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unread_$myUid': 0,
      'unread_$otherUid': 0,
    });

    return newChat.id;
  }

  Future<String> createWorkoutGroup({
    required String creatorUid,
    required String creatorUsername,
    required String name,
    required List<String> memberIds,
  }) async {
    final allMembers = <String>{creatorUid, ...memberIds}.toList();
    final groupRef = await _db.collection('workout_groups').add({
      'name': name.trim(),
      'members': allMembers,
      'createdBy': creatorUid,
      'createdByUsername': creatorUsername,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      for (final uid in allMembers) 'unread_$uid': 0,
    });

    return groupRef.id;
  }

  Future<bool> canViewerAccessWorkout({
    required String ownerId,
    required String viewerId,
  }) async {
    if (ownerId == viewerId) return true;

    final ownerDoc = await _db.collection('users').doc(ownerId).get();
    if (!ownerDoc.exists) return false;

    final ownerData = ownerDoc.data() ?? {};
    final isPrivate = ownerData['isPrivate'] == true;
    if (!isPrivate) return true;

    final viewerDoc = await _db.collection('users').doc(viewerId).get();
    final following = List<String>.from(viewerDoc.data()?['following'] ?? []);
    return following.contains(ownerId);
  }

  Future<bool> isWorkoutOwnerPrivate(String ownerId) async {
    final ownerDoc = await _db.collection('users').doc(ownerId).get();
    return ownerDoc.data()?['isPrivate'] == true;
  }

  Map<String, dynamic> _buildWorkoutPayload({
    required WorkoutPost post,
    required bool ownerIsPrivate,
  }) {
    return {
      'workoutId': post.id,
      'title': post.title,
      'ownerId': post.userId,
      'ownerUsername': post.user,
      'ownerIsPrivate': ownerIsPrivate,
      'exerciseCount': post.exercises.length,
      'exercises': post.exercises,
      'imageUrls': post.imageUrls,
      'videoUrls': post.videoUrls,
      'totalWeight': post.totalWeight,
    };
  }

  Future<void> sendWorkoutToDirectChat({
    required String chatId,
    required String fromUid,
    required String fromUsername,
    required String targetUid,
    required WorkoutPost post,
    required bool ownerIsPrivate,
  }) async {
    final preview = 'Treino partilhado: ${post.title}';
    await _db.collection('chats').doc(chatId).collection('messages').add({
      'type': 'workout',
      'text': '',
      'previewText': preview,
      'senderId': fromUid,
      'senderUsername': fromUsername,
      'createdAt': FieldValue.serverTimestamp(),
      'workout': _buildWorkoutPayload(post: post, ownerIsPrivate: ownerIsPrivate),
    });

    await _db.collection('chats').doc(chatId).update({
      'lastMessage': preview,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unread_$targetUid': FieldValue.increment(1),
    });

    await _notificationService.sendMessageNotification(
      targetUserId: targetUid,
      senderId: fromUid,
      senderUsername: fromUsername,
      chatId: chatId,
      messageText: preview,
    );
  }

  Future<void> sendWorkoutToGroup({
    required String groupId,
    required String fromUid,
    required String fromUsername,
    required WorkoutPost post,
    required bool ownerIsPrivate,
    required List<String> memberIds,
  }) async {
    final preview = 'Treino partilhado: ${post.title}';
    await _db
        .collection('workout_groups')
        .doc(groupId)
        .collection('messages')
        .add({
      'type': 'workout',
      'text': '',
      'previewText': preview,
      'senderId': fromUid,
      'senderUsername': fromUsername,
      'createdAt': FieldValue.serverTimestamp(),
      'workout': _buildWorkoutPayload(post: post, ownerIsPrivate: ownerIsPrivate),
    });

    await _db.collection('workout_groups').doc(groupId).update({
      'lastMessage': preview,
      'lastMessageAt': FieldValue.serverTimestamp(),
      for (final uid in memberIds)
        if (uid != fromUid) 'unread_$uid': FieldValue.increment(1),
    });
  }
}
