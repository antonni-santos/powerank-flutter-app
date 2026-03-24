<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/models/workout_post.dart';
import 'package:powerank/services/notification_service.dart';
=======
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/workout_post.dart';
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

class CommentsPage extends StatefulWidget {
  final WorkoutPost post;

  const CommentsPage({super.key, required this.post});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
<<<<<<< HEAD
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
=======

  final TextEditingController controller = TextEditingController();

  CollectionReference get commentsRef => FirebaseFirestore.instance
      .collection('workouts')
      .doc(widget.post.id)
      .collection('comments');

  void sendComment() async {
    if (controller.text.trim().isEmpty) return;
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
<<<<<<< HEAD
    final username = (userDoc.data()?['username'] ?? 'Utilizador').toString();

    await commentsRef.add({
      'text': commentText,
=======
    final username = userDoc.data()?['username'] ?? 'Utilizador';

   
    await commentsRef.add({
      'text': controller.text.trim(),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
      'userId': user.uid,
      'username': username,
      'createdAt': FieldValue.serverTimestamp(),
    });

<<<<<<< HEAD
=======
  
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
    await FirebaseFirestore.instance
        .collection('workouts')
        .doc(widget.post.id)
        .update({'comments': FieldValue.increment(1)});

<<<<<<< HEAD
    await NotificationService().sendMentionNotificationsFromText(
      text: commentText,
      senderId: user.uid,
      senderUsername: username,
      sourceType: 'comment',
      workoutId: widget.post.id,
    );

=======
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
<<<<<<< HEAD
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
=======

      appBar: AppBar(
        title: const Text("Comments"),
        backgroundColor: Colors.black,
      ),

      body: Column(
        children: [

          // LISTA DE COMENTÁRIOS
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: commentsRef
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
<<<<<<< HEAD
=======

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
<<<<<<< HEAD
                      'Sem comentarios ainda',
=======
                      "Sem comentários ainda",
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final comments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final data = comments[index].data() as Map<String, dynamic>;
<<<<<<< HEAD

                    return ListTile(
                      title: Text(
                        (data['username'] ?? 'Utilizador').toString(),
=======
                    return ListTile(
                      title: Text(
                        data['username'] ?? 'Utilizador',
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
<<<<<<< HEAD
                        (data['text'] ?? '').toString(),
=======
                        data['text'] ?? '',
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                );
              },
            ),
          ),
<<<<<<< HEAD
=======

          // INPUT
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
<<<<<<< HEAD
=======

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
<<<<<<< HEAD
                      hintText: 'Add a comment',
=======
                      hintText: "Add a comment",
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
<<<<<<< HEAD
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: sendComment,
                ),
              ],
            ),
          ),
=======

                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: sendComment, // guarda no Firestore
                ),

              ],
            ),
          ),

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
        ],
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
