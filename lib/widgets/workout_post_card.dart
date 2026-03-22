import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  void toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('workouts')
        .doc(widget.post.id);

    if (liked) {
      setState(() {
        liked = false;
        likesCount--;
      });
      await docRef.update({
        "likedBy": FieldValue.arrayRemove([user.uid]),
        "likes": FieldValue.increment(-1),
      });
    } else {
      setState(() {
        liked = true;
        likesCount++;
      });
      await docRef.update({
        "likedBy": FieldValue.arrayUnion([user.uid]),
        "likes": FieldValue.increment(1),
      });
    }
  }

  void deleteWorkout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (widget.post.userId != user.uid) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Excluir treino"),
        content: const Text("Tens a certeza que queres excluir este treino?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('workouts')
        .doc(widget.post.id)
        .delete();
  }

  String _exerciseDisplay(dynamic exercise) {
    if (exercise is Map) {
      final name = exercise['name'] ?? '';
      final weight = exercise['weight'] ?? 0;
      final sets = exercise['sets'] ?? 0;
      final reps = exercise['reps'] ?? 0;
      return '$name — ${weight}kg x $sets x $reps';
    }
    return exercise.toString();
  }

  @override
  Widget build(BuildContext context) {

    final post = widget.post;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser != null && post.userId == currentUser.uid;

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 16),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // USER INFO
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    post.user.isNotEmpty ? post.user[0] : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.user,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      post.time,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // WORKOUT TITLE
            Text(
              post.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: post.exercises.map((exercise) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    _exerciseDisplay(exercise),
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // ACTIONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // LIKE E COMENTÁRIO
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? Colors.red : Colors.white,
                      ),
                      onPressed: toggleLike,
                    ),
                    Text(
                      "$likesCount",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.comment, color: Colors.white),
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
                      "${post.comments}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),

                // BOTÃO EXCLUIR
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