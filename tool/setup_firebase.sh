#!/usr/bin/env bash
#
# AjíLimo · Configuración de Firebase (idempotente, NO invasivo).
#
# NO altera tu contexto de Fluxus:
#   · Firebase: la cuenta se fija SOLO para esta carpeta (activeAccounts).
#   · gcloud: se configura la config "ajilimo" con --configuration (sin activarla).
# Al terminar, tu Firebase global y tu gcloud "default" siguen en Fluxus.
#
# Uso:  bash tool/setup_firebase.sh

set -euo pipefail

PROJECT_ID="ajilimo-830ca"
ACCOUNT="javicheti001@gmail.com"
CONFIG_NAME="ajilimo"
FLUTTERFIRE="$HOME/.pub-cache/bin/flutterfire"

echo "▶ 1/5 Añadiendo la cuenta $ACCOUNT a Firebase CLI (si hace falta)…"
firebase login:add "$ACCOUNT" || true

echo "▶ 2/5 Fijando $ACCOUNT para ESTA carpeta (requiere .firebaserc)…"
firebase login:use "$ACCOUNT"

echo "▶ 3/5 Configurando gcloud '$CONFIG_NAME' sin activarla globalmente…"
if ! gcloud config configurations describe "$CONFIG_NAME" >/dev/null 2>&1; then
  gcloud config configurations create "$CONFIG_NAME" --no-activate
fi
gcloud --configuration "$CONFIG_NAME" config set account "$ACCOUNT"
gcloud --configuration "$CONFIG_NAME" config set project "$PROJECT_ID"

echo "▶ 4/5 Compilando Cloud Functions…"
if [ -f backend/functions/package.json ]; then
  npm --prefix backend/functions install --no-audit --no-fund
  npm --prefix backend/functions run build
else
  echo "   (sin functions aún; se omite)"
fi

echo "▶ 5/5 Deploy de reglas e índices…"
firebase deploy \
  --only firestore:rules,firestore:indexes,storage \
  --account "$ACCOUNT" \
  --project "$PROJECT_ID"

echo "✅ Listo. Tu contexto de Fluxus no fue modificado:"
echo "   · Firebase global sigue en fluxus.dev.lat@gmail.com"
echo "   · gcloud activo sigue en la config 'default'"
echo "   Para AjíLimo usa: gcloud --configuration $CONFIG_NAME ..."
