import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_post.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> getUsername(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return (doc.data()?['username'] ?? 'Utilizador').toString();
    }
    return 'Utilizador';
  }

  List<Map<String, dynamic>> _parseExercises(dynamic raw) {
    if (raw == null) return [];
    return (raw as List).map((e) {
      if (e is Map) return Map<String, dynamic>.from(e);
      return {'name': e.toString(), 'weight': 0, 'sets': 0, 'reps': 0};
    }).toList();
  }

  List<String> _parseImageUrls(dynamic raw) {
    if (raw == null) return [];
    return List<String>.from(raw);
  }

  String _parseTime(dynamic raw) {
    if (raw is Timestamp) return raw.toDate().toString();
    return 'agora';
  }

  Stream<List<WorkoutPost>> getWorkoutTemplatesStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return Stream.fromFuture(getUsername(user.uid)).asyncExpand((username) {
      return _db
          .collection('workout_templates')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) {
        final docs = snapshot.docs.toList()
          ..sort((a, b) {
            final aTs = a.data()['createdAt'] as Timestamp?;
            final bTs = b.data()['createdAt'] as Timestamp?;
            return (bTs?.millisecondsSinceEpoch ?? 0)
                .compareTo(aTs?.millisecondsSinceEpoch ?? 0);
          });

        return docs.map((doc) {
          final data = doc.data();
          return WorkoutPost(
            id: doc.id,
            userId: data['userId'] ?? '',
            user: (data['username'] ?? username).toString(),
            time: _parseTime(data['createdAt']),
            title: data['title'] ?? '',
            exercises: _parseExercises(data['exercises']),
            imageUrls: _parseImageUrls(data['imageUrls']),
            likes: data['likes'] ?? 0,
            comments: data['comments'] ?? 0,
            commentsList: [],
            likedBy: List<String>.from(data['likedBy'] ?? []),
            totalWeight: (data['totalWeight'] ?? 0).toDouble(),
          );
        }).toList();
      });
    });
  }

  Stream<List<WorkoutPost>> getFeedPostsStream() {
    return _db.collection('feed_posts').snapshots().map((snapshot) {
      final docs = snapshot.docs.toList()
        ..sort((a, b) {
          final aTs = a.data()['createdAt'] as Timestamp?;
          final bTs = b.data()['createdAt'] as Timestamp?;
          return (bTs?.millisecondsSinceEpoch ?? 0)
              .compareTo(aTs?.millisecondsSinceEpoch ?? 0);
        });

      return docs.map((doc) {
        final data = doc.data();
        return WorkoutPost(
          id: doc.id,
          userId: data['userId'] ?? '',
          user: (data['username'] ?? 'Utilizador').toString(),
          time: _parseTime(data['createdAt']),
          title: data['title'] ?? '',
          exercises: _parseExercises(data['exercises']),
          imageUrls: _parseImageUrls(data['imageUrls']),
          likes: data['likes'] ?? 0,
          comments: data['comments'] ?? 0,
          commentsList: [],
          likedBy: List<String>.from(data['likedBy'] ?? []),
          totalWeight: (data['totalWeight'] ?? 0).toDouble(),
        );
      }).toList();
    });
  }
}
