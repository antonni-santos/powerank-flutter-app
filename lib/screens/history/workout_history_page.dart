import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:powerank/models/workout_post.dart';
import 'package:powerank/services/firestore_service.dart';
import 'package:powerank/widgets/app_drawer.dart';
import 'package:powerank/widgets/notification_menu_button.dart';
=======
import 'package:powerank/services/firestore_service.dart';
import 'package:powerank/models/workout_post.dart';
import 'package:powerank/widgets/app_drawer.dart';
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

class WorkoutHistoryPage extends StatelessWidget {
  const WorkoutHistoryPage({super.key});

  String _exerciseDisplay(dynamic exercise) {
    if (exercise is Map) {
      final name = exercise['name'] ?? '';
      final weight = exercise['weight'] ?? 0;
      final sets = exercise['sets'] ?? 0;
      final reps = exercise['reps'] ?? 0;
<<<<<<< HEAD
      return '$name - ${weight}kg x $sets x $reps';
=======
      return '$name — ${weight}kg x $sets x $reps';
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
    }
    return exercise.toString();
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = textColor.withOpacity(0.7);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Workouts'),
        actions: [
          Builder(
            builder: (context) => NotificationMenuButton(
=======
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("My Workouts"),
        backgroundColor: Colors.black,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
<<<<<<< HEAD
      endDrawer: const AppDrawer(),
      body: StreamBuilder<List<WorkoutPost>>(
        stream: FirestoreService().getWorkoutsStream(),
        builder: (context, snapshot) {
=======

      endDrawer: const AppDrawer(), 

      body: StreamBuilder<List<WorkoutPost>>(
        stream: FirestoreService().getWorkoutsStream(),
        builder: (context, snapshot) {

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
<<<<<<< HEAD
            return Center(
              child: Text(
                'Nenhum treino encontrado',
                style: TextStyle(color: textColor),
=======
            return const Center(
              child: Text(
                "Nenhum treino encontrado",
                style: TextStyle(color: Colors.white),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
              ),
            );
          }

          final workouts = snapshot.data!;

          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
<<<<<<< HEAD
              final workout = workouts[index];

              return Card(
                color: theme.cardColor,
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    workout.title,
                    style: TextStyle(color: textColor),
                  ),
                  subtitle: Text(
                    '${workout.exercises.length} exercises',
                    style: TextStyle(color: mutedColor),
=======

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
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(workout.title),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
<<<<<<< HEAD
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: workout.exercises
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(_exerciseDisplay(e)),
                                ),
                              )
=======
                          children: workout.exercises
                              .map((e) => Text(
                                    _exerciseDisplay(e),
                                    style: const TextStyle(color: Colors.black),
                                  ))
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
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
<<<<<<< HEAD
}
=======
}
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
