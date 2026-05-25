# 🧿 Nazar Empire

**The watcher. The executor. Your agent.**

A stripped, focused fork of Hermes Agent — rebuilt around the Nazar identity. Terminal-native, zero bloat, ready to run.

```
pip install -e .
nazar
```

## What's Different

- **Slimmed** — 20+ platforms stripped, 26 model providers cut, tests/docs/CI/website gone. 392 Python files, not thousands.
- **Nazar Identity** — SOUL.md is the default persona. You are the watcher from session one.
- **Efficient** — System prompt saves ~16K tokens per session (no skill listing dump, no AGENTS.md injection).
- **Focused Channels** — Telegram, WhatsApp, WeChat, QQ, Signal. That's it.
- **Private-first** — Bring your own API keys. No forced subscriptions, no external service dependencies.

## Quick Start

```bash
# Install
git clone https://github.com/BenHidalgo/nazar-agent
cd nazar-agent
uv pip install -e .

# Set your API key
export DEEPSEEK_API_KEY="sk-..."
# or run the config wizard
nazar setup

# Start chatting
nazar
```

## Configuration

All config lives in `~/.nazar/`:

```
~/.nazar/
├── config.yaml     # Agent configuration
├── .env            # API keys
├── SOUL.md         # Your agent's identity
├── skills/         # Procedural knowledge
├── scripts/        # Custom automation scripts
└── sessions/       # Conversation history
```

## Gateway (Multi-Platform)

```bash
# Set up Telegram, WhatsApp, etc.
nazar gateway setup
nazar gateway start
```

## Philosophy

Nazar is not a framework. It's a **ready-to-run agent** that you own completely. The code is open. The config is yours. The API keys are yours. No telemetry, no subscriptions, no vendor lock-in.

**The Eye watches over you.**

Built from [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) (MIT).
