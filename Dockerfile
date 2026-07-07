# opencode-server — imagen endurecida y autoactualizable de OpenCode.
# - Base ligera node:22-slim, corre como no-root (uid 1000 "node")
# - Toolchain "lean + mise": los runtimes (Node/Python/Go/Rust) se instalan por
#   proyecto bajo demanda con mise y persisten en el volumen HOME.
# - opencode "horneado" como fallback; AUTO_UPDATE lo refresca en cada arranque.
FROM node:22-slim
LABEL org.opencontainers.image.source="https://github.com/borborborja/opencode-server"
LABEL org.opencontainers.image.description="Hardened self-updating OpenCode server (non-root, basic-auth, mise toolchain, MCP)"

ENV DEBIAN_FRONTEND=noninteractive

# --- Toolchain base (build tools + CLIs de dev) ---
RUN apt-get update && apt-get install -y --no-install-recommends \
      git curl wget ca-certificates gnupg gettext-base \
      build-essential make cmake pkg-config \
      ripgrep fd-find jq sqlite3 unzip less fzf openssh-client \
    && ln -sf "$(command -v fdfind)" /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/*

# --- Librerías de sistema para el Chromium de Playwright (el binario del navegador
#     se descarga al volumen HOME en el primer uso; aquí solo las deps del SO) ---
RUN npx -y playwright@latest install-deps chromium \
    && rm -rf /var/lib/apt/lists/*

# --- GitHub CLI (gh) ---
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# --- mise (runtimes por-proyecto) + uv (Python) en /usr/local (fuera del volumen HOME) ---
RUN curl -fsSL https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh \
    && curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh \
    && corepack enable   # habilita pnpm y yarn

# --- opencode horneado en /usr/local (default prefix → fuera del volumen HOME) ---
RUN npm install -g opencode-ai@latest

# Defaults sembrados por el entrypoint si el volumen HOME viene vacío
COPY defaults/ /usr/local/share/opencode-defaults/

# A partir de aquí, prefijo npm y shims de mise apuntan al HOME (volumen) para runtime.
ENV HOME=/home/node \
    XDG_DATA_HOME=/home/node/.local/share \
    XDG_CONFIG_HOME=/home/node/.config \
    NPM_CONFIG_PREFIX=/home/node/.npm-global \
    MISE_DATA_DIR=/home/node/.local/share/mise \
    PLAYWRIGHT_BROWSERS_PATH=/home/node/.cache/ms-playwright \
    PATH=/home/node/.npm-global/bin:/home/node/.local/share/mise/shims:/usr/local/bin:/usr/bin:/bin \
    IN_DOCKER=true

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /home/node/projects
EXPOSE 4096
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
