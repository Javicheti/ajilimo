# AjíLimo — Roadmap

Duración estimada con 1 desarrollador full-stack. Cada fase cierra con pruebas en verde
y demo, antes de avanzar (sin detenerse salvo bloqueo por credenciales/terceros).

| Fase | Duración | Entregable | Dependencia externa |
|---|---|---|---|
| **0 Fundaciones** | 1 sem | Proyecto Firebase/GCP, aislamiento de cuentas, design system, apps + mocks, docs | — |
| **1 Conector Rappi + Config/Secrets** | 2–3 sem | `DeliveryConnector`, `ConnectorFactory`, `TenantResolver`, `SecretService`, `TokenVault`, RappiConnector (auth/stores/menu/availability), webhooks HMAC, self-onboarding | Credenciales Rappi (dev) para revalidar |
| **2 Conexión y Horarios** | 2 sem | Semáforo, horarios/festivos, reglas y alertas | — |
| **3 Cooking time + Órdenes** | 1–2 sem | Toma de órdenes con 22 min · **demo intermedia** | — |
| **4 Promos y Sabores** | 2 sem | Snapshot `suspension_info`/`is_category_active`, alerta "precio full" | — |
| **5 Reporte de Ventas** | 2–3 sem | Ingesta órdenes+Financial → BigQuery → dashboards + Excel | — |
| **6 KORN (evidencia)** | 2 sem | App tablet: Checklist→Foto→Continuar→Entregar + galería por pedido | Definir cámara/captura |
| **7 Conector DiDi + Reclamos** | 2–3 sem | Bandeja + timer 24 h + respuesta; mock-didi | NDA + credenciales DiDi |
| **8 Conector PedidosYa + unificación** | 2–3 sem | Tercera app + vista unificada | Credenciales PedidosYa (account manager) |
| **9 SaaS** | posterior | Onboarding de tenants, billing | — |

**Total estimado:** ~17–22 semanas. Demo intermedia al cierre de la Fase 3.

## Principios de ejecución
- Se construye **contra el mock** cuando faltan credenciales; el "switch a real" es config.
- Cada módulo: backend → datos → UI → pruebas, en verde antes de continuar.
- Deploys **siempre** con `--project ajilimo-830ca`.

## Estado actual
- ✅ Fase 0 — fundaciones.
- ✅ Fase 1 — conector Rappi + configuración/secretos + webhooks + UI Integraciones + deploy.
- ✅ Fase 2 — conexión y horarios (dominio + Torre de control con alertas).
- ✅ Fase 3 — cooking time + Órdenes (monitor en vivo).
- ✅ Fase 4 — promos y sabores (estado + precio full).
- ✅ Fase 5 — reporte de ventas (agregaciones + CSV).
- ✅ Fase 6 — KORN (flujo de evidencia validado + galería).
- ✅ Fase 7 — DiDi + Reclamos (conector, firma MD5, bandeja 24 h).
- ✅ Fase 8 — PedidosYa + vista unificada (resumen por app).
- ✅ Fase 9 — SaaS (onboarding de tenants).

> Nota: cada fase quedó con **núcleo funcional probado sobre mocks**. Pendientes transversales:
> wire UI↔backend real (Firestore/callables), job de Cloud Scheduler, captura real de cámara,
> y validación en el entorno DEV de cada plataforma con credenciales.

