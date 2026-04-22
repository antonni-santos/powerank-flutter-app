import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/models/workout_post.dart';
import 'package:powerank/screens/comments/comments_page.dart';
import 'package:powerank/screens/social/public_profile_page.dart';
import 'package:powerank/screens/workout/workout_details_page.dart';
import 'package:powerank/utils/workout_metrics.dart';
import 'package:powerank/widgets/workout_share_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkoutPostCard extends StatefulWidget {
  final WorkoutPost post;

  const WorkoutPostCard({super.key, required this.post});

  @override
  State<WorkoutPostCard> createState() => _WorkoutPostCardState();
}

class _WorkoutPostCardState extends State<WorkoutPostCard> {
  static const int _previewExerciseCount = 5;

  late bool liked;
  late int likesCount;

  @override
  void initState() {
    super.initState();
    _syncFromPost();
  }

  @override
  void didUpdateWidget(WorkoutPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.likes != widget.post.likes ||
        oldWidget.post.likedBy != widget.post.likedBy) {
      _syncFromPost();
    }
  }

  void _syncFromPost() {
    final user = FirebaseAuth.instance.currentUser;
    liked = user != null && widget.post.likedBy.contains(user.uid);
    likesCount = widget.post.likes;
  }

  Future<void> toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('feed_posts')
        .doc(widget.post.id);

    if (liked) {
      setState(() {
        liked = false;
        likesCount--;
      });
      await docRef.update({
        'likedBy': FieldValue.arrayRemove([user.uid]),
        'likes': FieldValue.increment(-1),
      });
    } else {
      setState(() {
        liked = true;
        likesCount++;
      });
      await docRef.update({
        'likedBy': FieldValue.arrayUnion([user.uid]),
        'likes': FieldValue.increment(1),
      });
    }
  }

  Future<void> deleteWorkout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (widget.post.userId != user.uid) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir post'),
        content: const Text(
          'Tens a certeza que queres excluir este post do feed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('feed_posts')
        .doc(widget.post.id)
        .delete();
  }

  void _openShareSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => WorkoutShareSheet(post: widget.post),
    );
  }

  Future<void> _openVideoUrl(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);

    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O link do video esta invalido.')),
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nao foi possivel abrir o video.')),
      );
    }
  }

  Future<void> _openVideos() async {
    final videoUrls = widget.post.videoUrls;
    if (videoUrls.isEmpty) return;

    if (videoUrls.length == 1) {
      await _openVideoUrl(videoUrls.first);
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Abrir videos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...List.generate(videoUrls.length, (index) {
              return ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: Text('Video ${index + 1}'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openVideoUrl(videoUrls[index]);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _openWorkoutDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkoutDetailsPage(post: widget.post)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final post = widget.post;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser != null && post.userId == currentUser.uid;
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = textColor.withOpacity(0.7);
    final previewExercises = post.exercises
        .take(_previewExerciseCount)
        .toList();
    final remainingExercises = post.exercises.length - previewExercises.length;

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: isOwner
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PublicProfilePage(userId: post.userId),
                        ),
                      );
                    },
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      post.user.isNotEmpty ? post.user[0].toUpperCase() : '?',
                      style: TextStyle(color: theme.colorScheme.onPrimary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.user,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        post.time,
                        style: TextStyle(color: mutedColor, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _openWorkoutDetails,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${post.exercises.length} exercicios - ${WorkoutMetrics.formatWeight(post.totalWeight)} kg',
                      style: TextStyle(color: mutedColor, fontSize: 13),
                    ),
                    if (post.imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: post.imageUrls.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                post.imageUrls[index],
                                width: MediaQuery.of(context).size.width * 0.75,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  color: Colors.black12,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: previewExercises.map((exercise) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            WorkoutMetrics.exerciseDisplay(exercise),
                            style: TextStyle(color: mutedColor),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      remainingExercises > 0
                          ? '+ $remainingExercises exercicio(s). Toque para ver o treino completo.'
                          : 'Toque para ver os detalhes do treino.',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (post.videoUrls.isNotEmpty) ...[
              const SizedBox(height: 10),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _openVideos,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.videocam, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${post.videoUrls.length} video(s) anexado(s)',
                              style: TextStyle(color: textColor),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              post.videoUrls.length == 1
                                  ? 'Toque para abrir o video'
                                  : 'Toque para escolher um video',
                              style: TextStyle(color: mutedColor, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.open_in_new, color: theme.colorScheme.primary),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _openWorkoutDetails,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.open_in_full,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Abrir detalhes do treino',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? Colors.red : textColor,
                      ),
                      onPressed: toggleLike,
                    ),
                    Text('$likesCount', style: TextStyle(color: textColor)),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.comment, color: textColor),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommentsPage(post: post),
                          ),
                        );
                      },
                    ),
                    Text(
                      '${post.comments}',
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.send, color: textColor),
                      onPressed: _openShareSheet,
                    ),
                  ],
                ),
                if (isOwner)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: deleteWorkout,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
