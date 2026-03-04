import 'database_helper.dart';

class AuthService {

  // REGISTRO
  Future<bool> register(
      String username,
      String email,
      String password) async {

    final db = await DatabaseHelper.instance.database;

    try {
      await db.insert('users', {
        'username': username,
        'email': email,
        'password': password,
      });

      return true; // sucesso
    } catch (e) {
      return false; // erro (ex: email já existe)
    }
  }

  // LOGIN
  Future<bool> login(
      String email,
      String password) async {

    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    return result.isNotEmpty;
  }
}