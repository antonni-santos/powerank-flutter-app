import 'package:flutter/material.dart';
import '../models/workout_post.dart';

class WorkoutPostCard extends StatelessWidget {
  final WorkoutPost post;
  final VoidCallback? onDelete;
  final VoidCallback? onLike;
  final ValueChanged<String>? onEdit;

  const WorkoutPostCard({
    super.key,
    required this.post,
    this.onDelete,
    this.onLike,
    this.onEdit,
  });

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

          // Cabeçalho
          Row(
            children: [
              const CircleAvatar(radius: 18),
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
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Título
          Text(
            post.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // Exercícios
          ...post.exercises.map((e) => Text(
                e,
                style: const TextStyle(color: Colors.grey),
              )),

          const SizedBox(height: 15),

          // Ações
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

     
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.comment, color: Colors.white),
                    onPressed: () {

                      TextEditingController commentController =
                          TextEditingController();

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(

                          title: const Text("Add Comment"),

                          content: TextField(
                            controller: commentController,
                          ),

                          actions: [

                            TextButton(
                              onPressed: () {

                                post.commentList.add(commentController.text);
                                post.comments++;

                                Navigator.pop(context);

                              },
                              child: const Text("Comment"),
                            )

                          ],
                        ),
                      );

                    },
                  ),
                  Text(
                    "${post.likes}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  const Icon(Icons.comment, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(
                    "${post.comments}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),

              // Editar e deletar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      final controller =
                          TextEditingController(text: post.title);

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Edit Workout"),
                          content: TextField(controller: controller),
                          actions: [
                            TextButton(
                              onPressed: () {
                                onEdit?.call(controller.text);
                                Navigator.pop(context);
                              },
                              child: const Text("Save"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),

            ],
          ),

        ],
      ),
    );
  }
}