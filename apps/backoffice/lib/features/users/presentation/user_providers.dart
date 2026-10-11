import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/user_repository.dart';
import '../domain/app_user.dart';
import '../domain/user_role.dart';

final Provider<UserRepository> userRepositoryProvider =
    Provider<UserRepository>((ref) => createUserRepository());

/// Perfil del usuario autenticado (null sin sesión o sin Firebase).
final StreamProvider<AppUser?> currentUserProvider = StreamProvider<AppUser?>((ref) {
  if (Firebase.apps.isEmpty) return Stream<AppUser?>.value(null);
  final UserRepository repository = ref.watch(userRepositoryProvider);
  return FirebaseAuth.instance.authStateChanges().asyncMap(
        (User? user) async => user == null ? null : repository.get(user.uid),
      );
});

/// Rol actual (viewer por defecto).
final Provider<UserRole> currentRoleProvider = Provider<UserRole>(
  (ref) => ref.watch(currentUserProvider).value?.role ?? UserRole.viewer,
);

/// Permisos efectivos del rol actual.
final Provider<Set<Permission>> permissionsProvider = Provider<Set<Permission>>(
  (ref) => ref.watch(currentRoleProvider).permissions,
);

/// Usuarios del tenant del usuario autenticado.
final FutureProvider<List<AppUser>> tenantUsersProvider = FutureProvider<List<AppUser>>((ref) async {
  final AppUser? user = await ref.watch(currentUserProvider.future);
  if (user == null) return const <AppUser>[];
  return ref.watch(userRepositoryProvider).listByTenant(user.tenantId);
});
