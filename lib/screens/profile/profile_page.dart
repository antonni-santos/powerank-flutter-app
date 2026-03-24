<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/services/firestore_service.dart';
import 'package:powerank/widgets/app_drawer.dart';
import 'package:powerank/widgets/notification_menu_button.dart';
=======
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../Login/login_screen.dart';
import '../settings/settings_page.dart';
import '../social/followers_page.dart';
import '../rank/rank_page.dart';
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
<<<<<<< HEAD
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = textColor.withOpacity(0.7);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          Builder(
            builder: (context) => NotificationMenuButton(
=======

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Profile"),
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
=======

      endDrawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Padding(
                padding: EdgeInsets.all(20),
                child: Text("Menu",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ),

              const Divider(color: Colors.grey),

              ListTile(
                leading:
                    const Icon(Icons.settings, color: Colors.white),
                title: const Text("Definições",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsPage()));
                },
              ),

              ListTile(
                leading:
                    const Icon(Icons.people, color: Colors.white),
                title: const Text("Seguidores",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FollowersPage()));
                },
              ),

              ListTile(
                leading: const Icon(Icons.emoji_events,
                    color: Colors.amber),
                title: const Text("Rank",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RankPage()));
                },
              ),

              ListTile(
                leading:
                    const Icon(Icons.share, color: Colors.white),
                title: const Text("Partilhar perfil",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: partilhar perfil
                },
              ),

              const Spacer(),

              const Divider(color: Colors.grey),

              ListTile(
                leading:
                    const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout",
                    style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await AuthService().logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),

              const SizedBox(height: 10),

            ],
          ),
        ),
      ),

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
      body: FutureBuilder<String>(
        future: FirestoreService().getUsername(user?.uid ?? ''),
        builder: (context, snapshot) {
          final username = snapshot.data ?? 'Utilizador';

          return Column(
            children: [
<<<<<<< HEAD
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 40,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                username,
                style: TextStyle(
                  fontSize: 20,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
=======

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
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              // ESTATÍSTICAS
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .snapshots(),
                builder: (context, snap) {
<<<<<<< HEAD
                  final data = snap.data?.data() as Map<String, dynamic>?;
                  final followers = List.from(data?['followers'] ?? []).length;
                  final following = List.from(data?['following'] ?? []).length;
=======
                  final data =
                      snap.data?.data() as Map<String, dynamic>?;
                  final followers =
                      List.from(data?['followers'] ?? []).length;
                  final following =
                      List.from(data?['following'] ?? []).length;
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
<<<<<<< HEAD
=======

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                      StreamBuilder<List>(
                        stream: FirestoreService().getWorkoutsStream(),
                        builder: (context, workSnap) {
                          final count = workSnap.data?.length ?? 0;
                          return Column(
                            children: [
<<<<<<< HEAD
                              Text(
                                '$count',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Treinos',
                                style: TextStyle(color: mutedColor),
                              ),
=======
                              Text("$count",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              const Text("Treinos",
                                  style:
                                      TextStyle(color: Colors.grey)),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                            ],
                          );
                        },
                      ),
<<<<<<< HEAD
                      Column(
                        children: [
                          Text(
                            '$followers',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Seguidores',
                            style: TextStyle(color: mutedColor),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '$following',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'A seguir',
                            style: TextStyle(color: mutedColor),
                          ),
                        ],
                      ),
=======

                      Column(
                        children: [
                          Text("$followers",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const Text("Seguidores",
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),

                      Column(
                        children: [
                          Text("$following",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const Text("A seguir",
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                    ],
                  );
                },
              ),
<<<<<<< HEAD
=======

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
            ],
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
