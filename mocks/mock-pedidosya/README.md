# mock-pedidosya

Mock de **PedidosYa** (Partner API / Delivery Hero) para pruebas sin credenciales.

```bash
npm start   # http://localhost:8791
npm test
```

Endpoints: `POST /v2/oauth/token`, `GET /v2/chains/:chainId/vendors`,
`GET /v2/vendors/:id/catalog`, `GET /v2/vendors/:id/status`,
`GET /v2/chains/:chainId/orders`, `PUT /v2/chains/:chainId/orders/:orderId`.
