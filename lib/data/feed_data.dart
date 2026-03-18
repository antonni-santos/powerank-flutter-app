import '../models/workout_post.dart';

class FeedData {

  static List<WorkoutPost> posts = [

    WorkoutPost(
      id: '1',             
      user: "João",
      time: "2h",
      title: "Chest Day",
      exercises: [
        "Bench Press 80kg x 8",
        "Incline DB 30kg x 10"
      ],
      likes: 12,
      comments: 2,
      commentsList: [],
      likedBy: [],          
    ),

    WorkoutPost(
      id: '2',              
      user: "Carlos",
      time: "5h",
      title: "Leg Day",
      exercises: [
        "Squat 120kg x 5",
        "Leg Press 200kg x 10"
      ],
      likes: 18,
      comments: 4,
      commentsList: [],
      likedBy: [],         
    ),

  ];

}