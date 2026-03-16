import 'package:flutter/material.dart';
import '../../models/workout_post.dart';
import '../../widgets/workout_post_card.dart';
import '../workout/create_workout_page.dart';
import '../../data/feed_data.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {

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

        onPressed: () async {

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateWorkoutPage(),
            ),
          );

          setState(() {});

        },
      ),
    );
  }
}