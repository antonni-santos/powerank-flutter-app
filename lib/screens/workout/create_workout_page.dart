import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/data/exercise_suggestions.dart';
import 'package:powerank/utils/workout_metrics.dart';

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

  String get display =>
      '$name - ${WorkoutMetrics.formatWeight(weight)}kg x $sets x $reps';
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {
  final TextEditingController workoutNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();

  final List<ExerciseEntry> exercises = [];
  List<ExerciseSuggestionItem> suggestions = [];
  bool _saving = false;

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
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return (doc.data()?['username'] ?? 'Utilizador').toString();
  }

  void _updateSuggestions(String query) {
    setState(() {
      suggestions = ExerciseSuggestions.search(query);
    });
  }

  void _selectSuggestion(String name) {
    setState(() {
      nameController.text = name;
      suggestions = [];
    });
  }

  void addExercise() {
    if (nameController.text.isEmpty ||
        weightController.text.isEmpty ||
        setsController.text.isEmpty ||
        repsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preenche todos os campos do exercício')),
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
      suggestions = [];
    });
  }

  Future<void> saveWorkout() async {
    if (workoutNameController.text.isEmpty || exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adiciona um nome e pelo menos um exercício'),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _saving = true;
    });

    try {
      final username = await _getCurrentUsername(user.uid);

      final totalWeight = exercises.fold<double>(0, (acc, e) => acc + e.weight);

      await FirebaseFirestore.instance.collection('workout_templates').add({
        'title': workoutNameController.text.trim(),
        'userId': user.uid,
        'username': username,
        'exercises': exercises.map((e) => e.toMap()).toList(),
        'imageUrls': [],
        'videoUrls': [],
        'totalWeight': totalWeight,
        'likes': 0,
        'likedBy': [],
        'comments': 0,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao guardar treino: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar treino')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nome do treino',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: workoutNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: Peito e Triceps',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Adicionar exercício',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nome (ex: remada, ombros, supino...)',
              ),
              onChanged: _updateSuggestions,
            ),
            if (suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 6),
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).cardColor,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final item = suggestions[index];
                    return ListTile(
                      dense: true,
                      title: Text(item.name),
                      subtitle: Text(item.muscle),
                      onTap: () => _selectSuggestion(item.name),
                    );
                  },
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
                label: const Text('Adicionar exercício'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Total de exercícios: ${exercises.length}',
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
                onPressed: _saving ? null : saveWorkout,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar treino'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
