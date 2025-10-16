import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/roles.dart';
import '../../mvc/providers.dart';

class UsersCounters extends ConsumerWidget {
  const UsersCounters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersControllerProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CountChip(
          tooltip: 'Admins',
          color: Colors.indigo,
          stream: users.watchCountByRole(UserRoles.admin),
          icon: Icons.admin_panel_settings_outlined,
        ),
        const SizedBox(width: 6),
        _CountChip(
          tooltip: 'Enseignants',
          color: Colors.teal,
          stream: users.watchCountByRole(UserRoles.teacher),
          icon: Icons.school_outlined,
        ),
        const SizedBox(width: 6),
        _CountChip(
          tooltip: 'Étudiants',
          color: Colors.deepOrange,
          stream: users.watchCountByRole(UserRoles.student),
          icon: Icons.group_outlined,
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.tooltip,
    required this.color,
    required this.stream,
    required this.icon,
  });
  final String tooltip;
  final Color color;
  final Stream<int> stream;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data;
        final child = Chip(
          label: Text(snapshot.hasData ? '$count' : '…'),
          avatar: Icon(icon, size: 16, color: color),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
          visualDensity: VisualDensity.compact,
        );
        return Tooltip(message: tooltip, child: child);
      },
    );
  }
}
