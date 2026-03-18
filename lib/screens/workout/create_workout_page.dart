import 'package:flutter/material.dart';
import '../../data/feed_data.dart';
import '../../models/workout_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  void saveWorkout() async {
    if (workoutNameController.text.isEmpty || exercises.isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser; 

    if (user == null) return; 

    await FirebaseFirestore.instance.collection('workouts').add({
      "title": workoutNameController.text,
      "userId": user.uid,        
      "exercises": exercises,
      "likes": 0,
      "likedBy": [],
      "createdAt": Timestamp.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Workout"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Workout Name",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: workoutNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Example: Chest Day",
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Add Exercise",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: exerciseController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Bench Press 80kg x 8",
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: addExercise,
                  child: const Text("Add"),
                ),

              ],
            ),

            const SizedBox(height: 20),

            Text(
              "Total exercises: ${exercises.length}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(exercises[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            exercises.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveWorkout,
                child: const Text("Save Workout"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}