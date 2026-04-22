import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum LoginResult {
  success,
  userNotFound,
  wrongPassword,
  invalidEmail,
  cancelled,
  googleConfigurationError,
  accountExistsWithDifferentProvider,
  error,
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  String _fallbackUsername(User user, {String? preferredUsername}) {
    final explicit = preferredUsername?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;

    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = user.email?.trim() ?? '';
    if (email.contains('@')) {
      final localPart = email.split('@').first.trim();
      if (localPart.isNotEmpty) return localPart;
    }

    return 'Utilizador';
  }

  Future<void> _ensureUserDocument(
    User user, {
    String? preferredUsername,
  }) async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final snapshot = await userRef.get();
    final data = snapshot.data() ?? {};
    final resolvedUsername = _fallbackUsername(
      user,
      preferredUsername: preferredUsername,
    );

    if (!snapshot.exists) {
      await userRef.set({
        'username': resolvedUsername,
        'email': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'photoUrl': user.photoURL ?? '',
        'isPrivate': false,
        'followers': <String>[],
        'following': <String>[],
        'friends': <String>[],
        'pushTokens': <String>[],
      });
      return;
    }

    final updates = <String, dynamic>{};

    if ((data['username'] ?? '').toString().trim().isEmpty) {
      updates['username'] = resolvedUsername;
    }
    if ((data['email'] ?? '').toString().trim().isEmpty && user.email != null) {
      updates['email'] = user.email;
    }
    if ((data['photoUrl'] ?? '').toString().trim().isEmpty &&
        user.photoURL != null) {
      updates['photoUrl'] = user.photoURL;
    }
    if (!data.containsKey('isPrivate')) {
      updates['isPrivate'] = false;
    }
    if (!data.containsKey('followers')) {
      updates['followers'] = <String>[];
    }
    if (!data.containsKey('following')) {
      updates['following'] = <String>[];
    }
    if (!data.containsKey('friends')) {
      updates['friends'] = <String>[];
    }
    if (!data.containsKey('pushTokens')) {
      updates['pushTokens'] = <String>[];
    }

    if (updates.isNotEmpty) {
      await userRef.set(updates, SetOptions(merge: true));
    }
  }

  Future<bool> register(String email, String password, String username) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _ensureUserDocument(result.user!, preferredUsername: username);

      return true;
    } catch (e) {
      debugPrint('Erro no register: $e');
      return false;
    }
  }

  Future<LoginResult> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _ensureUserDocument(credential.user!);
      }

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
          debugPrint('Erro no login: ${e.code} - ${e.message}');
          return LoginResult.error;
      }
    } catch (e) {
      debugPrint('Erro no login: $e');
      return LoginResult.error;
    }
  }

  Future<LoginResult> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      if (!_googleSignIn.supportsAuthenticate()) {
        return LoginResult.error;
      }

      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
        return LoginResult.error;
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user == null) return LoginResult.error;

      await _ensureUserDocument(user);
      return LoginResult.success;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return LoginResult.cancelled;
      }
      if (e.code == GoogleSignInExceptionCode.clientConfigurationError ||
          e.code == GoogleSignInExceptionCode.providerConfigurationError) {
        debugPrint('Configuracao do Google Sign-In invalida: ${e.description}');
        return LoginResult.googleConfigurationError;
      }

      debugPrint('Erro no login Google: ${e.code} - ${e.description}');
      return LoginResult.error;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        return LoginResult.accountExistsWithDifferentProvider;
      }

      debugPrint('Erro no login Google: ${e.code} - ${e.message}');
      return LoginResult.error;
    } catch (e) {
      debugPrint('Erro no login Google: $e');
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

    if (_googleInitialized) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Sem utilizador');
    await user.updatePassword(newPassword);
  }
}
