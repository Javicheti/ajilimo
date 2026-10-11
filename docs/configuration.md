# AjíLimo — Configuración (data-driven)

Todo es configurable en tiempo de ejecución: **nada** de credenciales ni URLs hardcodeadas.

## Capas
| Capa | Dónde vive | Contiene |
|---|---|---|
| Configuración | Firestore | canales, marcas, tiendas, mapeos, reglas, flags |
| Secretos | **Secret Manager** | `client_id/secret`, tokens, webhook secrets |
| Código | Repo | lógica genérica (sin valores) |

## Jerarquía y precedencia
`Tienda → Marca → Canal → Global` (el más específico gana).

## Registro de integraciones (dinámico)
Cada canal es una **fila de configuración**:
| Campo | Ejemplo |
|---|---|
| `provider` | `rappi` \| `didi` \| `pedidosya` |
| `environment` | `mock` \| `dev` \| `prod` |
| `baseUrl` | `https://api.dev.rappi.com` |
| `credentialsRef` | `secret://tenants/{id}/rappi/dev/oauth` |
| `status` | `connected` \| `error` \| `pending_auth` |
| `capabilities` | `orders, menu, availability, promos, claims, financial` |

El backend usa `DeliveryConnector` + `ConnectorFactory(provider)` → agregar canal = config + implementación.

## Configurable
- **Conexiones**: alta/edición de canal, entorno, base URL, "probar conexión", re-autorizar (OAuth PKCE).
- **Marcas y tiendas**: crear marca, mapear IDs por canal (`rappiStoreId`, `didiShopId`…).
- **Operación**: modo por tienda (`monitor` | `control`), horarios/festivos, cooking time objetivo.
- **Reglas**: umbrales (offline en horario > X min, cooking > X min, pico de pedidos), canales de alerta.
- **Seguridad**: usuarios/roles, quién edita credenciales, audit log.
- **Feature flags**: `korn`, `claims`, `reports`, `promos` por entorno/tenant.

## Cambio de entorno
El campo `environment` por canal permite **mock → dev → prod** sin recompilar, incluso
una marca en mock y otra en prod a la vez.
