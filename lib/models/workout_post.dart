import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:powerank/utils/workout_metrics.dart';

class WorkoutPost {
  final String id;
  final String userId;
  String user;
  String time;
  String title;
  List<Map<String, dynamic>> exercises;
  List<String> imageUrls;
  List<String> videoUrls;
  int likes;
  int comments;
  List<String> commentsList;
  List<String> likedBy;
  double totalWeight;

  WorkoutPost({
    required this.id,
    required this.userId,
    required this.user,
    required this.time,
    required this.title,
    required this.exercises,
    required this.imageUrls,
    required this.videoUrls,
    required this.likes,
    required this.comments,
    required this.commentsList,
    required this.likedBy,
    this.totalWeight = 0,
  });

  factory WorkoutPost.fromFirestore(String id, Map<String, dynamic> data) {
    return WorkoutPost(
      id: id,
      userId: data['userId'] ?? '',
      user: (data['username'] ?? data['userId'] ?? '').toString(),
      time: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate().toString()
          : 'agora',
      title: data['title'] ?? '',
      exercises: WorkoutMetrics.parseExercises(data['exercises']),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      videoUrls: List<String>.from(data['videoUrls'] ?? []),
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      commentsList: [],
      likedBy: List<String>.from(data['likedBy'] ?? []),
      totalWeight: WorkoutMetrics.resolveTotalWeight(
        exercises: data['exercises'],
        storedTotalWeight: data['totalWeight'],
      ),
    );
  }
}
