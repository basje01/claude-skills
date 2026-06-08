# claude-skills

A continuously-updated collection of [Claude Code](https://claude.com/claude-code)
skills authored by the operator. Each skill is a self-contained subfolder loaded
by Claude Code (or any Claude harness honoring the same convention) when its
trigger conditions match — so future sessions don't have to re-derive operational
patterns from upstream docs every time.

## Why a monorepo

Single source of truth, one git history for skill evolution, one CI/lint
surface, and a coherent place to land cross-cutting refactors (e.g., when the
external-AI-output safety rules tighten, every skill's T5 handling can be
updated in one PR).

Each skill is isolated in its own subfolder. The Claude Code loader treats
`~/.claude/skills/<name>/SKILL.md` as the entry point; this repo populates
those entries via symlinks (see [Local install](#local-install) below). The
loader follows symlinks — verified against the pre-existing
`team_members/braid-reasoning` symlink pattern.

## Layout

```
claude-skills/
├── README.md                     ← this file
├── gbrain/                       ← Garry Tan's personal-knowledge MCP memory layer
│   ├── SKILL.md                  ← auto-loaded body
│   ├── refresh.sh                ← weekly grok-p refresh ritual
│   ├── com.bas.gbrain-skill-refresh.plist
│   ├── install-refresh-launchd.sh
│   ├── references/
│   │   ├── upstream-schema-excerpt.md
│   │   ├── refresh-procedure.md
│   │   ├── t5-grok-intel-<UTC>.md       ← current capture
│   │   └── archive/<YYYY>/<MM>/         ← append-only history of captures
│   ├── README.md                  ← skill-specific docs
│   └── .gitignore                 ← launchd noise (.log files)
└── <future-skill>/                ← same pattern for any new skill
```

## Local install

After cloning this repo (`git clone git@github.com:basje01/claude-skills.git`
into `~/Code/claude-skills/` to match the convention with the operator's other
repos), register each skill with the Claude Code loader by symlinking:

```bash
ln -s ~/Code/claude-skills/gbrain ~/.claude/skills/gbrain
```

The loader picks up the new entry on next session start.

## Per-skill conventions

Each skill subfolder is expected to have:

- **`SKILL.md`** — the loaded body. YAML frontmatter must include `name`,
  `description`, and `metadata.triggers`. Body is markdown.
- **`README.md`** — skill-specific documentation: layout, cadence,
  safety contract.
- **`references/`** — longer-form supporting docs the `SKILL.md` can point
  at (T1 anchors, playbooks, captures).
- **`.gitignore`** — exclude transient artifacts (logs, runtime caches).

Anything skill-specific (refresh scripts, plists, installers) lives inside
the skill's own subfolder, not at the repo root.

## Safety model for skills that capture external AI output

Skills that surface T5 content (e.g., a refresh ritual that pulls intel from
grok-p, openai, gemini, etc.) MUST:

1. Capture verbatim text into a dated file under the skill's `references/`,
   wrapped in an `<external_ai_output source="<tool>" trusted="false">`
   envelope.
2. Diff against the prior capture for operator review.
3. **Archive prior captures**, never delete them — append-only timeline.
4. **Never auto-promote T5 claims into the SKILL.md body.** Promotion
   requires the operator to verify the cited source independently (URL,
   commit sha, official docs).
5. Auto-promote ONLY T1 facts (verified — repo HEAD, host config files,
   official docs).

This matches the global rule at `~/.claude/rules/external-ai-output.md`.
The `gbrain/refresh.sh` here is the reference implementation; new skills
adopting an external-AI capture pattern should mirror its structure.

## Cadence

Each skill is responsible for its own refresh cadence. The `gbrain` skill
uses a weekly launchd timer (Sunday 17:00 local), paired with a host-side
`systemd` timer that upgrades the gbrain service itself overnight (Sunday
03:17 UTC) so the host advances first, the skill captures the resulting
state in the evening. Skills with no remote content drift (pure reference
skills) need no refresh.

## Related operator repos

- [`bas-personal-bot`](https://github.com/basje01/bas-personal-bot) — Hermes
  gateway + hardening + ops runbooks (the consumers of the gbrain skill)
- [`hyperliquid-prediction`](https://github.com/basje01/hyperliquid-prediction) —
  the trading bot whose memory layer is gbrain

## Adding a new skill

```bash
cd ~/Code/claude-skills
mkdir -p <new-skill>/references
# Write <new-skill>/SKILL.md with frontmatter (name, description, triggers)
# Write <new-skill>/README.md with layout + cadence + safety contract
# Add any refresh/install scripts inside <new-skill>/
git add <new-skill>
git commit -m "feat(<new-skill>): initial commit"
git push
ln -s ~/Code/claude-skills/<new-skill> ~/.claude/skills/<new-skill>
```

That's the entire registration. The Claude Code loader picks it up on the
next session start.
