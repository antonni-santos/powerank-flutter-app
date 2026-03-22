import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../Login/login_screen.dart';
import '../settings/settings_page.dart';
import '../friends/friends_page.dart';
import '../rank/rank_page.dart'; 

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
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),

      endDrawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Menu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Divider(color: Colors.grey),

              // DEFINIÇÕES
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text("Definições", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),

              // AMIGOS
              ListTile(
                leading: const Icon(Icons.people, color: Colors.white),
                title: const Text("Amigos", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FriendsPage()),
                  );
                },
              ),

              // RANK 
              ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.amber),
                title: const Text("Rank", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RankPage()),
                  );
                },
              ),

              // PARTILHAR PERFIL
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text("Partilhar perfil", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: partilhar perfil
                },
              ),

              const Spacer(),

              const Divider(color: Colors.grey),

              // LOGOUT
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout", style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await AuthService().logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),

              const SizedBox(height: 10),

            ],
          ),
        ),
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

            ],
          );
        },
      ),
    );
  }
}