import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/class_model.dart';
import '../services/firebase_service.dart';

class ClassesRepository {
  final FirebaseFirestore _db = FirebaseService.db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('classes');

  Future<String> createClass(ClassModel model) async {
    final doc = await _col.add(model.toMap());
    return doc.id;
  }

  Future<void> updateClass(ClassModel model) async {
    await _col.doc(model.id).update(model.toMap());
  }

  Future<void> deleteClass(String id) async {
    await _col.doc(id).delete();
  }

  Stream<List<ClassModel>> watchAllClasses() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ClassModel.fromMap(d.id, d.data()))
            .toList());
  }

  Stream<List<ClassModel>> watchClassesForTeacher(String teacherId) {
    return _col
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ClassModel.fromMap(d.id, d.data()))
            .toList());
  }
}
