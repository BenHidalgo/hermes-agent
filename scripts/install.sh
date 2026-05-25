#!/bin/bash
# 🧿 Nazar Agent — Full Installer
# Sets up the main agent at ~/.nazzar/ and creates 'nazar' command
set -e

NAZZAR_HOME="${NAZZAR_HOME:-$HOME/.nazzar}"
NAZAR_REPO="${NAZAR_REPO:-$HOME/Nazar/repo}"
BOLD='\033[1m'
NC='\033[0m'
BLUE='\033[0;34m'

echo ""
echo -e "${BOLD}🧿 Nazar Agent — Installer${NC}"
echo -e "${BLUE}==========================${NC}"
echo ""

# ── Prerequisites ──────────────────────────────────────────────────────
command -v python3 >/dev/null 2>&1 || { echo "Requires Python 3.11+"; exit 1; }

if ! command -v uv &> /dev/null; then
    echo "📦 Installing uv (Python package manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# ── Clone if needed ────────────────────────────────────────────────────
if [ ! -d "$NAZAR_REPO" ]; then
    echo "📥 Cloning Nazar Agent..."
    mkdir -p "$(dirname "$NAZAR_REPO")"
    git clone https://github.com/BenHidalgo/hermes-agent.git "$NAZAR_REPO"
fi

# ── Install the package ────────────────────────────────────────────────
echo "🔧 Installing Nazar Agent..."
cd "$NAZAR_REPO"
uv venv .venv --python 3.11 2>/dev/null || true
source .venv/bin/activate
uv pip install -e ".[all]" 2>/dev/null || uv pip install -e "."

# ── Create ~/.nazzar/ throne directory ─────────────────────────────────
echo "🏰 Building throne at ~/.nazzar/..."
mkdir -p "$NAZZAR_HOME"/{skills,scripts,sessions,cron/output,skins,logs}
mkdir -p "$NAZZAR_HOME"/gateway

