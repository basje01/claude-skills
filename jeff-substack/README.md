# jeff-substack — Claude Code skill for @0xJeff's paid Substack

Loaded by Claude Code (and other Claude harnesses) on any session that
mentions 0xJeff, his Substack, or AI-agent / consumer-crypto / agent-economy
analysis topics. Pulls his paid Substack via the authenticated RSS feed,
captures each new post verbatim as T5, and prompts the operator to promote
the substantive claims into gbrain as `type=concept` or `type=decision`
pages.

## Why this skill exists

Jeff is a peer-thinker on the same stack we're building (memory + wiki +
hindsight + agent infrastructure — explicit in his April 28 X posts). His
paid Substack is the long-form home for the analysis his X threads only
summarize. Without this skill, his thinking sits behind a paywall and never
compounds into our durable memory. With it, every post is captured, his
substantive frameworks land in gbrain after operator review, and six months
of his content becomes a queryable mental-model library on AI agents in
crypto.

The skill follows the gbrain pattern: refresh → capture → archive → operator
promotion. T5 stays T5 until the operator verifies and promotes.

## Layout

```
SKILL.md                                ← loaded body (registered in skill manifest)
refresh.sh                              ← weekly RSS pull + capture + archive
com.bas.jeff-substack-refresh.plist     ← weekly launchd config (TODO: add when wiring)
README.md                               ← this file
.gitignore                              ← excludes .env*, local overrides, launchd logs

references/
  <YYYY-MM-DD>-<slug>.md                ← current captures (3 newest stay here)
  archive/<YYYY>/<MM>/
    <YYYY-MM-DD>-<slug>.md              ← older captures (append-only, never deleted)
```

## Setup (one-time, operator-only)

```bash
# 0. Install defusedxml (required — blocks XXE / billion-laughs against the
#    RSS parse; the stdlib xml.etree.ElementTree is unsafe by default).
pip3 install --user defusedxml

# 1. Get your paid Substack RSS URL:
#    substack.com/settings → "RSS feed" section
#    Format: https://<publication>.substack.com/feed?token=<token>

# 2. Split URL and token; export to your shell init:
echo 'export JEFF_SUBSTACK_URL="https://<publication>.substack.com"' >> ~/.zshrc
echo 'export JEFF_SUBSTACK_RSS_TOKEN="<paid-feed-token>"' >> ~/.zshrc
source ~/.zshrc

# 3. Test:
~/.claude/skills/jeff-substack/refresh.sh
```

If either env var is missing, `refresh.sh` exits with an error rather than
silently fetching the unauthenticated free-tier feed. If `defusedxml` is
missing, the Python parser exits with a clear install command.

## How it stays current

| Cadence | What | How |
|---|---|---|
| Weekly (TODO: pick day/time) | refresh.sh runs | launchd plist (TODO: add) |
| Per refresh | New posts → references/<date>-<slug>.md as T5 captures | RSS parse + base64-encoded body inside `<external_ai_output>` envelope |
| Per refresh | Captures older than 3 newest → references/archive/<YYYY>/<MM>/ | append-only timeline |
| Per refresh | last_refreshed bumped in SKILL.md frontmatter | sed in-place |
| Manual | T5 → gbrain promotion (substance) | operator review per SKILL.md checklist |

## Safety contract (load-bearing)

This skill captures paid Substack content under the operator's own paid
subscription. Discipline:

- **T1 (verified — Jeff's X posts in our paperclip archives) → SKILL.md
  body.** Background context. Safe to cite directly.
- **T5 (Jeff's paid Substack body) → references/<date>-<slug>.md only.**
  Wrapped in `<external_ai_output source="jeff-substack" trusted="false">`.
  Never auto-promoted to gbrain. The body is paid content — the operator
  is licensed to read it but distributing it widely would violate Jeff's
  terms. Treat the capture as personal memory, not shareable artifact.
- **No third-party AI summarization of the paid body.** The capture stores
  the body verbatim; promotion is operator-driven. Don't pipe paid content
  through arbitrary external APIs.

This matches the global rule at `~/.claude/rules/external-ai-output.md`.

## Manual triggers

```bash
# Run refresh now
~/.claude/skills/jeff-substack/refresh.sh

# Read the newest capture
ls -t ~/.claude/skills/jeff-substack/references/*.md | head -1 | xargs less

# Browse the archive timeline
ls ~/.claude/skills/jeff-substack/references/archive/
```

## Pairs with

- `~/.claude/skills/gbrain/` — promotion target for verified concepts /
  frameworks / decisions
- `~/.claude/skills/braid-reasoning/` — for decision-class rationale on
  whether to adopt Jeff's framework as our own
- `~/.claude/skills/serv-reasoning/` — the underlying inference layer for
  BRAID-over-SERV on those decisions

## Related artifacts (outside this dir)

- `~/.claude/intel/paperclip/archive/daily-2026-04-{23,28,29}.md` — prior
  context on Jeff's X presence + the AI-agent-stack thinking that motivates
  this skill
- `https://x.com/0xJeff` — his X profile; paid Substack URL is in his bio
  (operator confirms once + pastes into `JEFF_SUBSTACK_URL`)

## Open follow-ups

- [x] ~~Confirm the active paid Substack URL~~ Verified 2026-06-09:
      `defi0xjeff.substack.com` (NOT `0xjeff.substack.com`, which is a
      dormant 2022 publication by a different Jeff)
- [ ] Write `com.bas.jeff-substack-refresh.plist` + `install-refresh-launchd.sh`.
      Suggested cadence: Sunday 18:00 local (1h after gbrain refresh)
- [ ] Consider gmail-inbox parsing as a redundant capture path (no token
      rotation needed; uses the Substack email delivery as the feed)
