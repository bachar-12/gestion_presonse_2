import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/constants/roles.dart';
import '../../../core/widgets/role_badge.dart';
import '../../../core/widgets/admin_drawer.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/class_model.dart';
import '../../../data/providers.dart';
import '../../../mvc/providers.dart';
import 'class_editor_dialog.dart';

class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserDocProvider).value;
    final classesCtrl = ref.watch(classesControllerProvider);
    final usersCtrl = ref.watch(usersControllerProvider);

    final bool isAdmin = me?.role == UserRoles.admin;
    final String uid = ref.watch(authStateProvider).value?.uid ?? '';

    final stream = isAdmin
        ? classesCtrl.watchAll()
        : classesCtrl.watchForTeacher(uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
        // All admin-only actions moved to Drawer to avoid overflow on small screens.
        actions: const [RoleBadge()],
      ),
      // Show drawer for admins only. This groups counters, navigation and logout.
      drawer: isAdmin ? const AdminDrawer() : null,
      body: StreamBuilder<List<ClassModel>>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final classes = snapshot.data!;
          if (classes.isEmpty) {
            return const Center(child: Text('Aucune classe'));
          }
          return ListView.separated(
            itemCount: classes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final c = classes[index];
              return ListTile(
                title: Text(c.name),
                subtitle: StreamBuilder<AppUser?>(
                  stream: usersCtrl.watchUser(c.teacherId),
                  builder: (context, snap) {
                    final t = snap.data;
                    final teacherLabel = t == null ? '—' : t.name;
                    return Text('Enseignant: $teacherLabel • Étudiants: ${c.studentIds.length}');
                  },
                ),
                trailing: isAdmin
                    ? Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            tooltip: 'Modifier',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => showClassEditorDialog(context, ref, existing: c),
                          ),
                          IconButton(
                            tooltip: 'Supprimer',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Supprimer la classe ?'),
                                  content: Text('"${c.name}" sera définitivement supprimée.'),
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
                                await classesCtrl.remove(c.id);
                              }
                            },
                          ),
                        ],
                      )
                    : null,
                onTap: () {},
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => showClassEditorDialog(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
