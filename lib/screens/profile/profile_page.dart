import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/services/firestore_service.dart';
import 'package:powerank/widgets/app_drawer.dart';
import 'package:powerank/widgets/notification_menu_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: FutureBuilder<String>(
        future: FirestoreService().getUsername(user?.uid ?? ''),
        builder: (context, snapshot) {
          final username = snapshot.data ?? 'Utilizador';

          return Column(
            children: [
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
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .snapshots(),
                builder: (context, snap) {
                  final data = snap.data?.data() as Map<String, dynamic>?;
                  final followers = List.from(data?['followers'] ?? []).length;
                  final following = List.from(data?['following'] ?? []).length;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      StreamBuilder<List>(
                        stream: FirestoreService().getWorkoutsStream(),
                        builder: (context, workSnap) {
                          final count = workSnap.data?.length ?? 0;
                          return Column(
                            children: [
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
                            ],
                          );
                        },
                      ),
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
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
