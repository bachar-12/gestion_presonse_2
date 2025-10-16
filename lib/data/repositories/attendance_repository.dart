import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/attendance_model.dart';
import '../services/firebase_service.dart';

class AttendanceRepository {
  final FirebaseFirestore _db = FirebaseService.db;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('attendances');

  Future<String> markAttendance(AttendanceModel model) async {
    final doc = await _col.add(model.toMap());
    return doc.id;
  }

  /// Upsert attendance by (sessionId, studentId)
  Future<void> setAttendanceStatus({
    required String sessionId,
    required String studentId,
    required String status,
    required DateTime markedAt,
  }) async {
    final existing = await _col
        .where('sessionId', isEqualTo: sessionId)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();
    if (existing.docs.isEmpty) {
      await _col.add({
        'sessionId': sessionId,
        'studentId': studentId,
        'status': status,
        'markedAt': markedAt.toIso8601String(),
      });
    } else {
      await existing.docs.first.reference.update({
        'status': status,
        'markedAt': markedAt.toIso8601String(),
      });
    }
  }

  Stream<List<AttendanceModel>> watchForSession(String sessionId) {
    return _col
        .where('sessionId', isEqualTo: sessionId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AttendanceModel.fromMap(d.id, d.data()))
            .toList());
  }
}
