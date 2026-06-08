# serv-reasoning — Claude Code skill for OpenServ Inference (SERV)

Loaded by Claude Code (and other Claude harnesses) on any session that
mentions SERV / OpenServ / a SERV tier name. Encodes what's verified from
our own production backend (`serv_backend.py`) so future sessions don't
re-derive the tier ladder, strict-mode caveats, or BRAID pairing pattern
from scratch.

## Why this skill exists

We were missing the operational knowledge that:

1. The whole `inference-api.openserv.ai/v1/chat/completions` surface is
   branded "SERV Reasoning API" — there is no separate `/reasoning` route.
2. "Reasoning" in SERV today means **tier + prompt**, not an API parameter:
   - `serv-pro` / `serv-standard` are the higher-think-time tiers (~120s wall)
   - We get the chain-of-thought back by including a `"reasoning"` field in
     the strict JSON schema and instructing the model to populate it
3. The +N-point reasoning-lift claims circulating publicly are most
   plausibly BRAID-applied (same lab — OpenServ Labs, arXiv:2512.15959) and
   should be reproduced on our hardware before promotion from T5 to T1.

The skill prevents the next operator (or future-me after a context wipe)
from misreading marketing claims as features, hand-rolling an HTTP client
when `serv_backend.py` exists, or guessing wrong about which tier to pick.

## Layout

```
SKILL.md       ← loaded body (registered in skill manifest)
README.md      ← this file
references/    ← T1 anchors + worked benchmark notes (added as captured)
```

No `refresh.sh` — this is a reference skill, not a periodic capture. The
source of truth is `icm-analytics-website/shared/llm/serv_backend.py`; when
that file changes meaningfully, the operator bumps this skill by hand.

## How it stays current

Hand-curated. The operator is expected to bump `SKILL.md` when:

- A new tier ID appears in `.serv_pricing.local.json`
- A new failure-classification kind appears in `serv_backend.py`
- The "+N-point reasoning lift" tweet is verified or refuted on our bench
- A `/v1/models` enumeration becomes available with auth

There's no scheduled refresh job. Drift between `SKILL.md` and the live
backend should be caught by anyone touching either side; if drift persists,
add a `lint_skill_coverage` style check that diffs the tier table against
the pricing JSON.

## Manual triggers

```bash
# Print the skill body
cat ~/.claude/skills/serv-reasoning/SKILL.md

# Inspect the tier sheet that this skill mirrors
cat ~/Code/icm-analytics-website/.serv_pricing.local.json | jq 'keys'

# Run a smoke test through serv_backend.py
cd ~/Code/icm-analytics-website
python -m shared.llm.serv_backend  # if a __main__ exists; otherwise import in REPL
```

## Safety contract

This skill makes claims about an upstream API surface we don't fully own.
Discipline:

- **T1 (verified — our code) goes in `SKILL.md` body.** Tier IDs, failure
  taxonomy, strict-mode hardening rules: all anchored to `serv_backend.py`.
- **T5 (untrusted — vendor tweets / community claims) goes in
  `references/` only**, with the source URL captured. Never auto-promoted.
- The "Open questions to track" section in `SKILL.md` is the queue of T5
  claims awaiting verification.

This matches the global rule at `~/.claude/rules/external-ai-output.md`.

## Related artifacts (outside this dir)

- `~/Code/icm-analytics-website/shared/llm/serv_backend.py` — the
  canonical SERV client
- `~/Code/icm-analytics-website/.serv_pricing.local.json` — tier pricing
  (gitignored; lives only on the operator's Mac)
- `~/.claude/skills/braid-reasoning/` — the reasoning-wrap pattern that
  pairs with any SERV tier
- `~/.claude/skills/gbrain/` — where BRAID-over-SERV decision rationales
  land as `type=decision` pages
