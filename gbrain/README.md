# gbrain — Claude Code skill for Garry Tan's personal-knowledge MCP

Loaded by Claude Code (and other Claude harnesses) on any session that
mentions gbrain. Encodes the Garry-aligned usage discipline so future
sessions don't have to re-derive it from the upstream docs every time.

## Layout

```
SKILL.md                                ← loaded body (registered in skill manifest)
refresh.sh                              ← single-broad-query refresh; auto-archives prior
com.bas.gbrain-skill-refresh.plist      ← weekly launchd config
install-refresh-launchd.sh              ← idempotent installer for the plist
README.md                               ← this file

references/
  upstream-schema-excerpt.md            ← T1 anchor from gbrain repo (Garry's design)
  refresh-procedure.md                  ← operator playbook for T5→T1 promotion safety
  t5-grok-intel-<UTC>.md                ← current capture (refresh.sh keeps newest here)
  archive/<YYYY>/<MM>/
    t5-grok-intel-<UTC>.md              ← prior captures (append-only, never deleted)

.refresh-stdout.log                     ← launchd stdout (gitignored)
.refresh-stderr.log                     ← launchd stderr (gitignored)
```

## How it stays current

| Cadence | What | How |
|---|---|---|
| Sun 17:00 local (Mac) | refresh.sh runs | launchd: `com.bas.gbrain-skill-refresh.plist` |
| Sun 03:17 UTC (hermes-hz) | gbrain server itself upgrades | systemd: `gbrain-update.timer` in bas-personal-bot/deploy/ |
| Per refresh | T1 auto-promotion of `installed_version` | refresh.sh SSHes hermes-hz, reads package.json, syncs frontmatter |
| Per refresh | Prior capture moved to `archive/<YYYY>/<MM>/` | append-only timeline (Garry's schema rule) |
| Per refresh | T5 claims captured to `references/t5-grok-intel-<UTC>.md` | grok-p single broad query with `[version]` `[setup]` `[recommendation]` `[general]` tags |
| Manual | T5 → SKILL.md promotion (substance edits) | operator review per `references/refresh-procedure.md` |

## Safety contract (load-bearing)

- **T1 (verified) ↔ SKILL.md body**: ok to auto-promote facts from
  `github.com/garrytan/gbrain` master, host package.json, repo CHANGELOG.
- **T5 (untrusted) ↔ references/t5-*.md**: never enters SKILL.md until
  operator verifies the cited tweet URL exists + content matches. The
  rule is encoded in `references/refresh-procedure.md` + the global
  rule at `~/.claude/rules/external-ai-output.md`.

## Manual triggers

```bash
# Run refresh now
~/.claude/skills/gbrain/refresh.sh

# Same, via launchd (uses the scheduled env)
launchctl kickstart "gui/$(id -u)/com.bas.gbrain-skill-refresh"

# Install the weekly launchd job (idempotent)
~/.claude/skills/gbrain/install-refresh-launchd.sh

# Uninstall the launchd job
launchctl bootout "gui/$(id -u)/com.bas.gbrain-skill-refresh"
rm ~/Library/LaunchAgents/com.bas.gbrain-skill-refresh.plist
```

## Related artifacts (outside this dir)

- gbrain ops + auth + tool scope:
  `~/Code/bas-personal-bot/docs/gbrain-memory.md`
- system architecture (gbrain as the memory layer):
  `~/Code/bas-personal-bot/docs/architecture.md`
- Hermes hard rules (read RESOLVER before put_page):
  `~/Code/bas-personal-bot/config/SOUL.md`
- auto-update timer on hermes-hz:
  `~/Code/bas-personal-bot/deploy/gbrain-update.{sh,service,timer}`
- upstream:
  https://github.com/garrytan/gbrain/blob/master/docs/GBRAIN_RECOMMENDED_SCHEMA.md
