#!/usr/bin/env bash
#
# Refresco automático del bridge (casi tiempo real).
# Re-ejecuta: captura (sesión guardada) → menús → parse → publish, cada INTERVAL.
#
# Uso:
#   INTERVAL=300 bash refresh.sh        # cada 5 min (por defecto)
#   RUN_ONCE=1 bash refresh.sh          # una sola pasada
#
# Requisitos: haber corrido antes `npm run capture` (crea out/state.json) e
# `npx playwright install chromium`.
#
# Nota: el JWT dura ~2 h. Si la sesión caduca, inicia sesión con:
#   HEADLESS=0 AUTO_SECONDS=120 node capture.mjs

set -uo pipefail
cd "$(dirname "$0")"

INTERVAL="${INTERVAL:-300}"
RUN_ONCE="${RUN_ONCE:-0}"
TOKEN="$(grep '^BRIDGE_TOKEN=' ../../functions/.env | cut -d= -f2 || true)"

NAV="https://partners.rappi.com/connectivity,https://partners.rappi.com/orders,https://partners.rappi.com/menu"

cycle() {
  echo "──────────────────────────────────────────────"
  echo "[bridge] refresh $(date '+%Y-%m-%d %H:%M:%S')"
  USE_STATE=1 HEADLESS=1 AUTO_SECONDS=8 NAV_URLS="$NAV" node capture.mjs >/dev/null 2>&1 || echo "  capture: fallo"
  node menu.mjs 2>&1 | tail -1 || echo "  menu: fallo"
  node parse.mjs 2>&1 | tail -5 || echo "  parse: fallo"
  if [ -n "$TOKEN" ]; then
    BRIDGE_TOKEN="$TOKEN" node publish.mjs 2>&1 | tail -1 || echo "  publish: fallo"
  else
    echo "  publish: sin BRIDGE_TOKEN (define en backend/functions/.env)"
  fi
}

if [ "$RUN_ONCE" = "1" ]; then
  cycle
  exit 0
fi

echo "[bridge] refrescando cada ${INTERVAL}s. Ctrl+C para detener."
while true; do
  cycle
  sleep "$INTERVAL"
done
