import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home/main_navigation.dart';
import 'services/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final themeNotifier = ThemeNotifier();
  await themeNotifier.loadTheme();

  runApp(
    ChangeNotifierProvider.value(
      value: themeNotifier,
      child: const PowerankApp(),
    ),
  );
}

class PowerankApp extends StatelessWidget {
  const PowerankApp({super.key});

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF6F8FB),
      cardColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      dividerColor: isDark ? Colors.white12 : Colors.black12,
      drawerTheme: DrawerThemeData(
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFFF6F8FB),
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.65),
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey[900],
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Powerank',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: themeNotifier.themeMode,
      home: const MainNavigation(),
    );
  }
}
