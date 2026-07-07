# opencode-server

Imagen Docker **endurecida y autoactualizable** de [OpenCode](https://opencode.ai),
pensada para exponerse por un túnel/reverse-proxy.

Sustituye al viejo [`opencode-docker`](https://github.com/borborborja/opencode-docker) arreglando:

| | `opencode-docker` | `opencode-server` |
|---|---|---|
| Usuario | root | **no-root (uid 1000)** |
| Auth | ninguna | **basic-auth** (`OPENCODE_SERVER_PASSWORD`) |
| Flag web | `--host` (obsoleto) | `--hostname` |
| Persistencia | `/root/.opencode` (rutas viejas) | **HOME entero** (XDG correcto: `~/.local/share/opencode`, `~/.config/opencode`) |
| Autoupdate | flag, off por defecto | **on por defecto** (`AUTO_UPDATE`) |
| Imagen | build local | **publicada en `ghcr.io`** por CI (+ Watchtower) |

## Uso

```bash
cp .env.example .env      # pon OPENCODE_SERVER_PASSWORD y OPENROUTER_API_KEY
docker compose up -d
```

- Web/desktop: `http://localhost:4096` (usuario `opencode`, tu password).
- Terminal: `opencode attach http://HOST:4096 -u opencode -p '...' --dir /home/node/projects/<proyecto>`.

## Mantenimiento

- `AUTO_UPDATE=true` reinstala la última opencode en cada arranque → un `docker restart` la actualiza.
- La imagen se reconstruye y publica en `ghcr.io/borborborja/opencode-server:latest` en cada push a `main`
  y semanalmente; con Watchtower activo, se despliega sola.
