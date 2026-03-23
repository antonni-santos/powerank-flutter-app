import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/Home/home_feed_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/history/workout_history_page.dart';
import 'screens/home/main_navigation.dart';
import 'services/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const PowerankApp(),
    ),
  );
}

class PowerankApp extends StatelessWidget {
  const PowerankApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Powerank',
      theme: ThemeData.light(),       
      darkTheme: ThemeData.dark(),    
      themeMode: themeNotifier.themeMode, 
      home: const MainNavigation(),
    );
  }
}