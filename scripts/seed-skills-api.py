#!/usr/bin/env python3
"""Seeds Apocalypse Radio skill into Open WebUI via API. Called by seed-skills.sh."""

import json
import sys
import urllib.request
import urllib.error

WEBUI_URL = sys.argv[1]
ADMIN_EMAIL = sys.argv[2]
ADMIN_PASSWORD = sys.argv[3]

SKILL_ID = "apocalypse_radio"
SKILL_NAME = "Apocalypse Radio"
SKILL_DESC = (
    "Teaches AI how to register on Apocalypse Radio and create collaborative music "
    "using Lyria, GraphQL mutations, and the songs-for-the-apocalypse starter repo."
)
SKILL_FILE = "/app/skills/apocalypse-radio.md"


def log(msg):
    print(f"[seed-skills] {msg}", flush=True)


def api(path, data=None, token=None):
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(f"{WEBUI_URL}{path}", data=body, headers=headers)
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        body = e.read().decode()
        log(f"HTTP {e.code} from {path}: {body}")
        return None


# --- Sign in ---
log(f"Signing in as {ADMIN_EMAIL}...")
auth = api("/api/v1/auths/signin", {"email": ADMIN_EMAIL, "password": ADMIN_PASSWORD})
if not auth or not auth.get("token"):
    log("WARNING: Could not sign in. Admin account may not exist yet. Skipping.")
    sys.exit(0)

token = auth["token"]
log("Authenticated successfully.")

# --- Check if skill already exists ---
tools = api("/api/v1/tools/", token=token)
if tools and any(t.get("id") == SKILL_ID for t in tools):
    log(f"Skill '{SKILL_NAME}' already exists. Skipping.")
    sys.exit(0)

# --- Read skill markdown ---
with open(SKILL_FILE) as f:
    guide_content = f.read()

# Escape triple quotes for embedding in Python source
safe_content = guide_content.replace("\\", "\\\\").replace('"""', '\\"\\"\\"')

# --- Build tool Python code ---
tool_code = f'''"""
title: {SKILL_NAME}
description: {SKILL_DESC}
"""


class Tools:
    def __init__(self):
        pass

    async def get_apocalypse_radio_guide(self) -> str:
        """
        Get the complete Apocalypse Radio music creation guide. Call this when the user asks about
        Apocalypse Radio, making music, creating collabs, generating tracks, or registering as an
        AI musician.
        """
        return """{safe_content}"""
'''

# --- Create the tool ---
log(f"Creating skill '{SKILL_NAME}'...")
result = api(
    "/api/v1/tools/create",
    {
        "id": SKILL_ID,
        "name": SKILL_NAME,
        "meta": {"description": SKILL_DESC},
        "content": tool_code,
    },
    token=token,
)

if result:
    log(f"Skill '{SKILL_NAME}' created successfully.")
else:
    log("WARNING: Failed to create skill.")
