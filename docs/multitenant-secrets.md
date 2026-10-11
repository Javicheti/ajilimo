# AjíLimo — Multi-tenant y gestión de secretos (SaaS)

Objetivo: que sea **SaaS** para otros negocios, con credenciales **dinámicas**.

## Estrategia de secretos
| Opción | Descripción | Veredicto |
|---|---|---|
| **A. Un proyecto GCP + Secret Manager por-tenant** | secretos `tenants/{id}/{provider}/{env}/...` | ✅ **Recomendada** |
| B. Un proyecto GCP por tenant | aislamiento físico | solo enterprise |
| C. Envelope encryption (KMS) en BD | cifrar y guardar en Firestore | complemento opcional |

Flujo del cliente: ingresa credenciales → backend **valida** (health check) → escribe en
**Secret Manager** (nueva versión) → guarda solo la **referencia** en Firestore → responde
`configurado ✓`. El cliente **nunca** ve el secreto.

## Arquitectura Control Plane / Data Plane
```
CONTROL PLANE: onboarding, tenant/marca/tienda, credenciales (escribe Secret Manager),
               roles, flags, audit log
DATA PLANE:    connectors (leen su secreto) · webhooks → Pub/Sub → Functions →
               Firestore (tenant-scoped) · BigQuery (dataset/partición por tenant)
```

## Naming de secretos
```
tenants/{tenantId}/{provider}/{env}/oauth      # client_id/secret o app_id/secret
tenants/{tenantId}/{provider}/{env}/webhook    # secret de firma de webhooks
```

## Seguridad
- Secret Manager cifra en reposo (CMEK opcional con Cloud KMS).
- Rotación: cada `PUT` crea **nueva versión**; botón "Rotar" y `reset-secret` de webhook.
- IAM: el SA de Cloud Run accede solo a `tenants/*` (condiciones IAM a futuro).
- Auditoría: Data Access logs + `audit_log` propio.
- Nunca claves en repo, cliente ni Firestore (solo referencias).

## Token Vault (por tenant/tienda)
- Rappi M2M (`client_credentials`): token ~1 semana → cache + renovación automática.
- Rappi Merchant (OAuth PKCE): **sin refresh token** → requiere **"Reconectar"** (estado `pending_auth`).
- DiDi: `auth_token` por tienda → renovación en backend.

## Evolución
- **Hoy (single-tenant)**: modelar todo con `tenantId` (tenant-aware).
- **SaaS**: habilitar registro de tenants + onboarding wizard (el resolver ya está listo).
- **Enterprise**: un tenant puede migrar a proyecto GCP dedicado cambiando su `projectId`.
