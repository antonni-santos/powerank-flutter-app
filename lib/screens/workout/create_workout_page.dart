<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/services/notification_service.dart';
=======
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

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
<<<<<<< HEAD
        'name': name,
        'weight': weight,
        'sets': sets,
        'reps': reps,
      };

  String get display => '$name - ${weight}kg x $sets x $reps';
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {
=======
    'name': name,
    'weight': weight,
    'sets': sets,
    'reps': reps,
  };

  String get display => '$name — ${weight}kg x $sets x $reps';
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
  final TextEditingController workoutNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();

<<<<<<< HEAD
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
=======
  List<ExerciseEntry> exercises = [];
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

  void addExercise() {
    if (nameController.text.isEmpty ||
        weightController.text.isEmpty ||
        setsController.text.isEmpty ||
        repsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
        const SnackBar(
          content: Text('Preenche todos os campos do exercicio'),
        ),
=======
        const SnackBar(content: Text("Preenche todos os campos do exercício")),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
      );
      return;
    }

    setState(() {
<<<<<<< HEAD
      exercises.add(
        ExerciseEntry(
          name: nameController.text.trim(),
          weight: double.tryParse(weightController.text) ?? 0,
          sets: int.tryParse(setsController.text) ?? 0,
          reps: int.tryParse(repsController.text) ?? 0,
        ),
      );
=======
      exercises.add(ExerciseEntry(
        name: nameController.text.trim(),
        weight: double.tryParse(weightController.text) ?? 0,
        sets: int.tryParse(setsController.text) ?? 0,
        reps: int.tryParse(repsController.text) ?? 0,
      ));
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
      nameController.clear();
      weightController.clear();
      setsController.clear();
      repsController.clear();
    });
  }

<<<<<<< HEAD
  Future<void> saveWorkout() async {
    if (workoutNameController.text.isEmpty || exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adiciona um nome e pelo menos um exercicio'),
        ),
=======
  void saveWorkout() async {
    if (workoutNameController.text.isEmpty || exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Adiciona um nome e pelo menos um exercício")),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

<<<<<<< HEAD
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
=======
    final totalWeight = exercises.fold<double>(
      0, (sum, e) => sum + (e.weight * e.sets * e.reps),
    );

    await FirebaseFirestore.instance.collection('workouts').add({
      "title": workoutNameController.text.trim(),
      "userId": user.uid,
      "exercises": exercises.map((e) => e.toMap()).toList(), 
      "totalWeight": totalWeight, 
      "likes": 0,
      "likedBy": [],
      "comments": 0,
      "createdAt": Timestamp.now(),
    });

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text('Create Workout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workout Name',
=======
        title: const Text("Create Workout"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // NOME DO TREINO
            const Text(
              "Workout Name",
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: workoutNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
<<<<<<< HEAD
                hintText: 'Example: Chest Day',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Exercise',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
=======
                hintText: "Example: Chest Day",
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Add Exercise",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // NOME DO EXERCÍCIO
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
<<<<<<< HEAD
                hintText: 'Nome (ex: Bench Press)',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
=======
                hintText: "Nome (ex: Bench Press)",
              ),
            ),

            const SizedBox(height: 8),

            // PESO, SÉRIES, REPS
            Row(
              children: [

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
<<<<<<< HEAD
                      hintText: 'Peso (kg)',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
=======
                      hintText: "Peso (kg)",
                    ),
                  ),
                ),

                const SizedBox(width: 8),

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                Expanded(
                  child: TextField(
                    controller: setsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
<<<<<<< HEAD
                      hintText: 'Series',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
=======
                      hintText: "Séries",
                    ),
                  ),
                ),

                const SizedBox(width: 8),

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                Expanded(
                  child: TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
<<<<<<< HEAD
                      hintText: 'Reps',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
=======
                      hintText: "Reps",
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 8),

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: addExercise,
                icon: const Icon(Icons.add),
<<<<<<< HEAD
                label: const Text('Adicionar exercicio'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Total exercises: ${exercises.length}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
=======
                label: const Text("Adicionar exercício"),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "Total exercises: ${exercises.length}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 8),

            // LISTA DE EXERCÍCIOS
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
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
<<<<<<< HEAD
            const SizedBox(height: 10),
=======

            const SizedBox(height: 10),

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveWorkout,
<<<<<<< HEAD
                child: const Text('Save Workout'),
              ),
            ),
=======
                child: const Text("Save Workout"),
              ),
            ),

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
