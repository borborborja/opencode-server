#!/bin/bash
set -e
echo "--- opencode-server entrypoint ---"
echo "user $(id -u):$(id -g)  home=$HOME"

DEFAULTS=/usr/local/share/opencode-defaults
OCDIR="$HOME/.config/opencode"

# --- Config de opencode: la imagen manda. Se regenera en cada arranque desde la
#     plantilla (envsubst solo sustituye las vars nombradas → respeta "$schema"). ---
mkdir -p "$OCDIR" "$HOME/.config/mise" 2>/dev/null || true
if [ -f "$DEFAULTS/opencode.json.tpl" ]; then
  envsubst '${N8N_MCP_AUTH_TOKEN}' < "$DEFAULTS/opencode.json.tpl" > "$OCDIR/opencode.json"
  # Plugins opt-in (lista separada por comas en OPENCODE_PLUGINS) → se inyectan con jq
  if [ -n "${OPENCODE_PLUGINS:-}" ]; then
    arr=$(printf '%s' "$OPENCODE_PLUGINS" | jq -R 'split(",") | map(gsub("^\\s+|\\s+$";""))')
    tmp=$(mktemp); jq --argjson p "$arr" '.plugin = $p' "$OCDIR/opencode.json" > "$tmp" && mv "$tmp" "$OCDIR/opencode.json"
    echo "plugins habilitados: $OPENCODE_PLUGINS"
  fi
  echo "opencode.json regenerado desde plantilla"
fi

# --- Skills (agentes/comandos/reglas): sincronizados desde la imagen en cada arranque.
#     Los del proyecto (.opencode/) siguen teniendo prioridad. ---
[ -d "$DEFAULTS/agent" ]   && { mkdir -p "$OCDIR/agent";   cp -f "$DEFAULTS/agent/"*.md   "$OCDIR/agent/"   2>/dev/null || true; }
[ -d "$DEFAULTS/command" ] && { mkdir -p "$OCDIR/command"; cp -f "$DEFAULTS/command/"*.md "$OCDIR/command/" 2>/dev/null || true; }
[ -f "$DEFAULTS/AGENTS.md" ] && cp -f "$DEFAULTS/AGENTS.md" "$OCDIR/AGENTS.md" 2>/dev/null || true

# --- mise: config global sembrada si falta (no se pisa) ---
[ -f "$HOME/.config/mise/config.toml" ] || cp "$DEFAULTS/mise.toml" "$HOME/.config/mise/config.toml" 2>/dev/null || true

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
