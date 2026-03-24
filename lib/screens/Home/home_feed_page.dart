<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/screens/workout/create_workout_page.dart';
import 'package:powerank/services/firestore_service.dart';
import 'package:powerank/widgets/app_drawer.dart';
import 'package:powerank/widgets/notification_menu_button.dart';
import 'package:powerank/widgets/workout_post_card.dart';
=======
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:powerank/screens/workout/create_workout_page.dart';
import 'package:powerank/services/firestore_service.dart';
import 'package:powerank/widgets/workout_post_card.dart';
import 'package:powerank/widgets/app_drawer.dart'; 
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
<<<<<<< HEAD
=======

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
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
<<<<<<< HEAD
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
=======
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

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
<<<<<<< HEAD
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    await FirebaseFirestore.instance.collection('checkins').doc(user.uid).set({
=======
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    await FirebaseFirestore.instance
        .collection('checkins')
        .doc(user.uid)
        .set({
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
      'dates': FieldValue.arrayUnion([todayStr]),
    }, SetOptions(merge: true));

    setState(() {
      _checkedInToday = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
<<<<<<< HEAD
        content: Text('Treino de hoje marcado!'),
=======
        content: Text("✅ Treino de hoje marcado!"),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Powerank'),
        actions: [
          Builder(
            builder: (context) => NotificationMenuButton(
=======
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Powerank"),
        backgroundColor: Colors.black,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
<<<<<<< HEAD
      endDrawer: const AppDrawer(),
      body: Column(
        children: [
=======

      endDrawer: const AppDrawer(),

      body: Column(
        children: [

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
          Container(
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
<<<<<<< HEAD
                backgroundColor:
                    _checkedInToday ? Colors.grey[600] : Colors.green,
                foregroundColor: Colors.white,
=======
                backgroundColor: _checkedInToday ? Colors.grey[800] : Colors.green,
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                _checkedInToday ? Icons.check_circle : Icons.fitness_center,
<<<<<<< HEAD
              ),
              label: Text(
                _checkedInToday
                    ? 'Treino de hoje ja marcado'
                    : 'Marcar treino de hoje',
                style: const TextStyle(
=======
                color: Colors.white,
              ),
              label: Text(
                _checkedInToday
                    ? "Treino de hoje já marcado ✅"
                    : "🏋️ Marcar treino de hoje",
                style: const TextStyle(
                  color: Colors.white,
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _checkedInToday ? null : _doCheckIn,
            ),
          ),
<<<<<<< HEAD
=======

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
          Expanded(
            child: StreamBuilder(
              stream: FirestoreService().getWorkoutsStream(),
              builder: (context, snapshot) {
<<<<<<< HEAD
=======

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
<<<<<<< HEAD
                      'Erro: ${snapshot.error}',
                      style: TextStyle(color: textColor),
=======
                      "Erro: ${snapshot.error}",
                      style: const TextStyle(color: Colors.white),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                    ),
                  );
                }

                if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
<<<<<<< HEAD
                  return Center(
                    child: Text(
                      'Nenhum treino encontrado',
                      style: TextStyle(color: textColor),
=======
                  return const Center(
                    child: Text(
                      "Nenhum treino encontrado",
                      style: TextStyle(color: Colors.white),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
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
<<<<<<< HEAD
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: theme.colorScheme.onPrimary,
        ),
=======

        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateWorkoutPage()),
          );
        },
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
