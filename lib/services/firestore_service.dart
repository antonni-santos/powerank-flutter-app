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

  List<String> _parseUrls(dynamic raw) {
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
            imageUrls: _parseUrls(data['imageUrls']),
            videoUrls: _parseUrls(data['videoUrls']),
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
          imageUrls: _parseUrls(data['imageUrls']),
          videoUrls: _parseUrls(data['videoUrls']),
          likes: data['likes'] ?? 0,
          comments: data['comments'] ?? 0,
          commentsList: [],
          likedBy: List<String>.from(data['likedBy'] ?? []),
          totalWeight: (data['totalWeight'] ?? 0).toDouble(),
        );
      }).toList();
    });
  }

  Future<int> getUserCheckInCount(String userId) async {
    final doc = await _db.collection('checkins').doc(userId).get();
    final entries = Map<String, dynamic>.from(doc.data()?['entries'] ?? {});
    return entries.length;
  }

  Future<double> getUserTotalWeight(String userId) async {
    final snapshot = await _db
        .collection('feed_posts')
        .where('userId', isEqualTo: userId)
        .get();

    double total = 0;
    for (final doc in snapshot.docs) {
      total += (doc.data()['totalWeight'] ?? 0).toDouble();
    }
    return total;
  }

  Future<int> getUserPublishedWorkoutCount(String userId) async {
    final snapshot = await _db
        .collection('feed_posts')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.length;
  }

  Future<int> getUserTotalExerciseCount(String userId) async {
    final snapshot = await _db
        .collection('feed_posts')
        .where('userId', isEqualTo: userId)
        .get();

    int total = 0;
    for (final doc in snapshot.docs) {
      total += List.from(doc.data()['exercises'] ?? []).length;
    }
    return total;
  }

  Future<int> getUserPoints(String userId) async {
    final snapshot = await _db
        .collection('feed_posts')
        .where('userId', isEqualTo: userId)
        .get();

    double totalWeight = 0;
    int totalLikes = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      totalWeight += (data['totalWeight'] ?? 0).toDouble();
      totalLikes += (data['likes'] ?? 0) as int;
    }

    final checkIns = await getUserCheckInCount(userId);
    return (totalWeight / 100).floor() + (checkIns * 50) + (totalLikes * 10);
  }

  Future<List<Map<String, dynamic>>> getUserProgress(String userId) async {
    final snapshot = await _db
        .collection('feed_posts')
        .where('userId', isEqualTo: userId)
        .get();

    final docs = snapshot.docs.toList()
      ..sort((a, b) {
        final aTs = a.data()['createdAt'] as Timestamp?;
        final bTs = b.data()['createdAt'] as Timestamp?;
        return (aTs?.millisecondsSinceEpoch ?? 0)
            .compareTo(bTs?.millisecondsSinceEpoch ?? 0);
      });

    final aggregated = <String, Map<String, dynamic>>{};

    for (final doc in docs) {
      final data = doc.data();
      final ts = data['createdAt'] as Timestamp?;
      final date = ts?.toDate();
      final key = date == null
          ? 'Sem data'
          : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

      final current = aggregated[key] ??
          {
            'title': key,
            'weight': 0.0,
            'workouts': 0,
            'createdAt': ts,
          };

      current['weight'] =
          (current['weight'] as double) + (data['totalWeight'] ?? 0).toDouble();
      current['workouts'] = (current['workouts'] as int) + 1;
      aggregated[key] = current;
    }

    return aggregated.values.toList();
  }
}
