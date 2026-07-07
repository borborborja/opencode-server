#!/bin/bash
set -e
echo "--- opencode-server entrypoint ---"
echo "user $(id -u):$(id -g)  home=$HOME"

DEFAULTS=/usr/local/share/opencode-defaults

# --- Sembrar config si el volumen HOME viene vacío (no pisa lo que ya exista) ---
mkdir -p "$HOME/.config/opencode" "$HOME/.config/mise" 2>/dev/null || true
[ -f "$HOME/.config/opencode/opencode.json" ] || cp "$DEFAULTS/opencode.json" "$HOME/.config/opencode/opencode.json" 2>/dev/null || true
[ -f "$HOME/.config/mise/config.toml" ]       || cp "$DEFAULTS/mise.toml"     "$HOME/.config/mise/config.toml" 2>/dev/null || true

# --- Toolchain: instala los runtimes de mise en segundo plano (no bloquea el arranque) ---
# Primera vez que el volumen está vacío tarda unos minutos; luego es instantáneo (persistido).
if command -v mise >/dev/null 2>&1; then
  echo "mise: $(mise --version) → instalando runtimes en segundo plano (log en \$HOME/.cache/mise-install.log)"
  mkdir -p "$HOME/.cache" 2>/dev/null || true
  ( mise install -y >"$HOME/.cache/mise-install.log" 2>&1 && echo "mise install: OK" >>"$HOME/.cache/mise-install.log" ) &
fi

# --- OPCIÓN 1 — autoactualización de opencode en cada arranque ---
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
