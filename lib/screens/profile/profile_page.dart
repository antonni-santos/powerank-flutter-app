import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../Login/login_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.black,
      ),

      body: FutureBuilder<String>(
        future: FirestoreService().getUsername(user?.uid ?? ''),
        builder: (context, snapshot) {

          final username = snapshot.data ?? 'Utilizador';

          return Column(
            children: [

              const SizedBox(height: 30),

              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 40),
              ),

              const SizedBox(height: 15),

              Text(
                username, 
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  StreamBuilder<List>(
                    stream: FirestoreService().getWorkoutsStream(),
                    builder: (context, snap) {
                      final count = snap.data?.length ?? 0;
                      return Column(
                        children: [
                          Text(
                            "$count",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Total Workouts",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      );
                    },
                  ),

                  const Column(
                    children: [
                      Text(
                        "120",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Followers", style: TextStyle(color: Colors.grey)),
                    ],
                  ),

                  const Column(
                    children: [
                      Text(
                        "80",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Following", style: TextStyle(color: Colors.grey)),
                    ],
                  ),

                ],
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                onPressed: () async {
                  await AuthService().logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: const Text("Logout"),
              ),

            ],
          );
        },
      ),
    );
  }
}