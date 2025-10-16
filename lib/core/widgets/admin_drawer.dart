import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../data/providers.dart';
import '../../mvc/providers.dart';
import 'role_badge.dart';
import 'users_counters.dart';

/// Drawer réservé aux administrateurs: regroupe les compteurs, la navigation
/// vers les écrans d'administration et la déconnexion.
class AdminDrawer extends ConsumerWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authStateProvider).value;
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gestion Présence',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const RoleBadge(),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authUser?.email ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const UsersCounters(),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.class_outlined),
              title: const Text('Classes'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.classes);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_outlined),
              title: const Text('Séances'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.sessions);
              },
            ),
            ListTile(
              leading: const Icon(Icons.fact_check_outlined),
              title: const Text('Présence'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.attendance);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bar_chart_rounded),
              title: const Text('Statistiques'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.stats);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_alt_outlined),
              title: const Text('Utilisateurs'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.users);
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: FilledButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider).signOut();
                  if (context.mounted) context.go(AppRoutes.login);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Déconnexion'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

