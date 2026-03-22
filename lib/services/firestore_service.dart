import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout_post.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> getUsername(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return doc.data()?['username'] ?? 'Utilizador';
    }
    return 'Utilizador';
  }

  // 👈 converte os exercícios corretamente
  List<Map<String, dynamic>> _parseExercises(dynamic raw) {
    if (raw == null) return [];
    return (raw as List).map((e) {
      if (e is Map) return Map<String, dynamic>.from(e);
      return {'name': e.toString(), 'weight': 0, 'sets': 0, 'reps': 0};
    }).toList();
  }

  Future<List<WorkoutPost>> getWorkouts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final username = await getUsername(user.uid);
    final snapshot = await _db
        .collection('workouts')
        .where('userId', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return WorkoutPost(
        id: doc.id,
        userId: data['userId'] ?? '',
        user: username,
        time: data['createdAt'] != null
            ? data['createdAt'].toDate().toString()
            : 'agora',
        title: data['title'] ?? '',
        exercises: _parseExercises(data['exercises']), // 👈 corrigido
        likes: data['likes'] ?? 0,
        comments: data['comments'] ?? 0,
        likedBy: List<String>.from(data['likedBy'] ?? []),
        commentsList: [],
        totalWeight: (data['totalWeight'] ?? 0).toDouble(),
      );
    }).toList();
  }

  Stream<List<WorkoutPost>> getWorkoutsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return Stream.fromFuture(getUsername(user.uid)).asyncExpand((username) {
      return _db
          .collection('workouts')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data();
                return WorkoutPost(
                  id: doc.id,
                  userId: data['userId'] ?? '',
                  user: username,
                  time: data['createdAt'] != null
                      ? data['createdAt'].toDate().toString()
                      : 'agora',
                  title: data['title'] ?? '',
                  exercises: _parseExercises(data['exercises']), 
                  likes: data['likes'] ?? 0,
                  comments: data['comments'] ?? 0,
                  likedBy: List<String>.from(data['likedBy'] ?? []),
                  commentsList: [],
                  totalWeight: (data['totalWeight'] ?? 0).toDouble(),
                );
              }).toList());
    });
  }
}