{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "bash": {
      "*": "ask",
      "git *": "allow",
      "git push *": "deny",
      "rm -rf *": "deny",
      "npm *": "allow",
      "pnpm *": "allow",
      "yarn *": "allow",
      "mise *": "allow",
      "uv *": "allow",
      "go *": "allow",
      "cargo *": "allow"
    }
  },
  "mcp": {
    "filesystem": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "/home/node/projects"],
      "enabled": true
    },
    "context7": {
      "type": "local",
      "command": ["npx", "-y", "@upstash/context7-mcp"],
      "enabled": true
    },
    "playwright": {
      "type": "local",
      "command": ["npx", "-y", "@playwright/mcp@latest", "--headless", "--isolated"],
      "enabled": true
    },
    "n8n": {
      "type": "remote",
      "url": "http://n8n-mcp:3000/mcp",
      "enabled": true,
      "headers": { "Authorization": "Bearer ${N8N_MCP_AUTH_TOKEN}" }
    }
  }
}
