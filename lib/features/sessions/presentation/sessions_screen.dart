import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/constants/roles.dart';
import '../../../core/widgets/role_badge.dart';
import '../../../core/widgets/admin_drawer.dart';
import '../../../mvc/providers.dart';
import '../../../data/models/class_model.dart';
import '../../../data/models/session_model.dart';
import '../../../data/providers.dart';
import 'session_editor_dialog.dart';

class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({super.key});

  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen> {
  String? _selectedClassId;

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentUserDocProvider).value;
    final bool isAdmin = me?.role == UserRoles.admin;
    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final classesCtrl = ref.watch(classesControllerProvider);
    final sessionsCtrl = ref.watch(sessionsControllerProvider);

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
        final selectedId = _selectedClassId;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Séances'),
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
                            value: selectedId,
                            items: [
                              for (final c in classes)
                                DropdownMenuItem(value: c.id, child: Text(c.name)),
                            ],
                            onChanged: (v) {
                              setState(() => _selectedClassId = v);
                            },
                            decoration: const InputDecoration(
                              labelText: 'Classe',
                              prefixIcon: Icon(Icons.class_outlined),
                            ),
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<List<SessionModel>>(
                            stream: sessionsCtrl.watchForClass(selectedId!),
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final sessions = snap.data!;
                              if (sessions.isEmpty) {
                                return const Center(child: Text('Aucune séance'));
                              }
                              return ListView.separated(
                                itemCount: sessions.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, i) {
                                  final s = sessions[i];
                                  return ListTile(
                                    title: Text('${s.startAt} → ${s.endAt}'),
                                    subtitle: Text('Code: ${s.code}'),
                                    trailing: Wrap(
                                      spacing: 8,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined),
                                          onPressed: () => showSessionEditorDialog(
                                              context, ref,
                                              classId: selectedId, existing: s),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline),
                                          onPressed: () async {
                                            final ok = await showDialog<bool>(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text('Supprimer la séance ?'),
                                                content: const Text('Cette action est définitive.'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: const Text('Annuler'),
                                                  ),
                                                  FilledButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    child: const Text('Supprimer'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (ok == true) {
                                              await sessionsCtrl.remove(s.id);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
          floatingActionButton: classes.isEmpty
              ? null
              : FloatingActionButton(
                  onPressed: () => showSessionEditorDialog(context, ref, classId: selectedId!),
                  child: const Icon(Icons.add),
                ),
        );
      },
    );
  }
}
