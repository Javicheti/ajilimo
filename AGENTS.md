# AGENTS.md — AjíLimo

Reglas internas del proyecto. Aplican a cualquier agente que trabaje aquí.

## Contexto del proyecto
- Plataforma de control operativo de delivery **multi-marca / multi-app / multi-local**.
- Capas: **MUSE** (datos unificados) · **TOOL** (operación vigilada) · **KORN** (defensa de pedidos).
- Apps: `apps/backoffice` (Flutter **Web**) y `apps/korn_tablet` (Flutter **Android/tablet**).
- Paquete compartido: `shared/` (design tokens + widgets + modelos).
- Backend: `backend/` (conectores, webhooks, funciones, jobs) + `mocks/` (mock-rappi, mock-didi).
- Infra: `infra/` (Terraform). Documentación: `docs/`.
- Estado actual: **Fase 0 — fundaciones** (ver `docs/roadmap.md`).

## Proyecto Firebase / GCP
- **Project ID (dev): `ajilimo-830ca`** · cuenta `javicheti001@gmail.com` · plan **Blaze**.
- Prod se creará más adelante (proyecto separado).

## Reglas de cuentas (AISLAMIENTO — IMPORTANTE)
Este equipo trabaja también en **Fluxus**. No alterar su contexto.

- **Firebase**
  - Cuenta global: `fluxus.dev.lat@gmail.com` (debe permanecer así).
  - Cuenta de este proyecto (fijada por carpeta): `javicheti001@gmail.com`.
  - Para comandos de este proyecto usar siempre:
    `firebase <cmd> --account javicheti001@gmail.com --project ajilimo-830ca`
  - No ejecutar `firebase login:use` fuera de esta carpeta.
- **gcloud**
  - Mantener activa la configuración `default` (= Fluxus).
  - Para este proyecto usar: `gcloud --configuration=ajilimo <cmd>`
    (nunca `gcloud config configurations activate ajilimo` de forma permanente).
- **Setup idempotente**: `bash tool/setup_firebase.sh` (no invasivo; respeta Fluxus).

## Reglas de DEPLOY (OBLIGATORIO)
Todo comando `firebase`/`gcloud` de AjíLimo debe **referenciar el proyecto real explícitamente**.
Nunca ejecutar `firebase deploy` sin `--project` (evita tocar el proyecto activo/Fluxus).

Forma canónica:
```
firebase deploy --only functions:miFuncion \
  --project ajilimo-830ca \
  --account javicheti001@gmail.com
```
```
firebase functions:delete miFuncion --region us-central1 \
  --project ajilimo-830ca \
  --account javicheti001@gmail.com \
  --force
```
- Región por defecto: `us-central1` (salvo que se defina otra en `docs/`).

## Comandos y verificación
- Analizar (por app): `flutter analyze` dentro de `apps/<app>`.
- Tests: `flutter test` dentro de `apps/<app>` y en `shared/`.
- Build Web: `flutter build web` dentro de `apps/backoffice`.
- Correr Web: `flutter run -d chrome` dentro de `apps/backoffice`.
- Backend Functions: `npm --prefix backend/functions run build`.
- **No ejecutar builds de Android salvo pedido explícito.**
- Antes de dar por terminada una tarea: `flutter analyze` sin issues y tests en verde.

## Arquitectura (convenciones)
- **Frontend**: feature-first con capas `data` / `domain` / `presentation` por feature.
  Estado con **Riverpod**, navegación con **go_router**. La UI **nunca** llama APIs de
  delivery directamente: siempre al backend.
- **Diseño**: tokens centralizados en `shared/lib/design/`. **Prohibido** `Color(0x...)`
  fuera de `design/`. Tema claro/oscuro + extensión de tokens (`AppColors`).
  Color de marca **white-label** por tenant/marca (Firestore) sobre tokens en código.
- **Backend**: interfaz `DeliveryConnector` + `ConnectorFactory` por `provider`.
  Webhooks: verificar firma (Rappi HMAC-SHA256 / DiDi MD5) → Pub/Sub → Functions.
  Multi-tenant: `TenantResolver` + `SecretService` (Secret Manager) + `TokenVault`.
- **Secretos**: nunca en repo ni en Firestore. Solo referencias a Secret Manager.

## Convenciones de código
- Sin comentarios salvo que aporten contexto no obvio.
- Modelos inmutables con `copyWith`, `toJson`/`fromJson` (sin codegen).
- Dinero con cifras tabulares.

## Notas
- Tras cambiar configuración de opencode, reiniciar opencode para que aplique.
