class WorkoutPost {
  String title;               
  final String user;
  final String time;
  final List<String> exercises;
  int likes;
  int comments;
  List<String> commentList;   

  WorkoutPost({
    required this.title,
    required this.user,
    required this.time,
    required this.exercises,
    this.likes = 0,            
    this.comments = 0,         
    List<String>? commentList, 
  }) : commentList = commentList ?? []; 
}