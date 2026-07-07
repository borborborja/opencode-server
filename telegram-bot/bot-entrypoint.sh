#!/bin/bash
set -e
CFG="$HOME/.config/opencode-telegram-bot"
mkdir -p "$CFG"
# Escribe el .env que espera el bot desde las variables del contenedor (evita el wizard)
cat > "$CFG/.env" <<INNER
TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
TELEGRAM_ALLOWED_USER_ID=${TELEGRAM_ALLOWED_USER_ID}
OPENCODE_API_URL=${OPENCODE_API_URL:-http://opencode:4096}
OPENCODE_SERVER_USERNAME=${OPENCODE_SERVER_USERNAME:-opencode}
OPENCODE_SERVER_PASSWORD=${OPENCODE_SERVER_PASSWORD}
OPENCODE_MODEL_PROVIDER=${OPENCODE_MODEL_PROVIDER:-openrouter}
OPENCODE_MODEL_ID=${OPENCODE_MODEL_ID}
INNER
echo "opencode-telegram: config escrita (API=${OPENCODE_API_URL:-http://opencode:4096}, user permitido=${TELEGRAM_ALLOWED_USER_ID})"
exec opencode-telegram start
