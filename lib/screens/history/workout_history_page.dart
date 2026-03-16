import 'package:flutter/material.dart';
import '../../data/feed_data.dart';

class WorkoutHistoryPage extends StatelessWidget {
  const WorkoutHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("My Workouts"),
        backgroundColor: Colors.black,
      ),

      body: ListView.builder(
        itemCount: FeedData.posts.length,
        itemBuilder: (context, index) {

          final workout = FeedData.posts[index];

          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.all(10),

            child: ListTile(
              title: Text(
                workout.title,
                style: const TextStyle(color: Colors.white),
              ),

              subtitle: Text(
                "${workout.exercises.length} exercises",
                style: const TextStyle(color: Colors.grey),
              ),

              onTap: () {

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(workout.title),

                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: workout.exercises
                          .map((e) => Text(e))
                          .toList(),
                    ),

                  ),
                );

              },
            ),
          );

        },
      ),
    );
  }
}