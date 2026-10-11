import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tenants/domain/tenant.dart';
import '../../users/domain/app_user.dart';
import '../../users/domain/user_role.dart';
import '../../users/presentation/user_providers.dart';
import '../data/auth_service.dart';
import 'auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _organization = TextEditingController();
  bool _registering = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    _phone.dispose();
    _organization.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final AuthService? service = ref.read(authServiceProvider);
    if (service == null) {
      setState(() => _error = 'Firebase no está inicializado.');
      return;
    }
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Ingresa correo y contraseña.');
      return;
    }
    if (_registering && _name.text.trim().isEmpty) {
      setState(() => _error = 'Ingresa tu nombre.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_registering) {
        final User user = await service.signUp(_email.text, _password.text);
        final String tenantSlug = slugify(_organization.text);
        final AppUser profile = AppUser(
          uid: user.uid,
          email: user.email ?? _email.text.trim(),
          displayName: _name.text.trim(),
          phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          tenantId: tenantSlug.isEmpty ? 'ajilimo' : tenantSlug,
          role: UserRole.viewer,
          createdAt: DateTime.now(),
          createdBy: user.uid,
        );
        await ref.read(userRepositoryProvider).upsert(profile);
      } else {
        await service.signIn(_email.text, _password.text);
      }
    } catch (error) {
      if (mounted) setState(() => _error = authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: AppCard(
              padding: const EdgeInsets.all(Spacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: c.brandPrimary,
                          borderRadius: BorderRadius.circular(Radii.md),
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Text('AjíLimo', style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    _registering ? 'Crea tu cuenta' : 'Inicia sesión',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: Spacing.lg),
                  if (_registering) ...<Widget>[
                    TextField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Nombre completo'),
                    ),
                    const SizedBox(height: Spacing.md),
                    TextField(
                      controller: _organization,
                      decoration: const InputDecoration(
                        labelText: 'Organización / negocio',
                        hintText: 'Ej. PINWINGS',
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Teléfono (opcional)'),
                    ),
                    const SizedBox(height: Spacing.md),
                  ],
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const <String>[AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'Correo', hintText: 'tu@correo.com'),
                  ),
                  const SizedBox(height: Spacing.md),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                  ),
                  if (_error != null) ...<Widget>[
                    const SizedBox(height: Spacing.md),
                    Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.danger),
                    ),
                  ],
                  const SizedBox(height: Spacing.lg),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_registering ? 'Crear cuenta' : 'Ingresar'),
                  ),
                  const SizedBox(height: Spacing.sm),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() {
                              _registering = !_registering;
                              _error = null;
                            }),
                    child: Text(
                      _registering ? '¿Ya tienes cuenta? Inicia sesión' : '¿No tienes cuenta? Regístrate',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
