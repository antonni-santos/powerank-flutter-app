import 'package:flutter/material.dart';
import '../models/workout_post.dart';

class WorkoutPostCard extends StatelessWidget {
  final WorkoutPost post;

  const WorkoutPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              const CircleAvatar(radius: 18),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.user,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  Text(post.time,
                      style: const TextStyle(color: Colors.grey, fontSize: 12))
                ],
              )
            ],
          ),

          const SizedBox(height: 15),

          Text(
            post.title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ...post.exercises.map((e) => Text(
                e,
                style: const TextStyle(color: Colors.grey),
              )),

          const SizedBox(height: 15),

          Row(
            children: [
              const Icon(Icons.favorite_border, color: Colors.grey),
              const SizedBox(width: 6),
              Text("${post.likes}",
                  style: const TextStyle(color: Colors.grey)),

              const SizedBox(width: 20),

              const Icon(Icons.chat_bubble_outline, color: Colors.grey),
              const SizedBox(width: 6),
              Text("${post.comments}",
                  style: const TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}