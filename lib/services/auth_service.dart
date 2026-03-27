import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum LoginResult {
  success,
  userNotFound,
  wrongPassword,
  invalidEmail,
  error,
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> register(String email, String password, String username) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(result.user!.uid)
          .set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'photoUrl': '',
        'isPrivate': false,
        'followers': <String>[],
        'following': <String>[],
        'pushTokens': <String>[],
      });

      return true;
    } catch (e) {
      print('Erro no register: $e');
      return false;
    }
  }

  Future<LoginResult> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return LoginResult.success;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return LoginResult.userNotFound;
        case 'wrong-password':
        case 'invalid-credential':
          return LoginResult.wrongPassword;
        case 'invalid-email':
          return LoginResult.invalidEmail;
        default:
          print('Erro no login: ${e.code} - ${e.message}');
          return LoginResult.error;
      }
    } catch (e) {
      print('Erro no login: $e');
      return LoginResult.error;
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() async {
    final user = _auth.currentUser;
    if (user != null) {
      final token = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((doc) => doc.data()?['pushTokens']);
      if (token is List && token.isNotEmpty) {}
    }
    await _auth.signOut();
  }

  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Sem utilizador');
    await user.updatePassword(newPassword);
  }
}
