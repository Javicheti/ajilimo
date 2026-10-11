import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../domain/app_user.dart';
import '../domain/user_role.dart';

/// Repositorio de usuarios. Usa Firestore si está disponible; si no, memoria.
class UserRepository {
  UserRepository({this.firestore});

  final FirebaseFirestore? firestore;
  final Map<String, AppUser> _memory = <String, AppUser>{};

  CollectionReference<Map<String, dynamic>>? get _collection =>
      firestore?.collection('users');

  Future<AppUser?> get(String uid) async {
    if (_collection == null) return _memory[uid];
    final DocumentSnapshot<Map<String, dynamic>> doc = await _collection!.doc(uid).get();
    return doc.exists ? AppUser.fromJson(doc.data()!) : null;
  }

  Stream<AppUser?> watch(String uid) {
    if (_collection == null) return Stream<AppUser?>.value(_memory[uid]);
    return _collection!
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? AppUser.fromJson(doc.data()!) : null);
  }

  Future<void> upsert(AppUser user) async {
    if (_collection == null) {
      _memory[user.uid] = user;
      return;
    }
    await _collection!.doc(user.uid).set(user.toJson(), SetOptions(merge: true));
  }

  Future<List<AppUser>> listByTenant(String tenantId) async {
    if (_collection == null) {
      return _memory.values.where((user) => user.tenantId == tenantId).toList();
    }
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _collection!.where('tenantId', isEqualTo: tenantId).get();
    return snapshot.docs.map((doc) => AppUser.fromJson(doc.data())).toList();
  }

  Future<void> updateRole(String uid, UserRole role) async {
    if (_collection == null) {
      final AppUser? user = _memory[uid];
      if (user != null) _memory[uid] = user.copyWith(role: role);
      return;
    }
    await _collection!.doc(uid).set(
      <String, dynamic>{'role': role.wire, 'updatedAt': DateTime.now().toIso8601String()},
      SetOptions(merge: true),
    );
  }
}

/// Crea el repositorio según disponibilidad de Firebase.
UserRepository createUserRepository() {
  if (Firebase.apps.isEmpty) return UserRepository();
  return UserRepository(firestore: FirebaseFirestore.instance);
}
