import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // REGISTER
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
      });

      return true;
    } catch (e) {
      print("Erro no register: $e"); 
      return false;
    }
  }

  // LOGIN
  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      print("Erro no login: $e"); 
      return false;
    }
  }

  // RESET PASSWORD
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Email de recuperação enviado para: $email"); 
    } catch (e) {
      print("Erro no resetPassword: $e"); 
      rethrow; 
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}