import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:powerank/models/workout_post.dart';
import 'package:powerank/services/firestore_service.dart';
import 'package:powerank/widgets/app_drawer.dart';
import 'package:powerank/widgets/notification_menu_button.dart';

class WorkoutHistoryPage extends StatelessWidget {
  const WorkoutHistoryPage({super.key});

  String _exerciseDisplay(dynamic exercise) {
    if (exercise is Map) {
      final name = exercise['name'] ?? '';
      final weight = exercise['weight'] ?? 0;
      final sets = exercise['sets'] ?? 0;
      final reps = exercise['reps'] ?? 0;
      return '$name - ${weight}kg x $sets x $reps';
    }
    return exercise.toString();
  }

  Future<void> _publishWorkout(
    BuildContext context,
    WorkoutPost workout,
  ) async {
    final result = await showModalBottomSheet<_HistoryPublishResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _HistoryPublishSheet(workoutTitle: workout.title),
    );

    if (result == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final username = (userDoc.data()?['username'] ?? 'Utilizador').toString();
    final isPrivate = userDoc.data()?['isPrivate'] == true;

    final urls = <String>[];
    if (result.images.isNotEmpty) {
      for (int i = 0; i < result.images.length; i++) {
        final ref = FirebaseStorage.instance.ref().child(
          'history_posts/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        );
        await ref.putFile(
          File(result.images[i].path),
          SettableMetadata(contentType: 'image/jpeg'),
        );
        urls.add(await ref.getDownloadURL());
      }
    }

    await FirebaseFirestore.instance.collection('feed_posts').add({
      'title': workout.title,
      'userId': user.uid,
      'username': username,
      'templateId': workout.id,
      'authorIsPrivate': isPrivate,
      'exercises': workout.exercises,
      'imageUrls': urls,
      'totalWeight': workout.totalWeight,
      'likes': 0,
      'likedBy': [],
      'comments': 0,
      'createdAt': Timestamp.now(),
    });

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Treino publicado no feed!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = textColor.withOpacity(0.7);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Treinos criados'),
        actions: [
          Builder(
            builder: (context) => NotificationMenuButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: StreamBuilder<List<WorkoutPost>>(
        stream: FirestoreService().getWorkoutTemplatesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Nenhum treino criado ainda',
                style: TextStyle(color: textColor),
              ),
            );
          }

          final workouts = snapshot.data!;

          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
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
                    '${workout.exercises.length} exercícios',
                    style: TextStyle(color: mutedColor),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.publish, color: Colors.green),
                    onPressed: () => _publishWorkout(context, workout),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(workout.title),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: workout.exercises.map((e) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(_exerciseDisplay(e)),
                              );
                            }).toList(),
                          ),
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

class _HistoryPublishResult {
  final List<XFile> images;

  _HistoryPublishResult({required this.images});
}

class _HistoryPublishSheet extends StatefulWidget {
  final String workoutTitle;

  const _HistoryPublishSheet({required this.workoutTitle});

  @override
  State<_HistoryPublishSheet> createState() => _HistoryPublishSheetState();
}

class _HistoryPublishSheetState extends State<_HistoryPublishSheet> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];

  Future<void> _pickFromGallery() async {
    final images = await _picker.pickMultiImage(imageQuality: 80);
    if (images.isEmpty) return;
    setState(() => _images.addAll(images));
  }

  Future<void> _pickFromCamera() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (image == null) return;
    setState(() => _images.add(image));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Publicar ${widget.workoutTitle}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text('Queres adicionar fotos a esta publicação?'),
              const SizedBox(height: 10),
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
              if (_images.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return Image.file(
                        File(_images[index].path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, _HistoryPublishResult(images: _images)),
                  child: const Text('Publicar no feed'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
