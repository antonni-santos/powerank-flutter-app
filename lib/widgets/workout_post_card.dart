import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/models/workout_post.dart';
import 'package:powerank/screens/comments/comments_page.dart';

class WorkoutPostCard extends StatefulWidget {
  final WorkoutPost post;

  const WorkoutPostCard({super.key, required this.post});

  @override
  State<WorkoutPostCard> createState() => _WorkoutPostCardState();
}

class _WorkoutPostCardState extends State<WorkoutPostCard> {
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

    final docRef =
        FirebaseFirestore.instance.collection('feed_posts').doc(widget.post.id);

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
        content: const Text('Tens a certeza que queres excluir este post do feed?'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final post = widget.post;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser != null && post.userId == currentUser.uid;
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = textColor.withOpacity(0.7);

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    post.user.isNotEmpty ? post.user[0] : '?',
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
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              post.title,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.imageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        post.imageUrls[index],
                        width: MediaQuery.of(context).size.width * 0.75,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: MediaQuery.of(context).size.width * 0.75,
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
              children: post.exercises.map((exercise) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    _exerciseDisplay(exercise),
                    style: TextStyle(color: mutedColor),
                  ),
                );
              }).toList(),
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
                    const SizedBox(width: 20),
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
                    Text('${post.comments}', style: TextStyle(color: textColor)),
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
