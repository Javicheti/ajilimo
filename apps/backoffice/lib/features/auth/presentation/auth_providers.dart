import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_service.dart';

/// Servicio de auth (null si Firebase no está inicializado, p. ej. en tests).
final Provider<AuthService?> authServiceProvider = Provider<AuthService?>((ref) {
  if (Firebase.apps.isEmpty) return null;
  return AuthService(FirebaseAuth.instance);
});

/// Estado de sesión. Sin Firebase se considera "con sesión" para no bloquear.
final StreamProvider<bool> authStatusProvider = StreamProvider<bool>((ref) {
  final AuthService? service = ref.watch(authServiceProvider);
  if (service == null) return Stream<bool>.value(true);
  return service.authStateChanges();
});
