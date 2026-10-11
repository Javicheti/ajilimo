# AjíLimo — Estrategia de pruebas (mock → DEV → prod)

## Principio
No depender de credenciales para desarrollar. Se programa contra el **contrato documentado**
y se prueba con **mocks**; el cambio a real es **configuración**, no código.

## Niveles
1. **Mock propio** (`mocks/mock-rappi`, y `mock-didi` en Fase 7)
   - Réplica de endpoints reales + emisor de **webhooks firmados** (HMAC-SHA256 / MD5).
   - Generador de escenarios (órdenes, caídas de conexión, suspensiones, reclamos).
2. **DEV de Rappi** (`api.dev.rappi.com`, `microservices.dev.rappi.com`)
   - Cuando lleguen credenciales (`client_id/secret` + `TAM`/Auth0). Simulador de órdenes del *Integrations Manager*.
3. **Producción controlada**
   - 1–2 locales en modo `monitor` antes de habilitar acciones.

## Switch de entorno
```
RAPPI_BASE_URL = mock | dev | prod
RAPPI_CLIENT_ID / RAPPI_CLIENT_SECRET = (vacíos en mock)
WEBHOOK_SECRET = (mismo en mock y real)
```

## Pirámide de pruebas
| Capa | Qué verifica | Herramienta |
|---|---|---|
| Contrato | El mock respeta el JSON real | `node --test` (mocks) |
| Unit | Conectores, normalizadores, reglas, casos de uso | `flutter test`, `node --test` |
| Integración | Webhook → Pub/Sub → Firestore/BigQuery (firma real) | emuladores + `node --test` |
| Widget | Componentes `shared/` y pantallas | `flutter test` |
| E2E mock | Orden → alerta → acción → reporte | script de escenarios |

## CI (por PR)
- `dart analyze` + `flutter test` en `shared/`, `apps/backoffice`, `apps/korn_tablet`.
- `tsc` en `backend/functions`.
- `node --test` en `mocks/mock-rappi`.
- Build web de `apps/backoffice`.

## Cómo probar con datos ficticios (local)
```bash
bash tool/run_local.sh          # levanta mocks (:8787/8790/8791) + emulador BFF (:5001)
cd apps/backoffice && flutter run -d chrome
```
La app consume el BFF (`.../us-central1/api/control-tower`); si no está disponible,
cae a datos ficticios locales (seed). Al agregar credenciales reales solo cambia la
config (`RAPPI_BASE_URL`, `DIDI_BASE_URL`, `PEDIDOSYA_BASE_URL`) y el backend de secretos.

## Estado
- ✅ `shared`: 5 tests.
- ✅ `apps/backoffice`: 34 tests + `flutter build web`.
- ✅ `apps/korn_tablet`: 3 tests.
- ✅ `mocks/mock-rappi`: 6 · `mocks/mock-didi`: 5 · `mocks/mock-pedidosya`: 2.
- ✅ `backend/functions`: 58 tests (conectores, config, seguridad, dominio, BFF, admin) + `tsc`.
- ✅ Funciones desplegadas en `ajilimo-830ca`: `health`, `rappiWebhook`, `api`, `bootstrapOwner`, `setUserRole`.
- ✅ BFF verificado end-to-end contra los mocks (torre, órdenes, reclamos, conexiones).
- **Total: 113 tests.**

