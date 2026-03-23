import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:powerank/screens/workout/create_workout_page.dart';
import 'package:powerank/services/firestore_service.dart';
import 'package:powerank/widgets/workout_post_card.dart';
import 'package:powerank/widgets/app_drawer.dart'; 

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {

  bool _checkedInToday = false;

  @override
  void initState() {
    super.initState();
    _checkIfCheckedInToday();
  }

  Future<void> _checkIfCheckedInToday() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final doc = await FirebaseFirestore.instance
        .collection('checkins')
        .doc(user.uid)
        .get();

    final dates = List<String>.from(doc.data()?['dates'] ?? []);

    setState(() {
      _checkedInToday = dates.contains(todayStr);
    });
  }

  Future<void> _doCheckIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    await FirebaseFirestore.instance
        .collection('checkins')
        .doc(user.uid)
        .set({
      'dates': FieldValue.arrayUnion([todayStr]),
    }, SetOptions(merge: true));

    setState(() {
      _checkedInToday = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Treino de hoje marcado!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Powerank"),
        backgroundColor: Colors.black,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),

      endDrawer: const AppDrawer(),

      body: Column(
        children: [

          Container(
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _checkedInToday ? Colors.grey[800] : Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                _checkedInToday ? Icons.check_circle : Icons.fitness_center,
                color: Colors.white,
              ),
              label: Text(
                _checkedInToday
                    ? "Treino de hoje já marcado ✅"
                    : "🏋️ Marcar treino de hoje",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _checkedInToday ? null : _doCheckIn,
            ),
          ),

          Expanded(
            child: StreamBuilder(
              stream: FirestoreService().getWorkoutsStream(),
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
          ),

        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateWorkoutPage()),
          );
        },
      ),
    );
  }
}