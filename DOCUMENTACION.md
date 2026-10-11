# AjíLimo — Documentación completa del proyecto

> Documento maestro. Consolida visión, arquitectura, alcance, configuración, seguridad,
> diseño, pruebas, infraestructura y estado. Los detalles profundos viven en `docs/`.

## Índice
1. [Qué es](#1-qué-es)
2. [Estado actual](#2-estado-actual)
3. [Alcance funcional](#3-alcance-funcional)
4. [Arquitectura](#4-arquitectura)
5. [Estructura del repositorio](#5-estructura-del-repositorio)
6. [Aislamiento de cuentas](#6-aislamiento-de-cuentas)
7. [Integraciones de delivery](#7-integraciones-de-delivery)
8. [Configuración (data-driven)](#8-configuración-data-driven)
9. [Multi-tenant y secretos](#9-multi-tenant-y-secretos)
10. [Design system](#10-design-system)
11. [Estrategia de pruebas](#11-estrategia-de-pruebas)
12. [Infraestructura](#12-infraestructura)
13. [Roadmap](#13-roadmap)
14. [Referencias (`docs/`)](#14-referencias)

---

## 1. Qué es
Plataforma de **control operativo de delivery** multi-marca / multi-app / multi-local.
Integra los datos de **Rappi, DiDi y PedidosYa** en una sola vista y permite **actuar**
sobre la operación. Tres capas (referencia TRDC):
- **MUSE** — datos unificados.
- **TOOL** — operación vigilada.
- **KORN** — defensa de pedidos (evidencia + reclamos).

Stack: **Flutter** (Web + Android) + **Firebase** + **Google Cloud**.

## 2. Estado actual
- **Fase 0 — completada**: proyecto Firebase/GCP, aislamiento de cuentas, design system, apps, mocks.
- **Fases 1–9 — núcleo completado** (probado sobre mocks):
  - **1** conector Rappi + config/secretos + webhooks + UI Integraciones + deploy verificado.
  - **2** conexión/horarios + **Torre de control** con alertas.
  - **3** cooking time + **Órdenes** con monitor en vivo.
  - **4** **Promos y sabores** (estado + precio full).
  - **5** **Reporte de ventas** (agregaciones + export CSV).
  - **6** **KORN** (flujo de evidencia + galería).
  - **7** **DiDi + Reclamos** (conector, firma MD5, bandeja 24 h).
  - **8** **PedidosYa** + vista unificada (resumen por app).
  - **9** **SaaS** (onboarding de tenants).
- **Capa de integración (BFF)**: función `api` desplegada (endpoints `/control-tower`,
  `/orders`, `/claims`, `/connections`) que sirve datos normalizados de los conectores.
  Torre de control, Órdenes, Reclamos e Integraciones consumen el BFF con **fallback** a datos
  ficticios locales. Cambiar a datos reales = configurar `RAPPI_BASE_URL`/etc. + secretos.
- **Pendientes transversales**: secretos reales en Secret Manager, job Cloud Scheduler,
  captura real de cámara, App Check, entorno `prod`, y validación en DEV con credenciales.


## 3. Alcance funcional
1. **Conexión y horarios** — revisión diaria, estado de tiendas, festivos, "alta demanda".
2. **Promociones y sabores** — encendido/apagado/suspendido y detección de "precio full".
3. **Cooking time** — objetivo 22 min, monitoreo y ajuste.
4. **Reclamos (solo DiDi)** — bandeja con temporizador de 24 h y respuesta.
5. **Reporte diario de ventas** — por marca/app/producto/tienda/día-semana-mes; culminados,
   cancelados (pagados y no pagados), **monto pagado**, y conteos de **alas** y **gaseosas**.

### Brechas conocidas y mitigación
| Requisito | Rappi | Mitigación |
|---|---|---|
| "Alta demanda" | ❌ | Inferencia (picos de pedidos) + marcado manual |
| Distinguir pausado/cerrado | 🟡 | Cruce horario (`Utils`) × disponibilidad (bool) |
| Reclamos | ❌ | Exclusivo de DiDi |

## 4. Arquitectura
```
Flutter (backoffice + korn) ── Firebase Auth/App Check ── Firestore (estado vivo)
        ▲                                                    ▲
        │ callable / realtime                                 │ normalizadores
┌───────┴───────────── GCP ──────────────────────────────────┴───────────┐
│ Cloud Run (connectors) ← Secret Manager                                │
│ Webhooks (HMAC/MD5) → Pub/Sub → Cloud Functions → BigQuery             │
│ Cloud Scheduler (revisiones) · Cloud Tasks (backoff)                   │
│ Cloud Storage (evidencia KORN) · BigQuery (reportes)                   │
└────────────────────────────────────────────────────────────────────────┘
```
Principio: la **UI nunca** llama APIs de delivery; todo pasa por el backend (secretos y firmas).

## 5. Estructura del repositorio
```
apps/backoffice      Flutter Web (torre de control)
apps/korn_tablet     Flutter Android (evidencia KORN)
shared/              Design system + widgets + modelos
backend/functions/   Conectores, config, security, webhooks, jobs, reporting (TS)
mocks/mock-rappi     Contrato de Rappi + emisor de webhooks firmados
infra/               Terraform (GCP)
docs/                Documentación detallada
```

## 6. Aislamiento de cuentas
- **Firebase**: la cuenta `javicheti001@gmail.com` se fija **por carpeta** (`activeAccounts`).
  El global sigue en `fluxus.dev.lat@gmail.com`.
- **gcloud**: config `ajilimo` creada sin activar; `default` (Fluxus) permanece activa.
- **Deploy**: siempre `--project ajilimo-830ca --account javicheti001@gmail.com`.
- Setup idempotente: `bash tool/setup_firebase.sh`.

## 7. Integraciones de delivery
- **Rappi**: integración completa (AjíLimo = POS). Auth M2M + OAuth Merchant (PKCE),
  tiendas/self-onboarding, menú (Rests API), disponibilidad, órdenes, **Financial API**,
  webhooks firmados (HMAC-SHA256).
- **DiDi Food**: órdenes, menú, estado de tienda, promos, reportes y **reclamos**
  (`orderCancelApply`/`orderRefundApply`). Firma MD5.
- **PedidosYa**: Partner API (órdenes, catálogo, outlet, promos). Sin API de reclamos.
- Detalle: `docs/api-mapping.md`.

## 8. Configuración (data-driven)
Todo configurable en runtime: canales, marcas, tiendas, mapeos, reglas, flags.
Precedencia `Tienda → Marca → Canal → Global`. El campo `environment` (mock|dev|prod)
permite cambiar de entorno sin recompilar. Detalle: `docs/configuration.md`.

## 9. Multi-tenant y secretos
- Secretos en **Secret Manager** con naming `tenants/{tenantId}/{provider}/{env}/...`.
- El cliente ingresa credenciales → backend valida → escribe el secreto → guarda solo la **referencia**.
- `TenantResolver` + `SecretService` + `TokenVault`. Arquitectura Control/Data Plane.
- Detalle: `docs/multitenant-secrets.md`.

## 10. Design system
Tokens centralizados en `shared/lib/design/` (prohibido `Color(0x...)` fuera de ahí).
Paleta Rappi premium, tipografía Sora + Inter, `AppColors` (ThemeExtension), tema claro/oscuro,
**white-label** por tenant/marca. Galería viva en `/design`. Detalle: `docs/design-system.md`.

## 11. Estrategia de pruebas
Desarrollo contra **mock** (sin credenciales) → DEV → prod. Pirámide: contrato, unit,
integración (webhooks firmados), widget, E2E. Detalle: `docs/testing-strategy.md`.

## 12. Infraestructura
Terraform (`infra/`): APIs, BigQuery (`ajilimo_dev`), Pub/Sub por canal + DLQ,
Cloud Scheduler, Secret Manager, service account de conectores. Detalle: `infra/README.md`.

## 13. Roadmap
Fases 0–9 (~17–22 semanas), Rappi → DiDi → PedidosYa, demo intermedia al cierre de Fase 3.
Detalle: `docs/roadmap.md`.

## 14. Referencias
| Documento | Contenido |
|---|---|
| `docs/plan.md` | Plan y alcance |
| `docs/roadmap.md` | Fases y entregables |
| `docs/api-mapping.md` | Endpoints por plataforma |
| `docs/design-system.md` | Tokens, componentes, pantallas |
| `docs/configuration.md` | Configuración dinámica |
| `docs/multitenant-secrets.md` | SaaS y secretos |
| `docs/testing-strategy.md` | Pruebas |
| `docs/rbac.md` | Usuarios, roles y permisos |
| `AGENTS.md` | Reglas operativas (cuentas, deploy) |
