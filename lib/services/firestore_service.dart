import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_post.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<WorkoutPost>> getWorkouts() async {
    final snapshot = await _db.collection('workouts').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return WorkoutPost(
        user: data['userId'] ?? '',
        time: "now",
        title: data['title'] ?? '',
        exercises: List<String>.from(data['exercises'] ?? []),
        likes: data['likes'] ?? 0,
        comments: 0,
        commentsList: List<String>.from(data['commentList'] ?? []), 
      );
    }).toList();
  }
}