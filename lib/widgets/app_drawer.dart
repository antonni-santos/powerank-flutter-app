<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/screens/Login/login_screen.dart';
import 'package:powerank/screens/notifications/notifications_page.dart';
import 'package:powerank/screens/rank/rank_page.dart';
import 'package:powerank/screens/settings/settings_page.dart';
import 'package:powerank/screens/social/followers_page.dart';
=======
import 'package:flutter/material.dart';
import 'package:powerank/screens/Login/login_screen.dart';
import 'package:powerank/screens/social/followers_page.dart';
import 'package:powerank/screens/rank/rank_page.dart';
import 'package:powerank/screens/settings/settings_page.dart';
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
import 'package:powerank/services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

<<<<<<< HEAD
  Widget _buildNotificationsIcon(BuildContext context, String? uid) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.onSurface;
    final drawerBackground =
        theme.drawerTheme.backgroundColor ?? theme.scaffoldBackgroundColor;

    if (uid == null) {
      return Icon(Icons.notifications_none, color: iconColor);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .snapshots(),
      builder: (context, snapshot) {
        final hasUnread = snapshot.data?.docs.any((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['isRead'] != true;
            }) ??
            false;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.notifications_none, color: iconColor),
            if (hasUnread)
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7DD3FC),
                    shape: BoxShape.circle,
                    border: Border.all(color: drawerBackground, width: 1.2),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Drawer(
      backgroundColor:
          theme.drawerTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
=======
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(color: theme.dividerColor),
            ListTile(
              leading: _buildNotificationsIcon(context, currentUser?.uid),
              title: Text(
                'Notificacoes',
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: textColor),
              title: Text(
                'Definicoes',
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.people, color: textColor),
              title: Text(
                'Seguidores',
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FollowersPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.amber),
              title: Text(
                'Rank',
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RankPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: textColor),
              title: Text(
                'Partilhar perfil',
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            Divider(color: theme.dividerColor),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
=======

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
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text("Definições",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsPage()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.people, color: Colors.white),
              title: const Text("Seguidores",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const FollowersPage()));
              },
            ),

            ListTile(
              leading:
                  const Icon(Icons.emoji_events, color: Colors.amber),
              title: const Text("Rank",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const RankPage()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
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
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout",
                  style: TextStyle(color: Colors.red)),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
              onTap: () async {
                Navigator.pop(context);
                await AuthService().logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
<<<<<<< HEAD
                    builder: (_) => const LoginPage(),
                  ),
=======
                      builder: (_) => const LoginPage()),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
                  (route) => false,
                );
              },
            ),
<<<<<<< HEAD
            const SizedBox(height: 10),
=======

            const SizedBox(height: 10),

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
}
  
=======
}
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
