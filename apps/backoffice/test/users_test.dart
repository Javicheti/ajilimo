import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:backoffice/features/users/data/user_repository.dart';
import 'package:backoffice/features/users/domain/app_user.dart';
import 'package:backoffice/features/users/domain/user_role.dart';
import 'package:backoffice/features/users/presentation/user_providers.dart';
import 'package:backoffice/features/users/presentation/users_page.dart';

void main() {
  testWidgets('Lista usuarios y la matriz de permisos', (WidgetTester tester) async {
    final UserRepository repository = UserRepository();
    await repository.upsert(
      const AppUser(
        uid: 'u1',
        email: 'ana@ajilimo.pe',
        displayName: 'Ana',
        tenantId: 't1',
        role: UserRole.viewer,
      ),
    );

    await tester.binding.setSurfaceSize(const Size(1200, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(repository),
          currentUserProvider.overrideWith(
            (ref) => Stream<AppUser?>.value(
              const AppUser(
                uid: 'admin',
                email: 'admin@ajilimo.pe',
                displayName: 'Admin',
                tenantId: 't1',
                role: UserRole.admin,
              ),
            ),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light(), home: const UsersPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Usuarios'), findsWidgets);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Roles y permisos'), findsOneWidget);
  });
}
