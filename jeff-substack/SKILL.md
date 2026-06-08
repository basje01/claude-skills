---
name: jeff-substack
description: >
  Weekly digest skill that pulls @0xJeff's paid Substack (crypto AI-agent
  researcher/investor — known on X for substantive analysis of AI agents in
  crypto, consumer AI, memory/wiki/hindsight stacks, fake-stars/VC-signal
  posture, and infra commentary including Hermes/Claude integration). Mirrors
  the gbrain refresh ritual: pulls new posts via the paid RSS feed token,
  captures verbatim into references/<date>-<slug>.md inside an
  <external_ai_output> envelope (T5 — analyst commentary, lead not fact),
  diffs vs prior, archives older captures append-only. The operator then
  promotes any novel concept that's worth keeping into gbrain as
  type=concept (mental model / framework / heuristic) or type=decision
  (if we adopt one of his frameworks). The substack URL + paid RSS feed
  token live in env vars (JEFF_SUBSTACK_URL, JEFF_SUBSTACK_RSS_TOKEN) the
  operator pastes once — no secret commits. Use when: pulling/reading
  Jeff's posts, deciding which concept from his Substack to promote into
  gbrain, asking "what does Jeff say about X?", or extending his analytical
  framework onto our own watch-list.
metadata:
  triggers: >-
    0xjeff, 0xJeff, jeff substack, jeff's substack, crypto AI agents,
    AI agent investor, jeff x post, jeff newsletter, JEFF_SUBSTACK_URL,
    JEFF_SUBSTACK_RSS_TOKEN, what does jeff say, jeff's framework,
    fake github stars VC signal, AI memory wiki hindsight stack,
    consumer crypto AI, agent economy thesis
  category: research
  schema_version: '1'
  version: 0.2.0
  last_refreshed: 2026-06-08
  pairs_with: [gbrain, braid-reasoning, serv-reasoning]
  substack_url: https://defi0xjeff.substack.com
  feed_url: https://defi0xjeff.substack.com/feed
  feed_auth: none-required
  feed_verified: 2026-06-09T22:00Z full-body-no-truncation
---

# jeff-substack — @0xJeff's paid Substack as a knowledge feed

> **One-line:** Pull Jeff's paid Substack posts weekly, capture verbatim as
> T5, diff vs prior, archive older captures append-only. Operator promotes
> verified concepts into gbrain by hand. Same discipline as the gbrain skill.

## Who is 0xJeff (and why this skill exists)

