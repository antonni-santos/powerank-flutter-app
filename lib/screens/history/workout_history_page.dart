import 'package:flutter/material.dart';
import 'package:powerank/services/firestore_service.dart';
import 'package:powerank/models/workout_post.dart';

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

      body: StreamBuilder<List<WorkoutPost>>(
        stream: FirestoreService().getWorkoutsStream(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum treino encontrado",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final workouts = snapshot.data!;

          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {

              final workout = workouts[index];

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
          );
        },
      ),
    );
  }
}