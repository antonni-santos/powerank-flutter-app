import '../data/feed_data.dart';

class WorkoutStats {

  static int totalWorkouts() {
    return FeedData.posts.length;
  }

  static int totalExercises() {

    int total = 0;

    for (var post in FeedData.posts) {
      total += post.exercises.length;
    }

    return total;
  }

}