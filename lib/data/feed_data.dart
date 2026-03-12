import '../models/workout_post.dart';

class FeedData {

  static List<WorkoutPost> posts = [

    WorkoutPost(
      user: "João Silva",
      time: "2h ago",
      title: "Chest Workout",
      exercises: [
        "Bench Press 80kg x 8",
        "Bench Press 80kg x 6",
      ],
      likes: 24,
      comments: 5,
    ),

    WorkoutPost(
      user: "Carlos",
      time: "5h ago",
      title: "Leg Day",
      exercises: [
        "Squat 120kg x 5",
        "Leg Press 200kg x 10",
      ],
      likes: 17,
      comments: 2,
    ),

  ];

}