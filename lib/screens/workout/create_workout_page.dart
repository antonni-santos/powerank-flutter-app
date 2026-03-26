import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

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
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return (doc.data()?['username'] ?? 'Utilizador').toString();
  }

  Future<void> _pickFromGallery() async {
    final images = await _picker.pickMultiImage(imageQuality: 80);
    if (images.isEmpty) return;

    setState(() {
      _selectedImages.addAll(images);
    });
  }

  Future<void> _pickFromCamera() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (image == null) return;

    setState(() {
      _selectedImages.add(image);
    });
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages({
    required String workoutId,
    required String userId,
  }) async {
    final storage = FirebaseStorage.instance;
    final imageUrls = <String>[];

    for (int i = 0; i < _selectedImages.length; i++) {
      final image = _selectedImages[i];
      final ref = storage.ref().child(
            'workout_images/$userId/$workoutId/${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
          );

      await ref.putFile(
        File(image.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadUrl = await ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }

    return imageUrls;
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

    setState(() {
      _saving = true;
    });

    try {
      final workoutTitle = workoutNameController.text.trim();
      final username = await _getCurrentUsername(user.uid);

      final totalWeight = exercises.fold<double>(
        0,
        (sum, e) => sum + (e.weight * e.sets * e.reps),
      );

      final workoutRef =
          FirebaseFirestore.instance.collection('workouts').doc();

      final imageUrls = await _uploadImages(
        workoutId: workoutRef.id,
        userId: user.uid,
      );

      await workoutRef.set({
        'title': workoutTitle,
        'userId': user.uid,
        'exercises': exercises.map((e) => e.toMap()).toList(),
        'imageUrls': imageUrls,
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao guardar treino: $e'),
        ),
      );
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
              'Fotos do treino',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeria'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFromCamera,
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Camera'),
                  ),
                ),
              ],
            ),
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_selectedImages[index].path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => _removeSelectedImage(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
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
                onPressed: _saving ? null : saveWorkout,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Workout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
