# Changelog

All notable changes to this persona pack are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — 2026-05-11

Initial release. Extracted from the
`config/agents.d/marketing.multiclient.example.yaml` template
that ships inside `lordmacu/nexo-rs` as the multi-client
multi-LLM marketing pattern reference. Cuts it to a standalone
pack installable via
`nexo persona install lordmacu/nexo-persona-marketing-multiclient-template`.

### Added

- `persona.toml` v2 manifest (id=`marketing-multi`, requires
  `marketing` plugin placeholder, contributes single-file
  agents.d + per-agent workspace seeds).
- `agents.d/marketing-multi.yaml` — three agents
  (acme_intake / bravo_retention / charlie_exec), each pinned
  to a different LLM (MiniMax M2.5 / Claude Haiku 4.5 /
  DeepSeek v4 flash) + own proactive cadence + own
  daily_turn_budget.
- Three workspace seed dirs with README placeholders for
  brand-voice / escalation-criteria / canned templates.
- `install.sh` — legacy v1 installer (airgapped / CI).
- `.github/workflows/release.yml` — generic v2 release
  publisher (reads persona id from persona.toml).
