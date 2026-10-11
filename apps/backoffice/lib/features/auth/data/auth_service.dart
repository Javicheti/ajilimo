import 'package:firebase_auth/firebase_auth.dart';

/// Envuelve Firebase Auth. Se construye solo cuando Firebase está disponible.
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  Stream<bool> authStateChanges() => _auth.authStateChanges().map((user) => user != null);

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<User> signUp(String email, String password) async {
    final UserCredential credential =
        await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    return credential.user!;
  }

  Future<void> signOut() => _auth.signOut();
}

/// Traduce códigos de error de Firebase Auth a mensajes legibles.
String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'user-disabled':
        return 'Esta cuenta está deshabilitada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ese correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña es muy débil.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';
      default:
        return error.message ?? 'Error de autenticación.';
    }
  }
  return 'No se pudo completar la operación.';
}
