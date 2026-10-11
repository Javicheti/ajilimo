# AjíLimo — Design System

Estilo **Rappi premium**: denso en datos, limpio, con semáforos de estado.

## Principio de centralización
Todo el estilo vive en `shared/lib/design/`. **Prohibido** `Color(0x...)` fuera de esa carpeta.
Cambiar la marca = editar **un** lugar; se propaga a ambas apps.

```
shared/lib/design/
├── tokens.dart            # primitivos: Palette, Spacing, Radii, Durations, Breakpoints
├── brand.dart             # BrandPalette (white-label, fromJson/toJson)
├── semantic_colors.dart   # AppColors (ThemeExtension) + extensión context.colors
├── typography.dart        # Sora + Inter (fuentes empaquetadas en assets/fonts)
├── elevations.dart        # sombras
└── app_theme.dart         # AppTheme.light()/dark() desde tokens + BrandPalette
```

## Dos niveles
- **Primitivos** (`Palette`): valores crudos.
- **Semánticos** (`AppColors`): roles que consume la UI (`brandPrimary`, `success`, `channelRappi`…).
- Los widgets usan **roles** vía `context.colors`, nunca primitivos.

## Paleta
| Rol | Valor |
|---|---|
| Marca (primario) | `#FF441F` (hover `#E63A17`, soft `#FFE8E0`) |
| Éxito/Abierto | `#00C48C` |
| Alerta/Pausado | `#FFB020` |
| Peligro/Cerrado | `#FF3B30` |
| Suspendido | `#7C3AED` |
| Info | `#3B82F6` |
| Canales | Rappi `#FF441F` · DiDi `#FF8A00` · PedidosYa `#E5004D` |
| Superficie/Fondo/Borde | `#FFFFFF` / `#F7F7F8` / `#E6E6EA` |
| Oscuro | fondo `#0F0F12`, superficie `#1B1B1F`, borde `#2A2A31` |

## Tipografía
- **Roboto** para títulos y datos, con **cifras tabulares**.
- Fuentes **empaquetadas** en `shared/assets/fonts/` (sin fetch en runtime).

## Shell y navegación
La plataforma usa un **AppShell v2** (`shared/lib/navigation/app_shell.dart`) alineado a la
referencia del back-office de Rappi:
- **Header** (full width): marca AjíLimo (izq.) + **selector de país**, **notificaciones** con badge
  y **usuario** (nombre + rol + avatar con menú: tema / cerrar sesión) (der.).
- **Sidebar vertical claro** con grupos en mayúsculas, **ítem activo tipo pill relleno** (color de
  marca), hover animado, **badges** y pie con banderas + versión.
- **Responsive**: sidebar expandida (≥1080), rail de íconos (720–1080) y **drawer** (<720).
- **Gate por rol**; **modo oscuro** conmutable; **transiciones** de página (fade + slide).

## Páginas (paridad con back-office delivery)
Operación: **Torre de control** (KPIs + métricas de servicio con deltas), **Conectividad**,
**Órdenes**, **Horarios**, **Menú/Carta** (Tu Menú: tabs, chips, acordeón de categorías con
filas de producto, toggles), **Promos y sabores**. Defensa: **Reclamos**, **Evidencia (KORN)**.
Analítica: **Reportes**, **Financiero**. Configuración: Integraciones, Usuarios, Tenants.

## Componentes (Fase 1)
`AppShell`, `NavGroup`/`NavEntry`, `PageHeader`, `FilterBar`, `DataTableCard`, `EmptyState`,
`AppCard`, `StatusChip`, `ChannelBadge`, `KpiCard` (con tendencia), `SectionHeader`;
gráficos con `fl_chart`. Galería viva en la ruta **`/design`**.

Componentes previstos: `DataTable`, `AlertFeed`, `CountdownTimer` (24 h), `EvidenceViewer`,
`ScheduleEditor`, `FilterBar`, `EmptyState`, `SkeletonLoader`, `Chart`.

## White-label (por tenant/marca)
El color de marca es **administrable desde la app** (Firestore) sobre los tokens en código:
`BrandPalette.fromJson({ primary, primaryHover, soft })` → `AppTheme.light(brand: …)`.
Cada tenant/marca puede tener su acento sin recompilar.

## Pantallas (objetivo)
Torre de control · Tiendas (detalle) · Horarios y festivos · Promos y sabores · Órdenes ·
Reclamos · Evidencia (KORN) · Reportes · Alertas · Configuración.

## Flujo KORN
Checklist → Foto → Validación 10 s → Entregar (evidencia ligada al `order_id`).
