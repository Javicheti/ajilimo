# AjíLimo — Mapeo de APIs (Rappi, DiDi, PedidosYa)

Base de autenticación Rappi: `x-authorization: Bearer <token>` (token de
`POST /restaurants/auth/v1/token/login/integrations`, válido ~1 semana).
Dominio dev: `https://api.dev.rappi.com`; producción por país: `https://api.rappi.pe` (Perú).
Ruta base `/{module}/v1` para la API nueva (`restaurants/`). Base para la API pública:
`/api/v2/restaurants-integrations-public-api` (dominio `services.rappi.pe`).

## Matriz de capacidades vs. lo que pide el cliente

| Requisito cliente | Rappi | Fuente |
|---|---|---|
| 1a Revisión diaria de horarios | ✅ | Utils `GET store/schedule/{storeId}` + `schedules_info` |
| 1b Conexión (abierto/cerrado/pausado/suspendido) | 🟡 | `POST availability/stores` (bool) + cruce horario + webhook `STORE_CONNECTIVITY`; suspensión en respuesta de `PUT .../enable` |
| 1c Horarios por días festivos | ✅ | Utils `GET store/schedule/{storeId}/holiday` y `/special` |
| 1d "Alta demanda" | ❌ | Inferencia (picos) + marcado manual |
| 2a Promos prendidas | ✅* | `suspension_info.is_available` + `is_category_active` (si la promo es ítem/categoría) |
| 2b Sabores prendidos | ✅ | Rests Menu `items` / Utils `menu/integration/{integrationId}` |
| 2c Promo a precio full | ✅ | `price_info` (+overrides) vs. precio real en órdenes |
| 3 Cooking time 22 min | ✅ | `PUT .../orders/{orderId}/cooking_time/{cookingTime}/take` |
| 4 Responder reclamos | ❌ Rappi / ✅ DiDi | DiDi `Handle Cancellation/Refund` + webhooks |
| 5 Reporte diario de ventas | ✅ | Órdenes + **Financial API** |

## Rappi — endpoints usados

### Auth
- `POST /restaurants/auth/v1/token/login/integrations` → `access_token` (M2M).

### Tiendas (Self-Onboarding, doble token)
- `GET /api/v2/restaurants-integrations-public-api/stores/integration-status` →
  tiendas con `integrated: true|false` y `children[]`.
  Headers: `X-Authorization: Bearer <integrator JWT>` + `Authorization-Partners: Bearer <merchant id_token>`.
- `POST /api/v2/restaurants-integrations-public-api/stores/provisioning` (máx 20, async 202 → webhook `STORE_PROVISIONING_STATUS`).
- `POST /api/v2/restaurants-integrations-public-api/stores/deprovisioning`.
- `GET /api/v2/restaurants-integrations-public-api/stores-pa` → tiendas del aliado.

### Menú (Rests API — programa por invitación)
- `GET /restaurants/menu/v1/stores/{storeId}/items` y `/store-menu` →
  `suspension_info` (`is_available`, `suspend_until`, `suspend_reason`, overrides STORE/ITEM),
  `schedules_info` (`days_of_week` incl. `hol`), `price_info`, `is_category_active`.
- `POST/PUT/DELETE` para crear/actualizar ítems, categorías y menús.

### Disponibilidad
- `POST /restaurants/menu/v1/stores/{storeId}/products/{identityType}/stock/status` → stock por SKU/ID.
- `PATCH /restaurants/menu/v1/stores/{storeId}/items/{identityType}/stock` → activar/desactivar.
- `POST /api/v2/restaurants-integrations-public-api/availability/stores` → estado online/offline (bool).
- `PUT /api/v2/restaurants-integrations-public-api/availability/stores/enable` →
  sincrónico; respuesta con `operation_result_type: "suspended"`, `suspended_reason`, `suspended_at`.

### Órdenes (Rests API)
- `GET /restaurants/orders/v1/stores/{storeId}/orders` → órdenes `READY` (solo una vez).
- `PUT /restaurants/orders/v1/stores/{storeId}/orders/{orderId}/take`.
- `PUT /restaurants/orders/v1/stores/{storeId}/orders/{orderId}/cooking_time/{cookingTime}/take`.
- `PUT .../orders/{orderId}/cancel_type/{cancelType}/reject`.
- `POST .../orders/{orderId}/ready-for-pickup`.
- `POST .../orders/{orderId}/bag-drink-confirmation`.
- `GET .../orders/{orderId}/handoff`.

### Utils (horarios / estado de productos)
- `GET store/schedule/{storeId}`, `/holiday`, `/special` (+ POST/PUT/DELETE).
- `GET menu/integration/{integrationId}` → productos/toppings con `active`, `isAvailable`, `activated`.

### Financiero (conciliación y reportes)
- `POST /restaurants/auth/v1/token/login/finance`.
- `GET /v2/stores/{store_id}/payments | orders | order_adjusments | charged_cancellations |
  cancellations | compensations | taxes | store_adjustments | loans | debts | extras | agreements`.

### Webhooks (eventos)
`NEW_ORDER`, `NEW_ORDER_SCHEDULED`, `NEW_ORDER_SCHEDULED_CANCELLED`, `ORDER_EVENT_CANCEL`,
`ORDER_OTHER_EVENT`, `MENU_APPROVED`, `MENU_REJECTED`, `PING`, `STORE_CONNECTIVITY`,
`ORDER_RT_TRACKING`, `STORE_PROVISIONING_STATUS`.
Seguridad: header `Rappi-Signature: t=<ts>,sign=<hmac-sha256(t + "." + payload, secret)>`.

## DiDi Food (reclamos)
- Auth: `app_id` + `app_secret` + `app_shop_id` → `auth_token` (`GET /v1/auth/authtoken/get`).
- Store API: `Set/Get Store Details`, `Set Store Status`, `Set Store Cancellation/Refund`.
- Order API: `Confirm Order`, `Cancel Order`, `Order Ready`, `Adjust Order Items`.
- Reclamos: `POST /v1/order/apply/cancel` y `POST /v1/order/apply/refund` + webhooks
  (`orderCancelApply`, `orderRefundApply`).
- Firma de webhook: header `didi-header-sign` = `MD5(rawBody + app_secret)`. IDs `int64`.

## PedidosYa (Partner API)
- Auth: OAuth2 Client Credentials (`POST /v2/oauth/token`).
- Órdenes: webhook + `GET/PUT /v2/chains/{chain_id}/orders/{order_id}`.
- Catálogo: `POST/GET/PUT .../catalog` (alta en BETA).
- Outlet: `GET/PUT` estado del local (online/offline/busy) y horarios.
- Promotions: `GET/PUT` (estado de promoción).
- Reclamos: **no hay API** (solo cancelaciones).

## Límites operativos (Rappi)
- Órdenes: descarga cada ~45 s; tomar/rechazar dentro de 4–6 min.
- Disponibilidad: 100 ítems y 100 tiendas por request; 300 en `enable` síncrono.
- Provisioning: 20 tiendas por solicitud. `ready-for-pickup`: máx 3 llamadas.
