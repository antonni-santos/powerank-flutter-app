class WorkoutPost {
  final String id;
  String user;
  String time;
  String title;
  List<String> exercises;
  int likes;
  int comments;
  List<String> commentsList;
  List<String> likedBy;

  WorkoutPost({
    required this.id,
    required this.user,
    required this.time,
    required this.title,
    required this.exercises,
    required this.likes,
    required this.comments,
    required this.commentsList,
    required this.likedBy,
  });

  factory WorkoutPost.fromFirestore(String id, Map<String, dynamic> data) {
    return WorkoutPost(
      id: id,
      user: data['userId'] ?? '',
      time: "now",
      title: data['title'] ?? '',
      exercises: List<String>.from(data['exercises'] ?? []),
      likes: (data['likedBy'] as List? ?? []).length,
      comments: 0,
      commentsList: [],
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }
}