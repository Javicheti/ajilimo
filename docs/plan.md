# AjíLimo — Plan del proyecto

## Qué es
Plataforma de **control operativo de delivery** para múltiples marcas, apps y locales.
Integra los datos de **Rappi, DiDi y PedidosYa** en una sola vista y permite **actuar**
sobre la operación (no solo observar).

Tres capas (referencia TRDC):
- **MUSE** — datos unificados (ventas, órdenes, catálogo) por marca/app/local.
- **TOOL** — operación vigilada (conexión, horarios, promos, sabores, cooking time).
- **KORN** — defensa de pedidos (evidencia fotográfica + respuesta a reclamos).

## Alcance funcional (mapeo al cliente)
1. **Conexión y horarios** — revisión diaria, estado de tiendas, días festivos, "alta demanda".
2. **Promociones y sabores** — estado encendido/apagado/suspendido y detección de "precio full".
3. **Cooking time** — objetivo 22 min, monitoreo y ajuste.
4. **Reclamos (solo DiDi)** — bandeja con temporizador de 24 h y respuesta.
5. **Reporte diario de ventas** — por marca/app/producto/tienda/día-semana-mes, con culminados,
   cancelados (pagados y no pagados), monto pagado, y conteos de **alas** y **gaseosas**.

## Decisiones clave
- **Rappi**: integración completa (AjíLimo actúa como POS/Integración) — self-onboarding,
  órdenes, cooking time, webhooks.
- **Multi-app**: Rappi primero → DiDi (reclamos) → PedidosYa.
- **Apps**: `apps/backoffice` (Flutter Web) + `apps/korn_tablet` (Flutter Android) + `shared/`.
- **Backend**: Cloud Run (conectores, webhooks) + Cloud Functions + Pub/Sub + Cloud Scheduler +
  BigQuery + Secret Manager.
- **Todo configurable** (data-driven) y **multi-tenant** desde el inicio (listo para SaaS).
- **Pruebas sin credenciales**: mocks del contrato (`mocks/mock-rappi`).

## Arquitectura (resumen)
```
Flutter (backoffice + korn) ── Firebase Auth/App Check ── Firestore (estado vivo)
        ▲                                                    ▲
        │ callable / realtime                                 │ normalizadores
┌───────┴───────────── GCP ──────────────────────────────────┴───────────┐
│ Cloud Run (connectors) ← Secret Manager                                │
│ Webhooks (verificación HMAC/MD5) → Pub/Sub → Cloud Functions → BQ      │
│ Cloud Scheduler (revisiones) · Cloud Tasks (backoff)                   │
│ Cloud Storage (evidencia KORN) · BigQuery (reportes)                   │
└────────────────────────────────────────────────────────────────────────┘
```

## Estructura del repositorio
```
apps/backoffice   Flutter Web (torre de control)
apps/korn_tablet  Flutter Android (evidencia)
shared            Design system + widgets + modelos
backend           connectors/ config/ security/ webhooks/ jobs/ functions/ reporting/
mocks             mock-rappi (contrato + webhooks firmados)
infra             Terraform
docs              este directorio
```

## Brechas conocidas (y mitigación)
- **"Alta demanda"**: no existe en API → inferencia (picos de pedidos) + marcado manual.
- **Estado pausado/cerrado**: solo booleano online/offline → se distingue cruzando horario × disponibilidad.
- **Reclamos en Rappi**: no existen por API → son exclusivos de DiDi.

## Estado
- **Fase 0 completada**: proyecto Firebase, aislamiento de cuentas, design system, apps y mocks.
- Siguiente: **Fase 1 — Conector Rappi + configuración/secretos**.
