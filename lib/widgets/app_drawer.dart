import 'package:flutter/material.dart';
import 'package:powerank/screens/Login/login_screen.dart';
import 'package:powerank/screens/friends/friends_page.dart';
import 'package:powerank/screens/rank/rank_page.dart';
import 'package:powerank/screens/settings/settings_page.dart';
import 'package:powerank/services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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

            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text("Partilhar perfil", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            const Spacer(),

            const Divider(color: Colors.grey),

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
    );
  }
}