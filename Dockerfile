# opencode-server — imagen endurecida y autoactualizable de OpenCode.
# - Base ligera node:22-slim
# - Corre como no-root (uid 1000 "node")
# - opencode "horneado" como fallback; AUTO_UPDATE lo refresca en cada arranque
# - Persistencia XDG correcta (todo cuelga de $HOME, que se monta como volumen)
FROM node:22-slim
LABEL org.opencontainers.image.source="https://github.com/borborborja/opencode-server"
LABEL org.opencontainers.image.description="Hardened self-updating OpenCode server (non-root, basic-auth, XDG-correct persistence)"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      git curl ca-certificates ripgrep openssh-client less fzf jq \
    && rm -rf /var/lib/apt/lists/*

# opencode horneado en /usr/local (default prefix, propiedad de root → fuera del volumen HOME)
RUN npm install -g opencode-ai@latest

# A partir de aquí, el prefijo npm apunta al HOME (volumen) para el AUTO_UPDATE en runtime.
ENV HOME=/home/node \
    XDG_DATA_HOME=/home/node/.local/share \
    XDG_CONFIG_HOME=/home/node/.config \
    NPM_CONFIG_PREFIX=/home/node/.npm-global \
    PATH=/home/node/.npm-global/bin:/usr/local/bin:/usr/bin:/bin \
    IN_DOCKER=true

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /home/node/projects
EXPOSE 4096
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
