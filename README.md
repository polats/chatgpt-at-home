# ChatGPT at Home

<p align="center">
  <img src="assets/at-home.jpg" alt="ChatGPT at Home" width="500">
</p>

Your own ChatGPT — for free. No API costs, no subscriptions, no catch.

A single-container deployment of [Open WebUI](https://github.com/open-webui/open-webui) + [Open Terminal](https://github.com/open-webui/open-terminal), pre-configured with 100+ free AI models via [NVIDIA NIM](https://build.nvidia.com).

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/free-open-webui-terminal)

## What You Get

- Full ChatGPT-style interface with markdown, images, and file support
- Code execution in the browser via Open Terminal
- 100+ free models (Qwen, LLaMA, Mistral, and more) via NVIDIA NIM
- Zero configuration — just add your free API key and go

## Quick Start

### One-Click Deploy (Railway)

1. Click the **Deploy on Railway** button above
2. Get a free API key from [NVIDIA NIM](https://build.nvidia.com/settings/api-keys) (no credit card needed)
3. Paste it as `NVIDIA_NIM_API_KEY`
4. Wait for the build to finish, open the generated URL
5. Create an account and start chatting

### Run Locally (Docker)

```bash
docker build -t chatgpt-at-home .
docker run -d -p 3000:8080 -e NVIDIA_NIM_API_KEY=your-key-here chatgpt-at-home
```

Open http://localhost:3000, create an account, and you're in.

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `NVIDIA_NIM_API_KEY` | Yes | — | Free API key from [NVIDIA NIM](https://build.nvidia.com/settings/api-keys) |
| `DEFAULT_MODELS` | No | `qwen/qwen3.5-122b-a10b` | Pre-selected model for new users |
| `OPENAI_API_BASE_URL` | No | `https://integrate.api.nvidia.com/v1` | Override to use a different OpenAI-compatible provider |
| `OPENAI_API_KEY` | No | Falls back to `NVIDIA_NIM_API_KEY` | Override if using a different provider |

## How It Works

The Dockerfile bakes Open WebUI and Open Terminal into a single container. On startup, it:

1. Launches Open Terminal on an internal port for code execution
2. Configures Open WebUI to connect to NVIDIA NIM and Open Terminal
3. Auto-generates secrets and sensible defaults
4. Starts serving on the port provided by your host (Railway, Docker, etc.)

## License

This project combines [Open WebUI](https://github.com/open-webui/open-webui) (MIT) and [Open Terminal](https://github.com/open-webui/open-terminal) (MIT).
