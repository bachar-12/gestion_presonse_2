import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import 'controllers/auth_controller.dart';
import 'controllers/classes_controller.dart';
import 'controllers/users_controller.dart';
import 'controllers/sessions_controller.dart';
import 'controllers/attendance_controller.dart';

final authControllerProvider = Provider<AuthController>((ref) =>
    AuthController(ref.read(authRepositoryProvider), ref.read(usersRepositoryProvider)));

final usersControllerProvider = Provider<UsersController>((ref) =>
    UsersController(ref.read(usersRepositoryProvider)));

final classesControllerProvider = Provider<ClassesController>((ref) =>
    ClassesController(ref.read(classesRepositoryProvider)));

final sessionsControllerProvider = Provider<SessionsController>((ref) =>
    SessionsController(ref.read(sessionsRepositoryProvider)));

final attendanceControllerProvider = Provider<AttendanceController>((ref) =>
    AttendanceController(ref.read(attendanceRepositoryProvider)));
