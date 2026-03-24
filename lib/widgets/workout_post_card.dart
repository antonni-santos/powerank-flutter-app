<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
=======
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
import 'package:powerank/models/workout_post.dart';
import 'package:powerank/screens/comments/comments_page.dart';

class WorkoutPostCard extends StatefulWidget {
  final WorkoutPost post;

  const WorkoutPostCard({super.key, required this.post});

  @override
  State<WorkoutPostCard> createState() => _WorkoutPostCardState();
}

class _WorkoutPostCardState extends State<WorkoutPostCard> {
<<<<<<< HEAD
=======

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
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

<<<<<<< HEAD
  Future<void> toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef =
        FirebaseFirestore.instance.collection('workouts').doc(widget.post.id);
=======
  void toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('workouts')
        .doc(widget.post.id);
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

    if (liked) {
      setState(() {
        liked = false;
        likesCount--;
      });
      await docRef.update({
<<<<<<< HEAD
        'likedBy': FieldValue.arrayRemove([user.uid]),
        'likes': FieldValue.increment(-1),
=======
        "likedBy": FieldValue.arrayRemove([user.uid]),
        "likes": FieldValue.increment(-1),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
      });
    } else {
      setState(() {
        liked = true;
        likesCount++;
      });
      await docRef.update({
<<<<<<< HEAD
        'likedBy': FieldValue.arrayUnion([user.uid]),
        'likes': FieldValue.increment(1),
=======
        "likedBy": FieldValue.arrayUnion([user.uid]),
        "likes": FieldValue.increment(1),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
      });
    }
  }

<<<<<<< HEAD
  Future<void> deleteWorkout() async {
=======
  void deleteWorkout() async {
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (widget.post.userId != user.uid) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
<<<<<<< HEAD
        title: const Text('Excluir treino'),
        content: const Text('Tens a certeza que queres excluir este treino?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
=======
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
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
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
<<<<<<< HEAD
      return '$name - ${weight}kg x $sets x $reps';
=======
      return '$name — ${weight}kg x $sets x $reps';
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
    }
    return exercise.toString();
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
=======

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
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.user,
<<<<<<< HEAD
                      style: TextStyle(
                        color: textColor,
=======
                      style: const TextStyle(
                        color: Colors.white,
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      post.time,
<<<<<<< HEAD
                      style: TextStyle(
                        color: mutedColor,
=======
                      style: const TextStyle(
                        color: Colors.grey,
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
<<<<<<< HEAD
            const SizedBox(height: 10),
            Text(
              post.title,
              style: TextStyle(
                color: textColor,
=======

            const SizedBox(height: 10),

            // WORKOUT TITLE
            Text(
              post.title,
              style: const TextStyle(
                color: Colors.white,
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
<<<<<<< HEAD
=======

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: post.exercises.map((exercise) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    _exerciseDisplay(exercise),
<<<<<<< HEAD
                    style: TextStyle(color: mutedColor),
=======
                    style: const TextStyle(color: Colors.grey),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                  ),
                );
              }).toList(),
            ),
<<<<<<< HEAD
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
=======

            const SizedBox(height: 12),

            // ACTIONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // LIKE E COMENTÁRIO
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
<<<<<<< HEAD
                        color: liked ? Colors.red : textColor,
=======
                        color: liked ? Colors.red : Colors.white,
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                      ),
                      onPressed: toggleLike,
                    ),
                    Text(
<<<<<<< HEAD
                      '$likesCount',
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: Icon(Icons.comment, color: textColor),
=======
                      "$likesCount",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.comment, color: Colors.white),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
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
<<<<<<< HEAD
                      '${post.comments}',
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
=======
                      "${post.comments}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),

                // BOTÃO EXCLUIR
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                if (isOwner)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: deleteWorkout,
                  ),
<<<<<<< HEAD
              ],
            ),
=======

              ],
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
