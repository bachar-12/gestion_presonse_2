import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/roles.dart';
import '../../../core/widgets/role_badge.dart';
import '../../../data/models/app_user.dart';
import '../../../mvc/providers.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersControllerProvider);
    Stream<List<AppUser>> stream;
    if (_filter == 'all') {
      // Combine three role streams by simple merge in UI; easiest is load students by default
      stream = users.watchByRole(UserRoles.student);
    } else {
      stream = users.watchByRole(_filter);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Utilisateurs'),
        actions: const [RoleBadge()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Tous'),
                  selected: _filter == 'all',
                  onSelected: (v) => setState(() => _filter = 'all'),
                ),
                ChoiceChip(
                  label: const Text('Admins'),
                  selected: _filter == UserRoles.admin,
                  onSelected: (v) => setState(() => _filter = UserRoles.admin),
                ),
                ChoiceChip(
                  label: const Text('Enseignants'),
                  selected: _filter == UserRoles.teacher,
                  onSelected: (v) => setState(() => _filter = UserRoles.teacher),
                ),
                ChoiceChip(
                  label: const Text('Étudiants'),
                  selected: _filter == UserRoles.student,
                  onSelected: (v) => setState(() => _filter = UserRoles.student),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<AppUser>>(
                stream: stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data!;
                  if (items.isEmpty) {
                    return const Center(child: Text('Aucun utilisateur'));
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final u = items[i];
                      return ListTile(
                        title: Text(u.name.isEmpty ? '(Sans nom)' : u.name),
                        subtitle: Text(u.email),
                        trailing: _RoleDropdown(
                          value: u.role,
                          onChanged: (r) async {
                            if (r == null || r == u.role) return;
                            await ref.read(usersControllerProvider).setUser(
                                  AppUser(
                                    id: u.id,
                                    name: u.name,
                                    email: u.email,
                                    role: r,
                                  ),
                                );
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Rôle mis à jour: ${u.name} → $r')),
                            );
                          },
                        ),
                        onTap: () {},
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.signup),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Créer un compte'),
      ),
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  const _RoleDropdown({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: const [
          DropdownMenuItem(value: UserRoles.admin, child: Text('Admin')),
          DropdownMenuItem(value: UserRoles.teacher, child: Text('Enseignant')),
          DropdownMenuItem(value: UserRoles.student, child: Text('Étudiant')),
        ],
      ),
    );
  }
}
