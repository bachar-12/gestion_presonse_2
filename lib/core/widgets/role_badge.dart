import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/roles.dart';
import '../../data/providers.dart';

class RoleBadge extends ConsumerWidget {
  const RoleBadge({super.key});

  String _label(String? role) {
    switch (role) {
      case UserRoles.admin:
        return 'Admin';
      case UserRoles.teacher:
        return 'Enseignant';
      case UserRoles.student:
        return 'Étudiant';
      default:
        return 'Invité';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(currentUserDocProvider);
    final role = asyncUser.value?.role;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Chip(
        label: Text(asyncUser.isLoading ? '...' : _label(role)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
