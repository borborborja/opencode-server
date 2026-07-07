# Reglas globales del agente

- **No inventes APIs, parámetros ni nombres de nodos.** Antes de escribir código que
  use una librería, consulta su documentación real con el MCP **context7**. Para
  construir/validar workflows de **n8n**, usa el MCP **n8n** (lista nodos, sus
  parámetros y valida antes de proponer nada).
- **Valida antes de dar por hecho.** Ejecuta el código o los tests cuando sea posible;
  no afirmes que algo funciona sin comprobarlo.
- **Git con cuidado.** Nunca hagas `git push` ni comandos destructivos (`rm -rf`) sin
  que el usuario lo pida explícitamente. Trabaja en ramas, no en `main`.
- **Secretos.** No leas ni imprimas ficheros `.env` ni claves. Si necesitas un valor,
  pídelo o usa variables de entorno.
- **Estilo.** Imita el estilo del código existente (naming, comentarios, idioma).
  Cambios pequeños y revisables.
- **Navegador.** Para inspeccionar webs o reproducir bugs de UI, usa el MCP
  **playwright**.
