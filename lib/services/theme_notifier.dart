import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:shared_preferences/shared_preferences.dart';
=======
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

<<<<<<< HEAD
  // 🔥 CARREGAR tema salvo
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? true;

    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // 🔥 ALTERAR e SALVAR
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    await prefs.setBool('isDark', _themeMode == ThemeMode.dark);

=======
  void toggleTheme() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
>>>>>>> ae3cd4e47011cad52817ad96d225c007f6712ec8
    notifyListeners();
  }
}