#!/usr/bin/env bash
#
# Instala/desinstala el agente de launchd que mantiene el bridge actualizado.
#
# macOS (TCC) NO permite a launchd ejecutar scripts dentro de ~/Downloads, por eso
# copiamos el runner a ~/Library/Application Support/ajilimo-bridge y apuntamos ahí.
#
# Uso:
#   bash tool/install_bridge_agent.sh            # instalar + arrancar
#   bash tool/install_bridge_agent.sh uninstall   # detener + quitar

set -euo pipefail

LABEL="com.ajilimo.bridge"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
SRC="$(cd "$(dirname "$0")/../backend/scrapers/rappi-portal" && pwd)"
DEST="$HOME/Library/Application Support/ajilimo-bridge"
INTERVAL="${INTERVAL:-300}"
NODE_BIN="$(command -v node || true)"

if [ "${1:-}" = "uninstall" ]; then
  launchctl unload "$PLIST" 2>/dev/null || true
  rm -f "$PLIST"
  rm -rf "$DEST"
  echo "✅ Agente desinstalado y runner eliminado."
  exit 0
fi

if [ -z "$NODE_BIN" ]; then
  echo "❌ No se encontró 'node' en PATH. Instala Node o ajusta PATH."
  exit 1
fi

# Token del bridge desde backend/functions/.env.
TOKEN="$(grep '^BRIDGE_TOKEN=' "$SRC/../../functions/.env" | cut -d= -f2 || true)"

echo "▶ Copiando runner a: $DEST"
mkdir -p "$DEST/out"
cp "$SRC"/*.mjs "$SRC/package.json" "$DEST/" 2>/dev/null || true
rm -rf "$DEST/node_modules"
cp -R "$SRC/node_modules" "$DEST/node_modules" 2>/dev/null || true
cp "$SRC/out/state.json" "$DEST/out/state.json" 2>/dev/null || true

cat > "$DEST/run.sh" <<EOF
#!/usr/bin/env bash
export PATH="$(dirname "$NODE_BIN"):/usr/local/bin:/usr/bin:/bin:\$PATH"
export BRIDGE_TOKEN="$TOKEN"
cd "$DEST"
NAV="https://partners.rappi.com/connectivity,https://partners.rappi.com/orders,https://partners.rappi.com/menu"
while true; do
  echo "[\$(date '+%H:%M:%S')] refresh"
  USE_STATE=1 HEADLESS=1 AUTO_SECONDS=8 NAV_URLS="\$NAV" node capture.mjs >/dev/null 2>&1 || echo "capture fallo"
  node menu.mjs 2>&1 | tail -1 || true
  node parse.mjs 2>&1 | tail -3 || true
  BRIDGE_TOKEN="\$BRIDGE_TOKEN" node publish.mjs 2>&1 | tail -1 || true
  sleep $INTERVAL
done
EOF
chmod +x "$DEST/run.sh"

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$DEST/run.sh</string>
  </array>
  <key>WorkingDirectory</key><string>$DEST</string>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>StandardOutPath</key><string>/tmp/ajilimo-bridge.log</string>
  <key>StandardErrorPath</key><string>/tmp/ajilimo-bridge.err</string>
</dict>
</plist>
EOF

launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"

echo "✅ Instalado y arrancado: $PLIST"
echo "   Runner: $DEST/run.sh · refresco cada ${INTERVAL}s"
echo "   Logs: /tmp/ajilimo-bridge.log  ·  /tmp/ajilimo-bridge.err"
echo "   Desinstalar: bash tool/install_bridge_agent.sh uninstall"
