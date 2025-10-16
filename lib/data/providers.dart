import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models/app_user.dart';
import 'repositories/auth_repository.dart';
import 'repositories/users_repository.dart';
import 'repositories/classes_repository.dart';
import 'repositories/sessions_repository.dart';
import 'repositories/attendance_repository.dart';
import 'services/firebase_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final usersRepositoryProvider = Provider<UsersRepository>((ref) => UsersRepository());
final classesRepositoryProvider = Provider<ClassesRepository>((ref) => ClassesRepository());
final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) => SessionsRepository());
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) => AttendanceRepository());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserDocProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return const Stream.empty();
  }
  return ref.watch(usersRepositoryProvider).watchUser(user.uid);
});

final firebaseInitializedProvider = FutureProvider<bool>((ref) async {
  return FirebaseService.ensureInitialized();
});
