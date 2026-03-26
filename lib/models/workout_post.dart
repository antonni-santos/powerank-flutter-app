import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutPost {
  final String id;
  final String userId;
  String user;
  String time;
  String title;
  List<Map<String, dynamic>> exercises;
  List<String> imageUrls;
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
      user: data['userId'] ?? '',
      time: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate().toString()
          : 'agora',
      title: data['title'] ?? '',
      exercises: List<Map<String, dynamic>>.from(
        (data['exercises'] ?? []).map(
          (e) => e is Map
              ? Map<String, dynamic>.from(e)
              : {
                  'name': e.toString(),
                  'weight': 0,
                  'sets': 0,
                  'reps': 0,
                },
        ),
      ),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      commentsList: [],
      likedBy: List<String>.from(data['likedBy'] ?? []),
      totalWeight: (data['totalWeight'] ?? 0).toDouble(),
    );
  }
}
