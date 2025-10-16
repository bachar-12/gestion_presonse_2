import 'package:firebase_auth/firebase_auth.dart';

import '../services/firebase_service.dart';

class AuthRepository {
  bool get _ready => FirebaseService.initialized;
  FirebaseAuth get _auth => FirebaseService.auth;

  Stream<User?> authStateChanges() {
    if (!_ready) return const Stream.empty();
    return _auth.authStateChanges();
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    if (!_ready) {
      throw StateError('Firebase non configuré. Ajoutez google-services.json/Info.plist.');
    }
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    if (!_ready) {
      throw StateError('Firebase non configuré. Ajoutez google-services.json/Info.plist.');
    }
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    if (!_ready) return;
    await _auth.signOut();
  }
}
