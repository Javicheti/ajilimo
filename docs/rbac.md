# AjíLimo — Usuarios, roles y permisos (RBAC)

## Datos del usuario (Firestore `users/{uid}`)
| Campo | Tipo | Notas |
|---|---|---|
| `uid` | string | ID de Firebase Auth |
| `email` | string | Único |
| `displayName`, `firstName`, `lastName` | string | |
| `phone`, `documentType`, `documentNumber` | string | opcionales (DNI/RUC) |
| `tenantId` | string | Negocio/organización |
| `role` | enum | owner · superadmin · admin · supervisor · operator · viewer |
| `brandIds`, `storeIds` | list | Alcance por marca/local |
| `status` | active/invited/disabled | |
| `locale`, `timezone` | string | es / America/Lima |
| `createdAt`, `updatedAt`, `lastLoginAt`, `createdBy`, `photoUrl` | | |

## Roles y permisos
| Permiso | owner | superadmin | admin | supervisor | operator | viewer |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Ver torre de control | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Operar órdenes | ✅ | ✅ | ✅ | ✅ | ✅ | — |
| Responder reclamos | ✅ | ✅ | ✅ | ✅ | ✅ | — |
| Ver reportes | ✅ | ✅ | ✅ | ✅ | — | ✅ |
| Capturar evidencia (KORN) | ✅ | ✅ | ✅ | ✅ | ✅ | — |
| Gestionar integraciones | ✅ | ✅ | ✅ | — | — | — |
| Gestionar usuarios | ✅ | ✅ | ✅ | — | — | — |
| Gestionar tenants | ✅ | ✅ | — | — | — | — |

## Mecanismo
- **Custom claims** en el token: `role`, `tenantId`, `admin`.
- Reglas de Firestore (`firestore.rules`) validan acceso por claims.
- Cloud Functions **`bootstrapOwner`** (primer owner) y **`setUserRole`** (solo owner/superadmin/admin)
  asignan claims + documento.
- La UI resuelve permisos con `currentRoleProvider`/`permissionsProvider` y oculta rutas/acciones.

## Bootstrap realizado
- `javier.ascue@fluxus.lat` → **owner** (tenant `ajilimo`) vía `bootstrapOwner`.

## Pendiente
- Sincronizar cambios de rol de la UI vía callable `setUserRole` (hoy la UI escribe Firestore;
  el callable ya existe y actualiza claims). Siguiente iteración.
