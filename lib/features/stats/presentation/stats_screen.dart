import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/roles.dart';
import '../../../mvc/providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')), 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Utilisateurs', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _CountCard(
                  label: 'Admins',
                  color: Colors.indigo,
                  stream: users.watchCountByRole(UserRoles.admin),
                ),
                _CountCard(
                  label: 'Enseignants',
                  color: Colors.teal,
                  stream: users.watchCountByRole(UserRoles.teacher),
                ),
                _CountCard(
                  label: 'Étudiants',
                  color: Colors.deepOrange,
                  stream: users.watchCountByRole(UserRoles.student),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Text(
                  'Ajoutez/retirez des utilisateurs pour voir les compteurs se mettre à jour en temps réel.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.label,
    required this.color,
    required this.stream,
  });
  final String label;
  final Color color;
  final Stream<int> stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data;
        return Container(
          width: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              if (!snapshot.hasData)
                const SizedBox(
                    height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
              else
                Text('$count',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(color: color, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      },
    );
  }
}