[@0xJeff](https://x.com/0xJeff) is a crypto researcher/investor focused on
the AI-agent stack — both the infrastructure (memory layers, wiki layers,
Hindsight/recall systems) and the market (which agent projects matter,
which narratives are forming, where VC signal is broken). His paid Substack
([defi0xjeff.substack.com](https://defi0xjeff.substack.com)) is the
long-form home for the analysis his X threads only summarize.

His Substack bio: *"I write Web3 AI content daily -> Filtered Thoughts on
X and Unfiltered 'Here'"*. 4.2K+ subscribers, #12 Rising in Crypto on
Substack's leaderboard. He posts ~weekly+ — recent titles confirm he writes
DIRECTLY about our stack:

- "Hermes as a Onchain Analyst" (May 25 2026)
- "All Roads Lead to Decentralized AI" (May 27 2026)
- "6 Workflows, 6 Lessons, 60 Days" (Jun 1 2026)
- "Why AI Needs to be Open and Decentralized" (Jun 3 2026)
- "The After Hour EP.58 — Blood on the Street" (Jun 7 2026)

Our paperclip intel archives caught him discussing:

- **Built-in memory + wiki + Hindsight (info synthesis) stacks** — Apr 28
  2026, exactly our gbrain/Hermes pattern
- **Systemdlink Claude (Windows) ↔ Hermes (WSL2) over local port** — Apr 28,
  he's running similar infra to ours
- **Fake GitHub stars as broken VC signal** — Apr 28, "fork-to-star ratio
  below 0.05 on 10k+ star repo = gamed"

He's not a shill. He's a peer-thinker on the same stack we're building. His
paid Substack is a high-signal feed into our system; the skill is the
bridge that gets the signal into gbrain without violating T5 discipline.

## Setup

**Zero-config — just run the script.** No tokens, no env vars, no auth.

```bash
~/.claude/skills/jeff-substack/refresh.sh
```

### Why no token is needed

Substack publications expose a public RSS feed at
`<publication>.substack.com/feed` that delivers the **full body** for every
post — paid posts included — unless the author has explicitly enabled feed
truncation. Verified 2026-06-09: `defi0xjeff.substack.com/feed` returns
the full body for paid posts ("The After Hour EP.58", "Why AI Needs to be
Open and Decentralized", "6 Workflows, 6 Lessons, 60 Days", etc.).

Substack's per-account paid-feed-with-token mechanism was deprecated; the
per-publication feed is the canonical delivery path.

### Defensive watch — if Jeff ever turns on truncation

`refresh.sh` checks each item's body for teaser markers
(`"subscribe to read"`, `"paid subscribers only"`, `"continue reading"`)
combined with a length under 2000 chars. If detected, the script captures
the teaser anyway and logs a WARN so the operator knows to investigate.
If this fires across a full refresh, the skill needs to pivot to one of:

1. Email-based capture (Substack still sends the full body via email to
   paid subscribers — Substack→Proton→Gmail forwarding rule + Gmail MCP)
2. Playwright-MCP-driven capture of the post URL using the operator's
   logged-in browser session
3. Manual paste workflow — operator pastes the body when refresh.sh
   produces a stub for a teaser-only capture

Until truncation actually fires, the public feed is the simplest, most
robust path.

> **DON'T commit either value.** `.gitignore` in this skill dir excludes
> `.env*` and `references/*.local.md` so a stray paste can't leak into git.
> If the token DOES leak: Substack lets you regenerate it under the same
> Settings → RSS section.

The launchd plist passes the env vars through; the refresh script reads
them. If either is missing, `refresh.sh` exits with a clear error rather
than fetching the free-tier-only feed (which would silently produce empty
captures).

## How the refresh works

```
refresh.sh runs (manually or weekly via launchd)
  ↓
fetch paid RSS feed → parse new posts since last_refreshed
  ↓
for each new post:
  - write references/<date>-<slug>.md wrapped in <external_ai_output> envelope
  - quote-extract the substantive theses + frameworks + claims
  - leave a "promote to gbrain?" checklist below the envelope
  ↓
diff vs prior capture; print delta
  ↓
archive older captures into references/archive/<YYYY>/<MM>/ (append-only)
  ↓
update metadata.last_refreshed in SKILL.md frontmatter (T1 — just a date)
```

## T5 → gbrain promotion (operator action)

For each capture, walk through:

1. **Is the claim a fact, a framework, or a forecast?**
   - **Fact** ("Project X did Y in Q") → verify against a primary source
     (on-chain tx, official announcement, etc.). If verified, file in gbrain
     as `type=concept` with the source URL as evidence.
   - **Framework** ("AI agents need memory + wiki + hindsight to be useful")
     → if we adopt the framing, file in gbrain as `type=concept` with the
     Jeff URL as the seed and ANY independent confirmations as evidence.
   - **Forecast** ("Agent X will hit $Y mcap by Z") → does NOT go in gbrain.
     If we care, log to inbox or to a separate prediction-tracking page.

2. **Does the claim conflict with what gbrain already knows?**
   - Run `gbrain:query query="<topic>"` BEFORE filing. If a related
     `type=concept` page exists, UPDATE it (add a Timeline entry with the
     Jeff URL + the new framing) rather than fragment.

3. **Lowercase kebab-case slug.** Verified gotcha — uppercase breaks
   addTag. (`gbrain/SKILL.md` documents this.)

4. **Two-layer page.** Compiled Truth above `---`, Timeline below. Every
   Timeline entry cites the Substack post URL + date.

5. **Discarded claims stay in the archive.** Append-only timeline applies
   here too — don't delete a capture just because we decided not to promote.

## Pairing patterns

### Pair with gbrain for concept-class learning

The promotion target IS gbrain. This skill is the upstream feeder; gbrain
is the durable artifact. Without gbrain, this skill would just be a
read-and-forget loop. With gbrain, Jeff's frameworks compound — six months
of his posts becomes six months of refined mental models on the AI-agent
stack, queryable in any session.

### Pair with braid-reasoning for adopting Jeff's frameworks

When Jeff proposes a framework we're considering adopting (e.g. "agents
need built-in memory + wiki + hindsight"), the question "should we adopt
this?" is decision-class. Run it through BRAID before committing — BRAID
externalizes the rationale (pro/con/edge-case/skeptic) so the gbrain
`type=decision` page that lands has a defensible audit trail, not just
"Jeff said so."

### Pair with serv-reasoning for BRAID-over-SERV on those decisions

When we DO run a BRAID over a Jeff-derived decision, run the underlying LLM
calls through SERV (per the `serv-reasoning` skill — SERV is from the same
lab as BRAID, OpenServ Labs). `serv-pro` tier for the reasoning loop;
`serv-mini` for the extract pass.

## Anti-patterns (Jeff-specific)

- **Quoting a forecast as a fact.** Jeff makes calls. Some land, some
  don't. A landed forecast doesn't retroactively become T1 — it stays T5
  with a "verified-outcome" annotation. Future calls don't inherit
  past-call accuracy as authority.
- **Promoting a thesis after one post.** Frameworks earn the right to a
  gbrain concept page after at least 2 independent posts (Jeff or someone
  else) confirm the framing, OR after our own bench/data confirms.
- **Auto-acting on his project picks.** Decision-support only — same rule
  as `article-investment-memo`. No buys based on this skill alone.
- **Letting the capture file balloon.** Quote-extract; don't paste entire
  3000-word posts into the envelope. The envelope holds the **substantive
  claims** — the user can click through to Jeff's Substack for the prose.
- **Bypassing the paid-RSS env var.** If we ever scrape the public preview
  instead of the paid feed, we're capturing the marketing summary, not the
  argument. The skill is worthless on free-tier content.

## Open questions to track

- [x] ~~What's the actual paid Substack URL?~~ Verified 2026-06-09:
      `defi0xjeff.substack.com` (NOT `0xjeff.substack.com` — that's a
      dormant 2022 publication by a different Jeff). The skill's
      `JEFF_SUBSTACK_URL` env var is set to the verified value.
- [ ] **How often does Jeff post?** Recent cadence looks weekly-ish (4
      posts May 25 – Jun 7), so the weekly launchd plist is a good fit.
      Re-evaluate after 4 captures: if posts are landing twice per
      `refresh.sh` run, switch cadence to twice-weekly.
- [ ] **Wire the launchd plist** (`com.bas.jeff-substack-refresh.plist`)
      and the installer, modeled on `gbrain/install-refresh-launchd.sh`.
      Suggested: Sunday 18:00 local (gbrain runs at 17:00, so Jeff
      captures 1h after — minimal contention, same window in operator's
      mind).
- [ ] **Does the digest land in gmail too?** If yes, we have a redundant
      capture path that doesn't depend on the RSS token (parse from inbox).
      Worth probing if the RSS-token rotation ever bites us.
- [ ] **Cross-source confirmation pattern.** When Jeff proposes a thesis,
      does grok-p X-search of @0xJeff + the same topic surface independent
      voices? If so, document the confirmation query in this skill.

## Sources

- **T1 (verified):** our paperclip intel archives capturing his X posts
  (`~/.claude/intel/paperclip/archive/daily-2026-04-{23,28,29}.md`).
- **T1 (operator-configured):** the paid Substack RSS URL +
  token, exported as `JEFF_SUBSTACK_URL` + `JEFF_SUBSTACK_RSS_TOKEN`.
- **T5 (untrusted):** every Substack post body is T5 — analyst commentary,
  lead not fact. Treat per `~/.claude/rules/external-ai-output.md`.

## Pairs with

- `~/.claude/skills/gbrain/` — where promoted concepts land
- `~/.claude/skills/braid-reasoning/` — for decision-class rationale on
  whether to adopt Jeff's framework
- `~/.claude/skills/serv-reasoning/` — the underlying inference layer for
  BRAID-over-SERV on those decisions
