import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerank/screens/Login/login_screen.dart';
import 'package:powerank/screens/notifications/notifications_page.dart';
import 'package:powerank/screens/rank/rank_page.dart';
import 'package:powerank/screens/settings/settings_page.dart';
import 'package:powerank/screens/social/followers_page.dart';
import 'package:powerank/services/auth_service.dart';
import 'package:share_plus/share_plus.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

Future<void> _shareProfile(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  final username = (doc.data()?['username'] ?? 'Utilizador').toString();
  final box = context.findRenderObject() as RenderBox?;

  await Share.share(
    'Segue-me no Powerank!\n\nUsername: @$username\nID: ${user.uid}\n\nProcura este username dentro do app.',
    sharePositionOrigin:
        box == null ? null : box.localToGlobal(Offset.zero) & box.size,
  );
}


  Widget _buildNotificationsIcon(BuildContext context, String? uid) {
    if (uid == null) {
      return const Icon(Icons.notifications_none);
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
            const Icon(Icons.notifications_none),
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
                    border: Border.all(color: Colors.white, width: 1.2),
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
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              title: Text('Notificacoes', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: textColor),
              title: Text('Definicoes', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.people, color: textColor),
              title: Text('Seguidores', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FollowersPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.amber),
              title: Text('Rank', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RankPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: textColor),
              title: Text('Partilhar perfil', style: TextStyle(color: textColor)),
              onTap: () async {
                Navigator.pop(context);
                await _shareProfile(context);
              },
            ),
            const Spacer(),
            Divider(color: theme.dividerColor),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await AuthService().logout();
                if (!context.mounted) return;
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
    );
  }
}
