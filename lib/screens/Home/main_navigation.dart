import 'package:flutter/material.dart';
import '../history/workout_history_page.dart';
import '../profile/profile_page.dart';
import '../messages/messages_list_page.dart';
import 'home_feed_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = [
      const HomeFeedPage(),
      const WorkoutHistoryPage(),
      const MessagesListPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            theme.bottomNavigationBarTheme.backgroundColor ?? theme.cardColor,
        selectedItemColor:
            theme.bottomNavigationBarTheme.selectedItemColor ??
                theme.colorScheme.primary,
        unselectedItemColor:
            theme.bottomNavigationBarTheme.unselectedItemColor ??
                theme.colorScheme.onSurface.withOpacity(0.65),
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Feed",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Mensagens",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
