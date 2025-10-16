import '../../data/models/attendance_model.dart';
import '../../data/repositories/attendance_repository.dart';

class AttendanceController {
  final AttendanceRepository _repo;
  const AttendanceController(this._repo);

  Future<String> mark(AttendanceModel model) => _repo.markAttendance(model);
  Stream<List<AttendanceModel>> watchForSession(String sessionId) =>
      _repo.watchForSession(sessionId);

  Future<void> setStatus({
    required String sessionId,
    required String studentId,
    required String status,
  }) => _repo.setAttendanceStatus(
        sessionId: sessionId,
        studentId: studentId,
        status: status,
        markedAt: DateTime.now().toUtc(),
      );
}
