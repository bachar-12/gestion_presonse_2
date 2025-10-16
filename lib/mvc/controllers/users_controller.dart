import '../../data/models/app_user.dart';
import '../../data/repositories/users_repository.dart';

class UsersController {
  final UsersRepository _users;
  const UsersController(this._users);

  Stream<List<AppUser>> watchByRole(String role) => _users.watchUsersByRole(role);
  Stream<int> watchCountByRole(String role) => watchByRole(role).map((e) => e.length);
  Stream<AppUser?> watchUser(String uid) => _users.watchUser(uid);
  Future<List<AppUser>> findByEmails(List<String> emails) => _users.findByEmails(emails);
  Future<void> setUser(AppUser user) => _users.setUser(user);
}