# ── Auto-migrate from ~/.hermes/ if present ────────────────────────────
if [ -d "$HOME/.hermes" ] && [ ! -f "$NAZZAR_HOME/.migrated" ]; then
    echo "🔄 Detected existing ~/.hermes/ — migrating to ~/.nazzar/..."
    echo ""
    echo "  The following will be copied:"
    echo "  - config.yaml  (settings)"
    echo "  - .env         (API keys, redacted)"
    echo "  - SOUL.md      (identity)"
    echo "  - skills/      (your skills)"
    echo "  - scripts/     (your scripts)"
    echo "  - sessions/    (conversation history)"
    echo ""
    echo "  ~/.hermes/ will NOT be deleted. Both coexist."
    echo ""

    # Migrate config
    [ -f "$HOME/.hermes/config.yaml" ] && cp "$HOME/.hermes/config.yaml" "$NAZZAR_HOME/config.yaml"
    
    # Migrate .env (redact keys from output)
    if [ -f "$HOME/.hermes/.env" ]; then
        cp "$HOME/.hermes/.env" "$NAZZAR_HOME/.env"
        echo "  ✅ .env migrated (keys preserved)"
    fi
    
    # Migrate SOUL.md
    [ -f "$HOME/.hermes/SOUL.md" ] && cp "$HOME/.hermes/SOUL.md" "$NAZZAR_HOME/SOUL.md"
    
    # Migrate skills, scripts, sessions (non-destructive copy)
    [ -d "$HOME/.hermes/skills" ] && cp -rn "$HOME/.hermes/skills"/* "$NAZZAR_HOME/skills/" 2>/dev/null || true
    [ -d "$HOME/.hermes/scripts" ] && cp -rn "$HOME/.hermes/scripts"/* "$NAZZAR_HOME/scripts/" 2>/dev/null || true
    [ -d "$HOME/.hermes/sessions" ] && cp -rn "$HOME/.hermes/sessions"/* "$NAZZAR_HOME/sessions/" 2>/dev/null || true
    
    # Mark migrated so it doesn't re-copy
    touch "$NAZZAR_HOME/.migrated"
    echo "  ✅ Migration complete. ~/.hermes/ still intact as backup."
    echo ""
fi

# Default config
if [ ! -f "$NAZZAR_HOME/config.yaml" ]; then
    cp "$NAZAR_REPO/nazar_cli/default_config.yaml" "$NAZZAR_HOME/config.yaml" 2>/dev/null || true
fi

# SOUL.md — identity
if [ ! -f "$NAZZAR_HOME/SOUL.md" ]; then
    cp "$NAZAR_REPO/SOUL.md" "$NAZZAR_HOME/SOUL.md" 2>/dev/null || true
fi

# .env placeholder
if [ ! -f "$NAZZAR_HOME/.env" ]; then
    cat > "$NAZZAR_HOME/.env" << 'EOF'
# 🧿 Nazar Agent — API Keys
# Add your keys here, one per line: KEY_NAME=value
# DEEPSEEK_API_KEY=sk-...
# OPENROUTER_API_KEY=sk-...
# TELEGRAM_BOT_TOKEN=...
EOF
fi

# AGENTS.md — operational instructions
if [ ! -f "$NAZZAR_HOME/AGENTS.md" ]; then
    cat > "$NAZZAR_HOME/AGENTS.md" << 'EOF'
# 🧿 Nazar Agent — AGENTS.md
# Edit this file to shape how your agent operates day-to-day.
# Loaded every session as operational context.

## Behavior
- Proactive, not passive. Flag risks before they become problems.
- Keep responses tight. One screen, no scroll.
- Use tools aggressively — don't describe, execute.
- When context hits 85%, run recap and deliver fresh picture.

## Communication
- Direct. No fluff. No apologies.
- With your operator: warm, loyal.
- With others (when authorized): straight intellectual, professional.

## Stack
- Model: DeepSeek V4 Flash
- Storage: ~/.nazzar/
- Platforms: Telegram, WhatsApp, WeChat, QQ, Signal
EOF
fi

# MEMORY.md — durable knowledge
if [ ! -f "$NAZZAR_HOME/MEMORY.md" ]; then
    cat > "$NAZZAR_HOME/MEMORY.md" << 'EOF'
# 🧿 Nazar Agent — MEMORY.md
# The agent writes durable facts here for cross-session recall.
# Memories persist across sessions and are injected every conversation start.
# Do not edit manually unless you want to correct or prune memory.
EOF
fi

# USER.md — your profile
if [ ! -f "$NAZZAR_HOME/USER.md" ]; then
    cat > "$NAZZAR_HOME/USER.md" << 'EOF'
# 🧿 Nazar Agent — USER.md
# Your profile. The agent builds this over time.
# Edit freely — this is who you are to the agent.

## About You
- Name: 
- Role: 
- Timezone: 
- Languages: 

## Preferences
- Communication style: 
- Technical depth: 
- Response length: 

## Important Context
(Anything you want the agent to always know about you)
EOF
fi

# ── Create nazar command ──────────────────────────────────────────────
echo "🔗 Linking 'nazar' command..."
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/nazar" << 'SCRIPT'
#!/bin/bash
export NAZAR_HOME="${NAZZAR_HOME:-$HOME/.nazzar}"
export PATH="$HOME/.local/bin:$PATH"

NAZAR_REPO="${NAZAR_REPO:-$HOME/Nazar/repo}"
if [ -f "$NAZAR_REPO/.venv/bin/activate" ]; then
    source "$NAZAR_REPO/.venv/bin/activate"
fi

cd "$NAZAR_REPO" 2>/dev/null || cd "$(dirname "$0")/../Nazar/repo"
exec python3 -m nazar_cli.main "$@"
SCRIPT
chmod +x "$HOME/.local/bin/nazar"

# ── Workspace system ─────────────────────────────────────────────────
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/nazar-workspace" << 'SCRIPT'
#!/bin/bash
# 🧿 Nazar Workspace — create a rental workspace
# Usage: nazar-workspace create <name>
#        nazar-workspace list
#        nazar-workspace run <name>

NAZZAR_HOME="${NAZZAR_HOME:-$HOME/.nazzar}"
WORKSPACES_DIR="$NAZZAR_HOME/workspaces"

case "${1:-help}" in
    create)
        if [ -z "$2" ]; then echo "Usage: $0 create <name>"; exit 1; fi
        mkdir -p "$WORKSPACES_DIR/$2"
        cat > "$WORKSPACES_DIR/$2/SOUL.md" << EOF
# Workspace: $2
# Customize this SOUL.md for your workspace agent.
# The workspace inherits the main ~/.nazzar/ config and keys
# but gets its own identity, context files, and working directory.

You are a Nazar Agent deployed in the "$2" workspace.
EOF
        echo "✅ Workspace '$2' created at $WORKSPACES_DIR/$2/"
        echo "   Run: nazar-workspace run $2"
        ;;
    list)
        echo "=== Workspaces ==="
        ls -1 "$WORKSPACES_DIR" 2>/dev/null || echo "(none)"
        ;;
    run)
        if [ -z "$2" ]; then echo "Usage: $0 run <name>"; exit 1; fi
        if [ ! -d "$WORKSPACES_DIR/$2" ]; then
            echo "Workspace '$2' not found. Create it first: $0 create $2"
            exit 1
        fi
        cd "$WORKSPACES_DIR/$2"
        export NAZAR_HOME="$NAZZAR_HOME"
        exec nazar
        ;;
    *)
        echo "🧿 Nazar Workspace Manager"
        echo ""
        echo "Usage:"
        echo "  $0 create <name>   Create a new workspace"
        echo "  $0 list            List workspaces"
        echo "  $0 run <name>      Run agent in workspace"
        ;;
esac
SCRIPT
chmod +x "$HOME/.local/bin/nazar-workspace"

# ── Done ───────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}✅ Nazar Agent installed!${NC}"
echo ""
echo -e "${BLUE}Throne:${NC}     ~/.nazzar/"
echo -e "${BLUE}Command:${NC}    nazar"
echo -e "${BLUE}Workspace:${NC}  nazar-workspace create <name>"
echo ""
echo "Quick start:"
echo "  1. Set your API key:"
echo "     echo 'DEEPSEEK_API_KEY=sk-...' >> ~/.nazzar/.env"
echo "  2. Run: nazar"
echo "  3. Or create a workspace: nazar-workspace create my-project && nazar-workspace run my-project"
echo ""
echo -e "${BOLD}🧿 The Eye watches over you.${NC}"
