import 'package:flutter/material.dart';
import '../../models/workout_post.dart';
import '../../widgets/workout_post_card.dart';
import '../workout/create_workout_page.dart';
import '../../data/feed_data.dart';

class HomeFeedPage extends StatelessWidget {
  HomeFeedPage({super.key});

  final List<WorkoutPost> posts = [
    WorkoutPost(
      user: "João Silva",
      time: "2h ago",
      title: "Chest Workout",
      exercises: [
        "Bench Press 80kg x 8",
        "Bench Press 80kg x 6",
        "Incline DB 30kg x 10"
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
        "Leg Curl 60kg x 12"
      ],
      likes: 17,
      comments: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Powerank"),
        backgroundColor: Colors.black,
      ),

body: ListView.builder(
  padding: const EdgeInsets.all(16),
  itemCount: FeedData.posts.length,
  itemBuilder: (context, index) {
    return WorkoutPostCard(post: FeedData.posts[index]);
  },
),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateWorkoutPage(),
            ),
          );
        },
      ),
    );
  }
}