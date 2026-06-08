# Excerpt — gbrain canonical schema (T1 anchor)

Source: https://github.com/garrytan/gbrain/blob/master/docs/GBRAIN_RECOMMENDED_SCHEMA.md
Fetched: 2026-06-08T18:20Z via `gh api` on the gbrain master branch.
Status: T1 (direct quote from maintainer's repo).

Reproduce locally with:

```bash
gh api repos/garrytan/gbrain/contents/docs/GBRAIN_RECOMMENDED_SCHEMA.md --jq '.content' \
  | base64 -d > /tmp/gbrain-schema.md
```

---

## Quoted: the three founding principles

> ### 1. Every Piece of Knowledge Has a Primary Home (MECE Directories)
>
> Every piece of knowledge passes through a decision tree and lands in exactly one directory. No duplicated pages, no ambiguity about where something goes.
>
> This is the single most important structural decision. Without it, knowledge bases rot — the same fact lives in three places with three different versions, nobody knows which is current, and the agent (or human) stops trusting the system. MECE directories with explicit resolver rules prevent this.
>
> Every directory has a `README.md` (the resolver) that answers two questions:
> 1. **What goes here** — a positive definition with a concrete test
> 2. **What does NOT go here** — the key distinctions from neighboring directories that the agent might confuse
>
> The brain also has a top-level `RESOLVER.md` — a numbered decision tree the agent walks when filing anything.

> ### 2. Compiled Truth + Timeline (Two-Layer Pages)
>
> Every brain page has two layers, separated by a horizontal rule (`---`):
>
> **Above the line — Compiled Truth.** Always current, always rewritten when new information arrives. Starts with a one-paragraph executive summary. If you read only this, you know the state of play. Followed by structured State fields, Open Threads (active items — removed when resolved), and See Also (cross-links).
>
> **Below the line — Timeline.** Append-only, never rewritten. Reverse-chronological evidence log. Each entry: date, source, what happened. When an open thread gets resolved, it moves here with its resolution.

> ### 3. Enrichment Fires on Every Signal
>
> Every time any signal touches a person or company — meeting, email, tweet, calendar event, contact sync, conversation mention — the enrichment pipeline fires. The brain grows as a side effect of normal operations, not as a separate task you remember to do.

## Quoted: the four database primitives

> **Entity registry** — canonical ID, all aliases, all external IDs (LinkedIn member ID, X user ID, email addresses, phone numbers) in one table. This is the single source of truth for "is this the same person?"
>
> **Event ledger** — every signal that touches the brain is an immutable event: meeting attended, email received, tweet published, enrichment completed, user correction applied.
>
> **Fact store** — structured claims with provenance. "Jane Doe is CTO of Acme" with `source=crustdata, confidence=high, observed_at=2026-04-07`. When two sources disagree, the conflict is visible as two facts for the same field with different values.
>
> **Relationship graph** — typed edges between entities. Person→Company (role: CTO, started: 2024-01), Person→Person (relationship: co-founded company together), Company→Deal (type: Series A, date: 2025-03).

## Quoted: the chain of authority

> The chain of authority: **Agent config (AGENTS.md) says "read RESOLVER.md" → RESOLVER.md is the decision tree → each directory README.md is the local resolver → schema.md defines page structure → the enrich skill defines the enrichment protocol.**

## Our adaptation note (operator-added)

The upstream schema ships 16 directories (people/, companies/, deals/,
meetings/, projects/, ideas/, concepts/, writing/, programs/, org/, civic/,
media/, personal/, household/, hiring/, sources/, prompts/, inbox/, archive/)
tuned for a YC company brain.

For our personal-bot scope (single operator, infrastructure stack), we
adapted to 7 types: `concept / decision / infrastructure / project / prompt /
inbox / archive`. Our `resolver` page on the live host is the canonical
decision tree for our adaptation; this excerpt is the T1 anchor for the
upstream design principles the adaptation derives from.
