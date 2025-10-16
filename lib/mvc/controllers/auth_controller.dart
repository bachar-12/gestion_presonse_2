import 'dart:async';

import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/users_repository.dart';

class AuthController {
  final AuthRepository _auth;
  final UsersRepository _users;
  const AuthController(this._auth, this._users);

  Future<void> signIn(String email, String password) {
    return _auth.signInWithEmail(email, password);
  }

  Future<void> signOut() => _auth.signOut();

  /// Creates the auth user and persists the profile document in Firestore.
  /// Adds a timeout for the profile write so the UI does not get stuck.
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    Duration profileWriteTimeout = const Duration(seconds: 8),
  }) async {
    final cred = await _auth.signUpWithEmail(email, password);
    final uid = cred.user!.uid;
    final user = AppUser(id: uid, role: role, name: name, email: email);
    await _users.setUser(user).timeout(profileWriteTimeout, onTimeout: () {});
  }
}

