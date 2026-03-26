import '../models/workout_post.dart';

class FeedData {
  static List<WorkoutPost> posts = [
    WorkoutPost(
      id: '1',
      userId: 'local_1',
      user: 'Joao',
      time: '2h',
      title: 'Chest Day',
      exercises: [
        {'name': 'Bench Press', 'weight': 80, 'sets': 4, 'reps': 8},
        {'name': 'Incline DB', 'weight': 30, 'sets': 3, 'reps': 10},
      ],
      imageUrls: [],
      likes: 12,
      comments: 2,
      commentsList: [],
      likedBy: [],
    ),
    WorkoutPost(
      id: '2',
      userId: 'local_2',
      user: 'Carlos',
      time: '5h',
      title: 'Leg Day',
      exercises: [
        {'name': 'Squat', 'weight': 120, 'sets': 5, 'reps': 5},
        {'name': 'Leg Press', 'weight': 200, 'sets': 4, 'reps': 10},
      ],
      imageUrls: [],
      likes: 18,
      comments: 4,
      commentsList: [],
      likedBy: [],
    ),
  ];
}
