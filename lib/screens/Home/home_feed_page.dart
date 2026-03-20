import 'package:flutter/material.dart';
import 'package:powerank/screens/workout/create_workout_page.dart';
import 'package:powerank/services/firestore_service.dart';
import 'package:powerank/widgets/workout_post_card.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Powerank"),
        backgroundColor: Colors.black,
      ),

      body: StreamBuilder(
        stream: FirestoreService().getWorkoutsStream(), // 👈 stream em vez de future
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erro: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return const Center(
              child: Text(
                "Nenhum treino encontrado",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final posts = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return WorkoutPostCard(post: posts[index]);
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateWorkoutPage(),
            ),
          );
        },
      ),
    );
  }
}