# mock-rappi

Réplica del **contrato documentado** de Rappi (RESTs API / Public API) para
desarrollar y probar AjíLimo **sin credenciales reales**. Incluye un **emisor de
webhooks firmados con HMAC-SHA256** (igual que producción).

## Uso
```bash
cd mocks/mock-rappi
npm start          # http://localhost:8787
npm test           # pruebas del contrato + firma de webhooks
```

## Endpoints simulados
- `GET /health`
- `POST /restaurants/auth/v1/token/login/integrations` → `access_token`
- `GET /api/v2/restaurants-integrations-public-api/stores-pa`
- `POST /api/v2/restaurants-integrations-public-api/availability/stores`
- `GET /restaurants/menu/v1/stores/{storeId}/items` (con `suspension_info`, `schedules_info`)
- `GET /restaurants/orders/v1/stores/{storeId}/orders`

## Simular un webhook
```bash
curl -X POST http://localhost:8787/_simulate/webhook \
  -H 'content-type: application/json' \
  -d '{"event":"STORE_CONNECTIVITY","url":"http://localhost:8788/webhooks/rappi","overrides":{"enabled":false}}'
```
Eventos: `NEW_ORDER`, `STORE_CONNECTIVITY`, `ORDER_EVENT_CANCEL`.

La firma viaja en el header `Rappi-Signature: t=<ts>,sign=<hmac>` usando
`WEBHOOK_SECRET` (`mock-rappi-secret`), verificable con `signPayload()`.
