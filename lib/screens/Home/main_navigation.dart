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
<<<<<<< HEAD
=======

>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final theme = Theme.of(context);
=======

    // 👈 movido para dentro do build
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
    final pages = [
      const HomeFeedPage(),
      const WorkoutHistoryPage(),
      const MessagesListPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
<<<<<<< HEAD
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
=======
        backgroundColor: Colors.black,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
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
<<<<<<< HEAD
}
=======
}
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
