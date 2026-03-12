class WorkoutPost {
  final String user;
  final String time;
  final String title;
  final List<String> exercises;
  final int likes;
  final int comments;

  WorkoutPost({
    required this.user,
    required this.time,
    required this.title,
    required this.exercises,
    required this.likes,
    required this.comments,
  });
}