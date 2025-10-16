import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/session_model.dart';
import '../services/firebase_service.dart';

class SessionsRepository {
  final FirebaseFirestore _db = FirebaseService.db;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('sessions');

  Future<String> createSession(SessionModel model) async {
    final doc = await _col.add(model.toMap());
    return doc.id;
  }

  Future<void> updateSession(SessionModel model) async {
    await _col.doc(model.id).update(model.toMap());
  }

  Future<void> deleteSession(String id) async {
    await _col.doc(id).delete();
  }

  Stream<List<SessionModel>> watchSessionsForClass(String classId) {
    return _col
        .where('classId', isEqualTo: classId)
        .orderBy('startAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SessionModel.fromMap(d.id, d.data()))
            .toList());
  }
}
