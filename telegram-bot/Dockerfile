# opencode-telegram — contenedor del bot @grinev/opencode-telegram-bot.
# Habla por HTTP con un server OpenCode existente (no arranca el suyo).
FROM node:22-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g @grinev/opencode-telegram-bot@latest
COPY bot-entrypoint.sh /usr/local/bin/bot-entrypoint.sh
RUN chmod +x /usr/local/bin/bot-entrypoint.sh
ENV HOME=/home/node
WORKDIR /home/node
ENTRYPOINT ["/usr/local/bin/bot-entrypoint.sh"]
