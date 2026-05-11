# nexo-persona-marketing-multiclient-template

> **Multi-client marketing automation** template for [nexo-rs](https://github.com/lordmacu/nexo-rs).
> Three agents, three LLMs, one daemon.

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![nexo-rs](https://img.shields.io/badge/nexo--rs-%E2%89%A50.1.6-orange.svg)](https://github.com/lordmacu/nexo-rs)

A starting point for marketing teams running automation across
multiple clients on the same nexo-rs daemon. Demonstrates the
multi-tenant single-install pattern:

| Agent | LLM | Role | Cadence |
|-------|-----|------|---------|
| `marketing_acme_intake` | MiniMax M2.5 | Inbound classifier (intake) | 5 min ticks, 120 turns/day |
| `marketing_bravo_retention` | Claude Haiku 4.5 | Churn-risk signals + follow-ups | 10 min ticks, 80 turns/day |
| `marketing_charlie_exec` | DeepSeek v4 flash | Executive thread summary | 15 min ticks, 50 turns/day |

Each agent:
- Pinned to its own marketing plugin instance (own inbox).
- Different LLM tuned for its role's cost / latency / quality
  sweet spot.
- Own proactive loop reviewing the inbox between user
  messages.
- Own workspace + transcripts dir for clean tenant isolation.

## Install

### Step 0 — Install nexo-rs

Pick a channel from the
[installation guide](https://lordmacu.github.io/nexo-rs/getting-started/installation.html):

```bash
cargo install --git https://github.com/lordmacu/nexo-rs nexo-rs
# OR pre-built binary: https://github.com/lordmacu/nexo-rs/releases
# OR Docker:           docker pull ghcr.io/lordmacu/nexo-rs:latest

nexo --version   # ≥ 0.1.6
```

### Step 1 — Install the pack (canonical)

```bash
nexo persona install lordmacu/nexo-persona-marketing-multiclient-template
nexo persona list           # marketing-multi  0.1.0  ...
```

### Step 1' — install.sh (legacy v1 / airgapped)

```bash
git clone https://github.com/lordmacu/nexo-persona-marketing-multiclient-template
cd nexo-persona-marketing-multiclient-template
./install.sh
```

## Customize

This is a template. The shipped agents are named `acme` /
`bravo` / `charlie`; replace with your real client names + role
specifics before going live.

### 1. Rename agent ids per client

Edit `~/.nexo/agents.d/marketing-multi.yaml`:

```yaml
agents:
  - id: marketing_acme_intake     # ← change to marketing_<your-client>_intake
    ...
```

Each id ties an agent to its plugin instance + workspace dir,
so renaming requires updating three call sites in the YAML
(id / inbound_bindings[].instance / workspace path) and the
matching plugin config.

### 2. System prompts

Each agent's `system_prompt` block ships a one-line
placeholder. Replace with real classification criteria,
escalation rules, and brand voice:

```yaml
system_prompt: |
  You are the ACME marketing intake agent.
  Classify inbound emails/messages, detect urgency, and prepare
  concise next actions for the human team.
```

### 3. Plugin instances

The pack uses a placeholder `marketing` plugin name. Pick the
real channel plugin (`whatsapp` / `telegram` / `email`) and
configure matching instances in your daemon's plugin config:

```yaml
# ~/.nexo/plugins/email.yaml (example)
email:
  - instance: acme_inbox
    imap:
      host: imap.acme.com
      ...
  - instance: bravo_retention
    imap:
      host: imap.bravo.com
      ...
```

Then update each agent's `plugins:` and
`inbound_bindings[].plugin:` to match.

### 4. Tighten `allowed_tools`

The shipped pack leaves `allowed_tools: []` (every registered
tool visible). Once you know which tools each agent needs,
narrow the list — the runtime prunes everything outside it
from the LLM's view, so a jailbroken prompt cannot reach
random tools.

### 5. Tune rate limits

`sender_rate_limit.rps` / `burst` and `daily_turn_budget`
default to conservative values. Bump per client SLA.

## Boot

```bash
nexo daemon
```

Each agent starts its proactive loop independently; the
daemon's broker layer routes inbound channel messages by
plugin instance.

## Repo layout

```
nexo-persona-marketing-multiclient-template/
├── persona.toml             # v2 manifest
├── install.sh               # legacy v1 installer
├── .github/workflows/
│   └── release.yml          # tag-driven release publisher
├── agents.d/
│   └── marketing-multi.yaml # the 3-agent definition
└── data/
    └── workspace/
        ├── marketing_acme_intake/
        ├── marketing_bravo_retention/
        └── marketing_charlie_exec/
```

## Upgrade

```bash
nexo persona upgrade marketing-multi
```

## Uninstall

```bash
nexo persona remove marketing-multi --yes
```

## License

MIT — see [LICENSE](LICENSE).

## Related

- [lordmacu/nexo-rs](https://github.com/lordmacu/nexo-rs) — the agent framework
- [Installing personas (full guide)](https://lordmacu.github.io/nexo-rs/personas/install.html)
- [lordmacu/nexo-persona-cody](https://github.com/lordmacu/nexo-persona-cody) — programmer pair persona
- [lordmacu/nexo-persona-ana-template](https://github.com/lordmacu/nexo-persona-ana-template) — sales / lead-capture template
