import 'package:flutter/material.dart';
import '../../models/workout_post.dart';

class CommentsPage extends StatefulWidget {

  final WorkoutPost post;

  const CommentsPage({super.key, required this.post});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Comments"),
        backgroundColor: Colors.black,
      ),

      body: Column(
        children: [

          /// LISTA
          Expanded(
            child: ListView.builder(
              itemCount: widget.post.commentsList.length,
              itemBuilder: (context, index) {

                return ListTile(
                  title: Text(
                    widget.post.commentsList[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                );

              },
            ),
          ),

          /// INPUT
          Container(
            padding: const EdgeInsets.all(10),

            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Add a comment",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),

                  onPressed: () {

                    setState(() {

                      widget.post.commentsList.add(controller.text);
                      widget.post.comments++;

                      controller.clear();

                    });

                  },
                )

              ],
            ),
          )

        ],
      ),
    );
  }
}