#!/bin/bash
set -e
echo "--- opencode-server entrypoint ---"
echo "user $(id -u):$(id -g)  home=$HOME"

# OPCIÓN 1 — autoactualización: en cada arranque instala la última opencode
# en el prefijo del HOME (volumen, escribible por uid 1000). Si falla (sin red),
# se usa la versión horneada en /usr/local.
if [ "${AUTO_UPDATE:-true}" = "true" ]; then
  echo "AUTO_UPDATE=on → npm i -g opencode-ai@latest (prefix $NPM_CONFIG_PREFIX)"
  mkdir -p "$NPM_CONFIG_PREFIX" 2>/dev/null || true
  npm install -g opencode-ai@latest || echo "warn: update failed → using baked version"
fi

OPENCODE_BIN="$(command -v opencode || echo /usr/local/bin/opencode)"
echo "opencode bin: $OPENCODE_BIN"
"$OPENCODE_BIN" --version || echo "warn: no version"

# Identidad git + repos montados como safe
git config --global user.email "${GIT_USER_EMAIL:-agent@opencode.local}" || true
git config --global user.name  "${GIT_USER_NAME:-opencode}"              || true
git config --global --add safe.directory '*'                            || true
git config --global init.defaultBranch main                             || true

# Servidor headless: web UI (desktop/navegador) + API (terminal 'attach')
exec "$OPENCODE_BIN" web --hostname 0.0.0.0 --port 4096 --cors "*"
