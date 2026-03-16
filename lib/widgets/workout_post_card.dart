import 'package:flutter/material.dart';
import '../models/workout_post.dart';
import '../screens/comments/comments_page.dart';

class WorkoutPostCard extends StatefulWidget {
  final WorkoutPost post;

  const WorkoutPostCard({super.key, required this.post});

  @override
  State<WorkoutPostCard> createState() => _WorkoutPostCardState();
}

class _WorkoutPostCardState extends State<WorkoutPostCard> {

  bool liked = false;

  @override
  Widget build(BuildContext context) {

    final post = widget.post;

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 16),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// USER INFO
            Row(
              children: [

                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    post.user[0],
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
                    )

                  ],
                )

              ],
            ),

            const SizedBox(height: 10),

            /// WORKOUT TITLE
            Text(
              post.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            /// EXERCISES
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: post.exercises.map((exercise) {

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),

                  child: Text(
                    exercise,
                    style: const TextStyle(color: Colors.grey),
                  ),
                );

              }).toList(),
            ),

            const SizedBox(height: 12),

            /// ACTIONS
            Row(
              children: [

                /// LIKE BUTTON
                IconButton(
                  icon: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.red : Colors.white,
                  ),

                  onPressed: () {

                    setState(() {

                      liked = !liked;

                      if (liked) {
                        post.likes++;
                      } else {
                        post.likes--;
                      }

                    });

                  },
                ),

                Text(
                  "${post.likes}",
                  style: const TextStyle(color: Colors.white),
                ),

                const SizedBox(width: 20),

                /// COMMENT BUTTON
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

          ],
        ),
      ),
    );
  }
}