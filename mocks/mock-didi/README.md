# mock-didi

Mock de **DiDi Food** para desarrollar y probar sin credenciales. Incluye firma
**MD5** (`MD5(rawBody + app_secret)`).

## Uso
```bash
cd mocks/mock-didi
npm start     # http://localhost:8790
npm test
```

## Endpoints
- `GET /v1/auth/authtoken/get`, `GET /v1/shop/list`, `GET /v1/menu/list`,
  `GET /v1/shop/status`, `GET /v1/order/list`
- `POST /v1/order/confirm`, `POST /v1/order/apply/refund`
- `POST /_simulate/webhook` (firma MD5 con `DIDI_WEBHOOK_SECRET = mock-didi-secret`)
