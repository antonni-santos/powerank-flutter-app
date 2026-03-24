import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/services/notification_service.dart';

class CreateWorkoutPage extends StatefulWidget {
  const CreateWorkoutPage({super.key});

  @override
  State<CreateWorkoutPage> createState() => _CreateWorkoutPageState();
}

class ExerciseEntry {
  String name;
  double weight;
  int sets;
  int reps;

  ExerciseEntry({
    required this.name,
    required this.weight,
    required this.sets,
    required this.reps,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'weight': weight,
        'sets': sets,
        'reps': reps,
      };

  String get display => '$name - ${weight}kg x $sets x $reps';
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {
  final TextEditingController workoutNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();

  final List<ExerciseEntry> exercises = [];

  @override
  void dispose() {
    workoutNameController.dispose();
    nameController.dispose();
    weightController.dispose();
    setsController.dispose();
    repsController.dispose();
    super.dispose();
  }

  Future<String> _getCurrentUsername(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return (doc.data()?['username'] ?? 'Utilizador').toString();
  }

  void addExercise() {
    if (nameController.text.isEmpty ||
        weightController.text.isEmpty ||
        setsController.text.isEmpty ||
        repsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preenche todos os campos do exercicio'),
        ),
      );
      return;
    }

    setState(() {
      exercises.add(
        ExerciseEntry(
          name: nameController.text.trim(),
          weight: double.tryParse(weightController.text) ?? 0,
          sets: int.tryParse(setsController.text) ?? 0,
          reps: int.tryParse(repsController.text) ?? 0,
        ),
      );
      nameController.clear();
      weightController.clear();
      setsController.clear();
      repsController.clear();
    });
  }

  Future<void> saveWorkout() async {
    if (workoutNameController.text.isEmpty || exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adiciona um nome e pelo menos um exercicio'),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final workoutTitle = workoutNameController.text.trim();
    final username = await _getCurrentUsername(user.uid);

    final totalWeight = exercises.fold<double>(
      0,
      (sum, e) => sum + (e.weight * e.sets * e.reps),
    );

    final workoutRef =
        await FirebaseFirestore.instance.collection('workouts').add({
      'title': workoutTitle,
      'userId': user.uid,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'totalWeight': totalWeight,
      'likes': 0,
      'likedBy': [],
      'comments': 0,
      'createdAt': Timestamp.now(),
    });

    await NotificationService().sendMentionNotificationsFromText(
      text: workoutTitle,
      senderId: user.uid,
      senderUsername: username,
      sourceType: 'workout',
      workoutId: workoutRef.id,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workout Name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: workoutNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Example: Chest Day',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Exercise',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nome (ex: Bench Press)',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Peso (kg)',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: setsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Series',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Reps',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: addExercise,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar exercicio'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Total exercises: ${exercises.length}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(exercises[index].display),
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
                child: const Text('Save Workout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
