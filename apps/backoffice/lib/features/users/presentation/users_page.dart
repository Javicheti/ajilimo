import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_user.dart';
import '../domain/user_role.dart';
import 'user_providers.dart';

class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final AsyncValue<List<AppUser>> usersAsync = ref.watch(tenantUsersProvider);
    final UserRole myRole = ref.watch(currentRoleProvider);
    final bool canManage = myRole.can(Permission.manageUsers);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: <Widget>[
              const PageHeader(
                icon: Icons.manage_accounts_outlined,
                eyebrow: 'Configuración',
                title: 'Usuarios y permisos',
                subtitle: 'Gestiona roles y accesos de tu negocio',
              ),
              SectionHeader(
                title: 'Usuarios',
                subtitle: 'Tu rol: ${myRole.label}',
              ),
              AppCard(
                padding: EdgeInsets.zero,
                child: usersAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(Spacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.all(Spacing.lg),
                    child: Text('No se pudieron cargar los usuarios: $error'),
                  ),
                  data: (users) => users.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(Spacing.lg),
                          child: Text(
                            'Aún no hay usuarios en este negocio.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : Column(
                          children: <Widget>[
                            for (int i = 0; i < users.length; i++) ...<Widget>[
                              _UserRow(
                                user: users[i],
                                enabled: canManage,
                                onRoleChanged: (role) async {
                                  await ref.read(userRepositoryProvider).updateRole(users[i].uid, role);
                                  ref.invalidate(tenantUsersProvider);
                                },
                              ),
                              if (i < users.length - 1) Divider(height: 1, color: c.border),
                            ],
                          ],
                        ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              SectionHeader(
                title: 'Roles y permisos',
                subtitle: canManage ? 'Puedes asignar roles' : 'Solo lectura',
              ),
              AppCard(child: _PermissionMatrix()),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user, required this.enabled, required this.onRoleChanged});

  final AppUser user;
  final bool enabled;
  final ValueChanged<UserRole> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
      leading: CircleAvatar(
        backgroundColor: c.brandSoft,
        child: Text(
          user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
          style: TextStyle(color: c.brandPrimary, fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(user.displayName.isEmpty ? user.email : user.displayName),
      subtitle: Text('${user.email} · ${user.status.wire}'),
      trailing: DropdownButton<UserRole>(
        value: user.role,
        onChanged: enabled ? (role) => role == null ? null : onRoleChanged(role) : null,
        items: UserRole.values
            .map((role) => DropdownMenuItem<UserRole>(value: role, child: Text(role.label)))
            .toList(),
      ),
    );
  }
}

class _PermissionMatrix extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      children: <Widget>[
        for (final UserRole role in UserRole.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${role.label} — ${role.description}', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: Spacing.xxs),
                Wrap(
                  spacing: Spacing.xs,
                  runSpacing: Spacing.xxs,
                  children: role.permissions
                      .map(
                        (permission) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: Spacing.xs, vertical: Spacing.xxs),
                          decoration: BoxDecoration(
                            color: c.brandSoft,
                            borderRadius: BorderRadius.circular(Radii.pill),
                          ),
                          child: Text(
                            permission.label,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: c.brandPrimary),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: Spacing.sm),
              ],
            ),
          ),
      ],
    );
  }
}
