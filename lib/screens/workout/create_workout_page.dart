import 'package:flutter/material.dart';
import '../../data/feed_data.dart';
import '../../models/workout_post.dart';

class CreateWorkoutPage extends StatefulWidget {
  const CreateWorkoutPage({super.key});

  @override
  State<CreateWorkoutPage> createState() => _CreateWorkoutPageState();
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {

  final TextEditingController workoutNameController = TextEditingController();
  final TextEditingController exerciseController = TextEditingController();

  List<String> exercises = [];

  void addExercise() {
    if (exerciseController.text.isNotEmpty) {
      setState(() {
        exercises.add(exerciseController.text);
        exerciseController.clear();
      });
    }
  }

void saveWorkout() {

  if (workoutNameController.text.isEmpty || exercises.isEmpty) {
    return;
  }

  FeedData.posts.insert(
    0,
    WorkoutPost(
      user: "You",
      time: "now",
      title: workoutNameController.text,
      exercises: exercises,
      likes: 0,
      comments: 0,
    ),
  );

  Navigator.pop(context);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Workout"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Workout Name",
              style: TextStyle(fontSize: 18),
            ),

            TextField(
              controller: workoutNameController,
              decoration: const InputDecoration(
                hintText: "Example: Chest Day",
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Exercises",
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: exerciseController,
              decoration: InputDecoration(
                hintText: "Add exercise",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: addExercise,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(exercises[index]),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveWorkout,
                child: const Text("Save Workout"),
              ),
            )
          ],
        ),
      ),
    );
  }
}