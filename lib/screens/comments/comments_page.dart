import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/models/workout_post.dart';
import 'package:powerank/services/notification_service.dart';

class CommentsPage extends StatefulWidget {
  final WorkoutPost post;

  const CommentsPage({super.key, required this.post});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController controller = TextEditingController();

  CollectionReference<Map<String, dynamic>> get commentsRef =>
      FirebaseFirestore.instance
          .collection('workouts')
          .doc(widget.post.id)
          .collection('comments');

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> sendComment() async {
    final commentText = controller.text.trim();
    if (commentText.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final username = (userDoc.data()?['username'] ?? 'Utilizador').toString();

    await commentsRef.add({
      'text': commentText,
      'userId': user.uid,
      'username': username,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('workouts')
        .doc(widget.post.id)
        .update({'comments': FieldValue.increment(1)});

    await NotificationService().sendMentionNotificationsFromText(
      text: commentText,
      senderId: user.uid,
      senderUsername: username,
      sourceType: 'comment',
      workoutId: widget.post.id,
    );

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: commentsRef
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Sem comentarios ainda',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final comments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final data = comments[index].data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(
                        (data['username'] ?? 'Utilizador').toString(),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        (data['text'] ?? '').toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Add a comment',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: sendComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
