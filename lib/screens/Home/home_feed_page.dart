import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/models/workout_post.dart';
import 'package:powerank/screens/workout/create_workout_page.dart';
import 'package:powerank/services/firestore_service.dart';
import 'package:powerank/widgets/app_drawer.dart';
import 'package:powerank/widgets/notification_menu_button.dart';
import 'package:powerank/widgets/workout_post_card.dart';

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
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final doc = await FirebaseFirestore.instance
        .collection('checkins')
        .doc(user.uid)
        .get();

    final dates = List<String>.from(doc.data()?['dates'] ?? []);

    if (!mounted) return;
    setState(() {
      _checkedInToday = dates.contains(todayStr);
    });
  }

  Future<void> _doCheckIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    await FirebaseFirestore.instance.collection('checkins').doc(user.uid).set({
      'dates': FieldValue.arrayUnion([todayStr]),
    }, SetOptions(merge: true));

    if (!mounted) return;
    setState(() {
      _checkedInToday = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Treino de hoje marcado!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Powerank'),
        actions: [
          Builder(
            builder: (context) => NotificationMenuButton(
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
                backgroundColor:
                    _checkedInToday ? Colors.grey[600] : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                _checkedInToday ? Icons.check_circle : Icons.fitness_center,
              ),
              label: Text(
                _checkedInToday
                    ? 'Treino de hoje ja marcado'
                    : 'Marcar treino de hoje',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _checkedInToday ? null : _doCheckIn,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<WorkoutPost>>(
              stream: FirestoreService().getWorkoutsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro: ${snapshot.error}',
                      style: TextStyle(color: textColor),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum treino encontrado',
                      style: TextStyle(color: textColor),
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
        child: Icon(
          Icons.add,
          color: theme.colorScheme.onPrimary,
        ),
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
