import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { HttpsError, onCall } from 'firebase-functions/v2/https';

export const VALID_ROLES = [
  'owner',
  'superadmin',
  'admin',
  'supervisor',
  'operator',
  'viewer',
] as const;

export type Role = (typeof VALID_ROLES)[number];

export function isValidRole(value: unknown): value is Role {
  return typeof value === 'string' && (VALID_ROLES as readonly string[]).includes(value);
}

function isManager(role: unknown): boolean {
  return role === 'owner' || role === 'superadmin' || role === 'admin';
}

/**
 * Asigna el rol owner al primer usuario que lo solicite (bootstrap).
 * Si ya existe un owner, se rechaza.
 */
export const bootstrapOwner = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Se requiere sesión.');

  const db = getFirestore();
  const owners = await db.collection('users').where('role', '==', 'owner').limit(1).get();
  if (!owners.empty) {
    throw new HttpsError('already-exists', 'Ya existe un owner.');
  }

  const uid = request.auth.uid;
  const email = request.auth.token.email ?? '';
  const tenantId = 'ajilimo';
  const displayName = (request.auth.token.name as string | undefined) ?? email;

  await getAuth().setCustomUserClaims(uid, { role: 'owner', admin: true, tenantId });
  await db.collection('users').doc(uid).set(
    {
      uid,
      email,
      displayName,
      role: 'owner',
      tenantId,
      status: 'active',
      updatedAt: new Date().toISOString(),
    },
    { merge: true },
  );

  return { ok: true, role: 'owner', tenantId };
});

/** Cambia el rol de un usuario (solo owner/superadmin/admin). */
export const setUserRole = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Se requiere sesión.');
  const callerRole = request.auth.token.role;
  if (!isManager(callerRole)) {
    throw new HttpsError('permission-denied', 'No autorizado para gestionar roles.');
  }

  const data = (request.data ?? {}) as { uid?: string; role?: unknown; tenantId?: string };
  if (!data.uid || !isValidRole(data.role)) {
    throw new HttpsError('invalid-argument', 'Datos inválidos.');
  }

  const tenantId = data.tenantId ?? 'ajilimo';
  const admin = data.role === 'owner' || data.role === 'superadmin';

  await getAuth().setCustomUserClaims(data.uid, { role: data.role, admin, tenantId });
  await getFirestore().collection('users').doc(data.uid).set(
    { role: data.role, tenantId, updatedAt: new Date().toISOString() },
    { merge: true },
  );

  return { ok: true, role: data.role };
});
