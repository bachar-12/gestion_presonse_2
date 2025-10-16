import '../../data/models/session_model.dart';
import '../../data/repositories/sessions_repository.dart';

class SessionsController {
  final SessionsRepository _repo;
  const SessionsController(this._repo);

  Future<String> create(SessionModel model) => _repo.createSession(model);
  Future<void> update(SessionModel model) => _repo.updateSession(model);
  Future<void> remove(String id) => _repo.deleteSession(id);
  Stream<List<SessionModel>> watchForClass(String classId) =>
      _repo.watchSessionsForClass(classId);
}
