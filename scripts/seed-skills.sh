#!/bin/bash
# seed-skills.sh — Waits for Open WebUI to start, then seeds skills via API.
# Runs in the background from start-all.sh. Idempotent.

set -euo pipefail

WEBUI_URL="http://localhost:${PORT:-8080}"
ADMIN_EMAIL="${WEBUI_ADMIN_EMAIL:-admin@localhost}"
ADMIN_PASSWORD="${WEBUI_ADMIN_PASSWORD:-changeme}"

log() { echo "[seed-skills] $*"; }

# --- Wait for Open WebUI to be ready ---
log "Waiting for Open WebUI to become healthy..."
for i in $(seq 1 60); do
  if curl -sf "${WEBUI_URL}/api/config" > /dev/null 2>&1; then
    log "Open WebUI is ready (attempt $i)."
    break
  fi
  if [ "$i" -eq 60 ]; then
    log "ERROR: Open WebUI did not become ready after 60 attempts. Giving up."
    exit 1
  fi
  sleep 2
done

# --- Use Python for all API interactions (avoids shell quoting nightmares) ---
python3 /app/scripts/seed-skills-api.py "${WEBUI_URL}" "${ADMIN_EMAIL}" "${ADMIN_PASSWORD}"
