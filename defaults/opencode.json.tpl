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
  "provider": {
    "ollama-cloud": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama Cloud",
      "options": {
        "baseURL": "https://ollama.com/v1",
        "apiKey": "{env:OLLAMA_API_KEY}"
      },
      "models": {
        "qwen3-coder:480b": { "name": "Qwen3 Coder 480B (cloud)" },
        "qwen3-coder-next": { "name": "Qwen3 Coder Next (cloud)" },
        "deepseek-v3.1:671b": { "name": "DeepSeek V3.1 671B (cloud)" },
        "deepseek-v4-pro": { "name": "DeepSeek V4 Pro (cloud)" },
        "gpt-oss:120b": { "name": "GPT-OSS 120B (cloud)" },
        "gpt-oss:20b": { "name": "GPT-OSS 20B (cloud)" },
        "kimi-k2.7-code": { "name": "Kimi K2.7 Code (cloud)" },
        "glm-5.2": { "name": "GLM-5.2 (cloud)" },
        "minimax-m3": { "name": "MiniMax M3 (cloud)" },
        "mistral-large-3:675b": { "name": "Mistral Large 3 675B (cloud)" }
      }
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
