FROM ghcr.io/open-webui/open-webui:main

# Install open-terminal (Python package) into the same environment
RUN pip install --no-cache-dir open-terminal

# Create workspace for open-terminal
RUN mkdir -p /home/terminal-user && chmod 777 /home/terminal-user

# Entrypoint that runs both services
COPY <<'ENTRYPOINT' /app/start-all.sh
#!/bin/bash
set -e

# --- Open Terminal (background, fixed port 8000) ---
OPEN_TERMINAL_API_KEY="${OPEN_TERMINAL_API_KEY:-terminal-secret}" \
  open-terminal run --host 0.0.0.0 --port 8000 --cwd /home/terminal-user &

# --- Configure Open WebUI env vars ---
# Railway provides PORT; Open WebUI listens on it
export PORT="${PORT:-8080}"
export HOST="0.0.0.0"

# NVIDIA NIM as the default OpenAI-compatible provider
export OPENAI_API_BASE_URL="${OPENAI_API_BASE_URL:-https://integrate.api.nvidia.com/v1}"
export OPENAI_API_KEY="${OPENAI_API_KEY:-${NVIDIA_NIM_API_KEY:-}}"

# Disable Ollama (not used)
export ENABLE_OLLAMA_API="${ENABLE_OLLAMA_API:-false}"

# Default model (pre-selected for new users)
export DEFAULT_MODELS="${DEFAULT_MODELS:-qwen/qwen3.5-122b-a10b}"

# Pre-configure Open Terminal connection (internal, no user setup needed)
export TERMINAL_SERVER_CONNECTIONS='[{"id":"open-terminal","name":"Open Terminal","url":"http://localhost:8000","key":"'"${OPEN_TERMINAL_API_KEY:-terminal-secret}"'","auth_type":"bearer","enabled":true}]'

# Generate secret key if not provided
if [ -z "$WEBUI_SECRET_KEY" ]; then
  export WEBUI_SECRET_KEY=$(head -c 12 /dev/random | base64)
fi

# --- Start Open WebUI (foreground) ---
exec bash /app/backend/start.sh
ENTRYPOINT
RUN chmod +x /app/start-all.sh

CMD ["bash", "/app/start-all.sh"]
