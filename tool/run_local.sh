#!/usr/bin/env bash
#
# AjíLimo · Prueba local con datos ficticios.
# Levanta los 3 mocks + el emulador de Cloud Functions (BFF) para que la app
# funcione contra datos ficticios. Al agregar credenciales reales, solo cambia
# la configuración (RAPPI_BASE_URL, etc.); no se toca el código.
#
# Uso:  bash tool/run_local.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PIDS=()

cleanup() {
  echo ""
  echo "▶ Deteniendo procesos locales…"
  for pid in "${PIDS[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
}
trap cleanup EXIT INT TERM

echo "▶ 1/4 Compilando backend…"
npm --prefix "$ROOT/backend/functions" run build

echo "▶ 2/4 Levantando mocks (rappi :8787, didi :8790, pedidosya :8791)…"
( cd "$ROOT/mocks/mock-rappi" && node server.mjs ) & PIDS+=($!)
( cd "$ROOT/mocks/mock-didi" && node server.mjs ) & PIDS+=($!)
( cd "$ROOT/mocks/mock-pedidosya" && node server.mjs ) & PIDS+=($!)

echo "▶ 3/4 Arrancando emulador de Functions (BFF en :5001)…"
echo "   La app (backoffice) apunta a:"
echo "   http://127.0.0.1:5001/ajilimo-830ca/us-central1/api"
echo ""
echo "▶ 4/4 Uso:"
echo "   · BFF:   curl http://127.0.0.1:5001/ajilimo-830ca/us-central1/api/control-tower"
echo "   · App:   cd apps/backoffice && flutter run -d chrome"
echo ""
echo "   Ctrl+C para detener todo."
echo ""

firebase --project ajilimo-830ca --account javicheti001@gmail.com emulators:start --only functions
