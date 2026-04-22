import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:powerank/models/workout_post.dart';
import 'package:powerank/services/firestore_service.dart';
import 'package:powerank/utils/workout_metrics.dart';
import 'package:powerank/widgets/app_drawer.dart';
import 'package:powerank/widgets/notification_menu_button.dart';
import 'package:powerank/widgets/workout_share_sheet.dart';

class WorkoutHistoryPage extends StatelessWidget {
  const WorkoutHistoryPage({super.key});

  String _exerciseDisplay(dynamic exercise) {
    return WorkoutMetrics.exerciseDisplay(exercise);
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

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final username = (userDoc.data()?['username'] ?? 'Utilizador').toString();
      final isPrivate = userDoc.data()?['isPrivate'] == true;

      final imageUrls = <String>[];
      for (int i = 0; i < result.images.length; i++) {
        final ref = FirebaseStorage.instance.ref().child(
          'history_posts/${user.uid}/images/${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        );
        await ref.putFile(
          File(result.images[i].path),
          SettableMetadata(contentType: 'image/jpeg'),
        );
        imageUrls.add(await ref.getDownloadURL());
      }

      final videoUrls = <String>[];
      for (int i = 0; i < result.videos.length; i++) {
        final ref = FirebaseStorage.instance.ref().child(
          'history_posts/${user.uid}/videos/${DateTime.now().millisecondsSinceEpoch}_$i.mp4',
        );
        await ref.putFile(
          File(result.videos[i].path),
          SettableMetadata(contentType: 'video/mp4'),
        );
        videoUrls.add(await ref.getDownloadURL());
      }

      await FirebaseFirestore.instance.collection('feed_posts').add({
        'title': workout.title,
        'userId': user.uid,
        'username': username,
        'templateId': workout.id,
        'authorIsPrivate': isPrivate,
        'exercises': workout.exercises,
        'imageUrls': imageUrls,
        'videoUrls': videoUrls,
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
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao publicar no feed: $e')));
    }
  }

  Future<void> _deleteWorkout(BuildContext context, WorkoutPost workout) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar treino'),
        content: Text('Queres eliminar "${workout.title}" do History?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('workout_templates')
        .doc(workout.id)
        .delete();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Treino eliminado do History')),
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
                    '${workout.exercises.length} exercicios',
                    style: TextStyle(color: mutedColor),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => WorkoutShareSheet(post: workout),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.publish, color: Colors.green),
                        onPressed: () => _publishWorkout(context, workout),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteWorkout(context, workout),
                      ),
                    ],
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
  final List<XFile> videos;

  _HistoryPublishResult({required this.images, required this.videos});
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
  final List<XFile> _videos = [];

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

  Future<void> _pickVideoFromGallery() async {
    final video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;
    setState(() => _videos.add(video));
  }

  Future<void> _pickVideoFromCamera() async {
    final video = await _picker.pickVideo(source: ImageSource.camera);
    if (video == null) return;
    setState(() => _videos.add(video));
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
              const Text('Queres adicionar fotos ou videos a esta publicacao?'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Fotos'),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickVideoFromGallery,
                      icon: const Icon(Icons.video_library),
                      label: const Text('Video'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickVideoFromCamera,
                      icon: const Icon(Icons.videocam),
                      label: const Text('Gravar'),
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
              if (_videos.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('${_videos.length} video(s) selecionado(s)'),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    _HistoryPublishResult(images: _images, videos: _videos),
                  ),
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
