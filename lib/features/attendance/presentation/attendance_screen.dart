import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/constants/roles.dart';
import '../../../core/widgets/role_badge.dart';
import '../../../core/widgets/admin_drawer.dart';
import '../../../mvc/providers.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/attendance_model.dart';
import '../../../data/models/class_model.dart';
import '../../../data/models/session_model.dart';
import '../../../data/providers.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  String? _selectedClassId;
  String? _selectedSessionId;

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentUserDocProvider).value;
    final bool isAdmin = me?.role == UserRoles.admin;
    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final classesCtrl = ref.watch(classesControllerProvider);
    final sessionsCtrl = ref.watch(sessionsControllerProvider);
    // Controllers used in child widgets; nothing to do here

    final classesStream = isAdmin
        ? classesCtrl.watchAll()
        : classesCtrl.watchForTeacher(uid);

    return StreamBuilder<List<ClassModel>>(
      stream: classesStream,
      builder: (context, classesSnap) {
        final classes = classesSnap.data ?? const <ClassModel>[];
        if (classes.isNotEmpty && (_selectedClassId == null ||
            !classes.any((c) => c.id == _selectedClassId))) {
          _selectedClassId = classes.first.id;
        }
        final selectedClassId = _selectedClassId;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Présence'),
            actions: [
              const RoleBadge(),
              if (!isAdmin)
                IconButton(
                  tooltip: 'Déconnexion',
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await ref.read(authControllerProvider).signOut();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                ),
            ],
          ),
          drawer: isAdmin ? const AdminDrawer() : null,
          body: classesSnap.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : classes.isEmpty
                  ? const Center(child: Text('Aucune classe'))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: DropdownButtonFormField<String>(
                            value: selectedClassId,
                            items: [
                              for (final c in classes)
                                DropdownMenuItem(value: c.id, child: Text(c.name)),
                            ],
                            onChanged: (v) {
                              setState(() {
                                _selectedClassId = v;
                                _selectedSessionId = null;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Classe',
                              prefixIcon: Icon(Icons.class_outlined),
                            ),
                          ),
                        ),
                        if (selectedClassId != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: StreamBuilder<List<SessionModel>>(
                              stream: sessionsCtrl.watchForClass(selectedClassId),
                              builder: (context, sessSnap) {
                                final sessions = sessSnap.data ?? const <SessionModel>[];
                                if (sessions.isNotEmpty && (_selectedSessionId == null ||
                                    !sessions.any((s) => s.id == _selectedSessionId))) {
                                  _selectedSessionId = sessions.first.id;
                                }
                                return DropdownButtonFormField<String>(
                                  value: _selectedSessionId,
                                  items: [
                                    for (final s in sessions)
                                      DropdownMenuItem(
                                        value: s.id,
                                        child: Text('${s.startAt} → ${s.endAt}'),
                                      ),
                                  ],
                                  onChanged: (v) => setState(() => _selectedSessionId = v),
                                  decoration: const InputDecoration(
                                    labelText: 'Séance',
                                    prefixIcon: Icon(Icons.event_outlined),
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: selectedClassId == null || _selectedSessionId == null
                              ? const Center(child: Text('Choisissez une classe et une séance'))
                              : _AttendanceList(
                                  classId: selectedClassId,
                                  sessionId: _selectedSessionId!,
                                ),
                        ),
                      ],
                    ),
        );
      },
    );
  }
}

class _AttendanceList extends ConsumerWidget {
  const _AttendanceList({required this.classId, required this.sessionId});
  final String classId;
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesCtrl = ref.watch(classesControllerProvider);
    final usersCtrl = ref.watch(usersControllerProvider);
    final attendanceCtrl = ref.watch(attendanceControllerProvider);
    return StreamBuilder<List<ClassModel>>(
      stream: classesCtrl.watchAll(),
      builder: (context, classesSnap) {
        final clazz = classesSnap.data?.firstWhere(
          (c) => c.id == classId,
          orElse: () => ClassModel(
              id: '', name: '', teacherId: '', studentIds: const [], createdAt: DateTime.fromMillisecondsSinceEpoch(0)),
        );
        final studentIds = clazz?.studentIds ?? const <String>[];
        return StreamBuilder<List<AttendanceModel>>(
          stream: attendanceCtrl.watchForSession(sessionId),
          builder: (context, attSnap) {
            final records = {for (final a in (attSnap.data ?? const <AttendanceModel>[])) a.studentId: a};
            if (studentIds.isEmpty) {
              return const Center(child: Text('Aucun étudiant dans cette classe'));
            }
            return ListView.separated(
              itemCount: studentIds.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final sid = studentIds[i];
                return StreamBuilder<AppUser?>(
                  stream: usersCtrl.watchUser(sid),
                  builder: (context, userSnap) {
                    final u = userSnap.data;
                    final rec = records[sid];
                    final status = rec?.status ?? 'absent';
                    final present = status == 'present';
                    return ListTile(
                      title: Text(u?.name ?? sid),
                      subtitle: Text(u?.email ?? ''),
                      trailing: Switch(
                        value: present,
                        onChanged: (v) async {
                          await attendanceCtrl.setStatus(
                            sessionId: sessionId,
                            studentId: sid,
                            status: v ? 'present' : 'absent',
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
