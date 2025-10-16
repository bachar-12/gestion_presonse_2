import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../services/firebase_service.dart';

class UsersRepository {
  bool get _ready => FirebaseService.initialized;

  FirebaseFirestore get _db => FirebaseService.db;
  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);
  Query<Map<String, dynamic>> _byRole(String role) =>
      _db.collection('users').where('role', isEqualTo: role);
  Query<Map<String, dynamic>> _byEmailIn(List<String> emails) =>
      _db.collection('users').where('email', whereIn: emails);

  Future<void> setUser(AppUser user) async {
    if (!_ready) {
      throw StateError('Firebase non configuré.');
    }
    await _doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  Future<AppUser?> getUser(String uid) async {
    if (!_ready) return null;
    final snap = await _doc(uid).get();
    if (!snap.exists) return null;
    return AppUser.fromMap(snap.id, snap.data()!);
  }

  Stream<AppUser?> watchUser(String uid) {
    if (!_ready) return const Stream.empty();
    return _doc(uid).snapshots().map((s) => s.data() == null
        ? null
        : AppUser.fromMap(s.id, s.data()!));
  }

  Stream<List<AppUser>> watchUsersByRole(String role) {
    if (!_ready) return const Stream.empty();
    return _byRole(role).snapshots().map((snap) => snap.docs
        .map((d) => AppUser.fromMap(d.id, d.data()))
        .toList());
  }

  Future<List<AppUser>> getUsersByRole(String role) async {
    if (!_ready) return [];
    final snap = await _byRole(role).get();
    return snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList();
  }

  Future<List<AppUser>> findByEmails(List<String> emails) async {
    if (!_ready || emails.isEmpty) return [];
    // Firestore whereIn max is 10 values per query.
    const int chunk = 10;
    final List<AppUser> out = [];
    for (int i = 0; i < emails.length; i += chunk) {
      final part = emails.sublist(i, i + chunk > emails.length ? emails.length : i + chunk);
      final snap = await _byEmailIn(part).get();
      out.addAll(snap.docs.map((d) => AppUser.fromMap(d.id, d.data())));
    }
    return out;
  }
}
