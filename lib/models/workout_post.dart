class WorkoutPost {

  String user;
  String time;
  String title;

  List<String> exercises;

  int likes;
  int comments;

  List<String> commentsList;

  WorkoutPost({
    required this.user,
    required this.time,
    required this.title,
    required this.exercises,
    required this.likes,
    required this.comments,
    required this.commentsList,
  });

}