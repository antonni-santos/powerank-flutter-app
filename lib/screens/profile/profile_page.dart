import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:powerank/models/workout_post.dart';
import 'package:powerank/screens/social/user_connections_page.dart';
import 'package:powerank/services/firestore_service.dart';
import 'package:powerank/utils/workout_metrics.dart';
import 'package:powerank/widgets/app_drawer.dart';
import 'package:powerank/widgets/notification_menu_button.dart';
import 'package:powerank/widgets/progress_area_chart.dart';
import 'package:share_plus/share_plus.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  bool _uploadingPhoto = false;

  Future<void> _showPhotoOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.pop(context);
                _setProfilePhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.pop(context);
                _setProfilePhoto(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setProfilePhoto(ImageSource source) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    setState(() => _uploadingPhoto = true);

    try {
      final ref = FirebaseStorage.instance.ref().child(
        'profile_images/${currentUser.uid}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await ref.putFile(
        File(pickedFile.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'photoUrl': downloadUrl});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil atualizada!')),
      );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _shareProfile(BuildContext context, String username) async {
    final box = context.findRenderObject() as RenderBox?;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await Share.share(
      'Segue-me no Powerank!\n\nUsername: @$username\nID: ${user.uid}\n\nProcura este username dentro do app.',
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  Widget _buildAvatar(ThemeData theme, String photoUrl) {
    final hasPhoto = photoUrl.isNotEmpty;

    return GestureDetector(
      onTap: _uploadingPhoto ? null : _showPhotoOptions,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 46,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
            backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
            child: !hasPhoto
                ? Icon(Icons.person, size: 40, color: theme.colorScheme.primary)
                : null,
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(
                Icons.camera_alt,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
          if (_uploadingPhoto)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(46),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCounter({
    required String label,
    required String value,
    required VoidCallback? onTap,
    required Color textColor,
    required Color mutedColor,
  }) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: mutedColor)),
        ],
      ),
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = textColor.withOpacity(0.7);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Faz login para ver o perfil')),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final doc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get();
              final username = (doc.data()?['username'] ?? 'Utilizador')
                  .toString();
              if (!context.mounted) return;
              await _shareProfile(context, username);
            },
          ),
          Builder(
            builder: (context) => NotificationMenuButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          final data = userSnapshot.data?.data() as Map<String, dynamic>?;
          final username = (data?['username'] ?? 'Utilizador').toString();
          final photoUrl = (data?['photoUrl'] ?? '').toString();
          final followers = List<String>.from(data?['followers'] ?? []).length;
          final following = List<String>.from(data?['following'] ?? []).length;
          final isPrivate = data?['isPrivate'] == true;

          return FutureBuilder<List<dynamic>>(
            future: Future.wait([
              FirestoreService().getUserCheckInCount(user.uid),
              FirestoreService().getUserWorkoutStats(user.uid),
              FirestoreService().getUserProgress(user.uid),
              FirestoreService().getUserPublishedWorkoutCount(user.uid),
              FirestoreService().getUserTotalExerciseCount(user.uid),
            ]),
            builder: (context, statsSnapshot) {
              final workoutStats = statsSnapshot.hasData
                  ? statsSnapshot.data![1] as UserWorkoutStats
                  : const UserWorkoutStats(
                      totalWeight: 0,
                      totalLikes: 0,
                      checkIns: 0,
                    );
              final streak = statsSnapshot.hasData
                  ? statsSnapshot.data![0] as int
                  : 0;
              final totalWeight = workoutStats.totalWeight;
              final points = workoutStats.points;
              final progress = statsSnapshot.hasData
                  ? List<Map<String, dynamic>>.from(
                      statsSnapshot.data![2] as List,
                    )
                  : <Map<String, dynamic>>[];
              final publishedCount = statsSnapshot.hasData
                  ? statsSnapshot.data![3] as int
                  : 0;
              final totalExercises = statsSnapshot.hasData
                  ? statsSnapshot.data![4] as int
                  : 0;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildAvatar(theme, photoUrl),
                    const SizedBox(height: 16),
                    Text(
                      username,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isPrivate
                            ? Colors.orange.withOpacity(0.12)
                            : Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isPrivate ? 'Conta privada' : 'Conta publica',
                        style: TextStyle(
                          color: isPrivate ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Toca na foto para alterar',
                      style: TextStyle(color: mutedColor, fontSize: 12),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: StreamBuilder<List<WorkoutPost>>(
                            stream: FirestoreService()
                                .getWorkoutTemplatesStream(),
                            builder: (context, workSnap) {
                              final count = workSnap.data?.length ?? 0;
                              return _buildCounter(
                                label: 'Treinos',
                                value: '$count',
                                onTap: null,
                                textColor: textColor,
                                mutedColor: mutedColor,
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildCounter(
                            label: 'Seguidores',
                            value: '$followers',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserConnectionsPage(
                                    userId: user.uid,
                                    username: username,
                                    initialTabIndex: 0,
                                  ),
                                ),
                              );
                            },
                            textColor: textColor,
                            mutedColor: mutedColor,
                          ),
                        ),
                        Expanded(
                          child: _buildCounter(
                            label: 'A seguir',
                            value: '$following',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserConnectionsPage(
                                    userId: user.uid,
                                    username: username,
                                    initialTabIndex: 1,
                                  ),
                                ),
                              );
                            },
                            textColor: textColor,
                            mutedColor: mutedColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumo',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _MetricChip(
                                label: 'Sequencia',
                                value: '$streak dias',
                              ),
                              _MetricChip(
                                label: 'Treinos publicados',
                                value: '$publishedCount',
                              ),
                              _MetricChip(
                                label: 'Exercicios totais',
                                value: '$totalExercises',
                              ),
                              _MetricChip(
                                label: 'Peso total',
                                value:
                                    '${WorkoutMetrics.formatWeight(totalWeight)} kg',
                              ),
                              _MetricChip(
                                label: 'Pontuacao',
                                value: '$points pts',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Evolucao do treino',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Mostra a carga total agregada por registo publicado.',
                            style: TextStyle(color: mutedColor, fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          ProgressAreaChart(progress: progress),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
