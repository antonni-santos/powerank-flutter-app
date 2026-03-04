import 'package:flutter/material.dart';
import 'screens/Login/login_screen.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PoweRank',
      theme: ThemeData(fontFamily: "SF-Pro-Text"),
      home: const LoginPage(),
    );
  }
}
