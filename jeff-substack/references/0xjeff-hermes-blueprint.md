---
title: 0xJeff Hermes Blueprint
type: synthesis
source: jeff-substack
source_trust: T5-derived (synthesized from analyst commentary, NOT vendor docs)
synthesized_at: 2026-06-09
posts_covered: 8
date_range: 2026-04-20 → 2026-06-01
methodology: chronological reading of the @0xJeff Hermes series + cross-pattern extraction
pairs_with: [gbrain, braid-reasoning, serv-reasoning]
status: candidate-for-gbrain-promotion
---

# 0xJeff Hermes Blueprint

> A structured synthesis of @0xJeff's 60-day Hermes-as-analyst journey
> (2026-04-20 → 2026-06-01), extracted from his Substack series. The
> source posts are T5 (analyst commentary, not vendor docs) but the
> patterns repeat across 8 posts which makes the framework itself
> high-signal. Operator should validate each claim against our own
> Hermes operations before adopting wholesale.

## TL;DR — the one-line takeaways

1. **"Building an agent is 90% architecture, 10% AI."** Model intelligence is commodity; tool/skill design, memory persistence, feedback loops, and unit economics are the differentiators.

2. **Hermes is the OPERATOR, Claude/Codex is the BUILDER.** Don't ask Hermes to build dashboards; ask it to run them. Don't ask Claude to be your second brain across sessions; ask Hermes.

3. **The 3-layer stack**: Identity (Soul.md) → Knowledge (User.md + Memory.md) → Tools/Skills/Config. **Layer 1 has the highest ROI by a mile** — most users skip it and wonder why their agent feels generic.

4. **Skill bundling is mandatory** at scale. SKILL.md + references/ + scripts/ → load ~500 tokens, save 5000+ per session.

5. **Pick one inference provider and stick** — provider swaps cost 2-3 debugging sessions each. Open-weight labs (DeepSeek v4, Kimi k2.6) match frontier intelligence at lower cost. Going direct beats multi-hop for latency.

6. **x402 pay-per-use is a real unlock** — instead of $100+ subscriptions, seed $5-10 USDC and access hundreds of premium tools at cents per run. Best fit: Nansen, Exa, Firecrawl, BlockRun via @agentcash aggregator.

## The Big Idea — 90/10

> *"Building an agent is 90% architecture, 10% AI. Everyone has access to the same models (most of which are highly intelligent). What separates useful agent to useless agent is tool/skill design, memory persistence, feedback/learning loop, and the unit economics that make it sustainable to run."* — @0xJeff, "6 Workflows, 6 Lessons, 60 Days" (Jun 1)

This is the central thesis. If we're sweating model choice (Opus vs Sonnet, GPT vs Nous Kimi) more than we're sweating Soul.md and skill bundles, we're optimizing the wrong axis.

## The 3-Layer Stack

| Layer | What | ROI | Time investment | Files |
|---|---|---|---|---|
| **1. Identity** | Who the agent IS — personality, voice, values, constraints | **Highest** (by a mile) | 2-3 hours initial, revise 5+ times | `Soul.md` |
| **2. Knowledge** | What it knows about YOU — portfolio, theses, past mistakes, preferred sign-offs | High (compounds daily) | 30min first draft, daily updates | `User.md`, `Memory.md` |
| **3. Tools** | What it can DO — skills, MCP servers, browser, API access | Medium (mandatory floor) | Ongoing, prune regularly | `config.yaml`, skills dir |

> *"Without [the Soul layer], I'm a generic chatbot with tools. With it, I'm Jeff's second brain that writes in his voice and knows what he'd care about before he finishes typing."*

**Common failure mode:** Install Hermes → plug in API key → add tools → wonder why it's unimpressive. Skip Layer 1, get a generic agent.

**Practical Soul.md contents** (Jeff's pattern):
- How I write (voice constraints: "no sounding smart like LLM", "casual narrator voice", "contrarian first")
- Investment theses
- Portfolio positions
- Operating constraints
- Who I am

**Practical User.md contents:**
- Portfolio + positions
- Active theses
- Preferred sign-offs / formats
- Past mistakes (so the agent doesn't repeat your blunders)

**Memory.md is intentionally small** — Hermes auto-trims stale entries. Explicitly say "remember this" on important facts.

## Role Discovery — Operator, not Builder

> *"Hermes is not a builder, he's an operator. Hermes strength is persistent memory + self-learning loop — it remembers things across sessions, automatically sets up skills if it thinks it's necessary, & can reduce time for the task next time (you can't find this in Codex or Claude Code)."* — Apr 27 post

This was the inflection point in Jeff's series. Early posts (Apr 20) describe trying to use Hermes to build dashboards — slow, bad aesthetics. After the Apr 27 reframe:

- **Hermes** → recurring tasks, persistent memory, cross-session learning. Morning briefs, X tracking, onchain forensics, alerts.
- **Claude / Codex / Cursor** → one-shot building. Dashboards, UI, code.

Don't fight the tool's strength.

## The 60-day Provider Journey

Provider swaps cost 2-3 debugging sessions each. Here's where Jeff landed after 5-6 swaps:

| Provider | Role | Cost | Notes |
|---|---|---|---|
| **DeepSeek v4 Flash** | base model (fast, cheap) | direct API discount 75% in May | preferred after optimization |
| **DeepSeek v4 Pro** | complex tasks | direct API | preferred for synthesis |
| **Opencode Go** | discovery month | $5/mo first month, >$50 of inference | good for Kimi k2.6, GLM5.1, MiniMax 2.5-2.7 access |
| **Grok subscription** | x_search tool only | $10/mo (3-month-cancel trick) | xai-oauth config, NOT xai |
| **Venice AI** | privacy / TEE inference | DIEM credits ($1/day free) | zero data retention |
| **OpenRouter** | tried, swapped away | — | adds 5-10s latency vs direct |

**Anti-patterns called out:**
- Multi-hop (Opencode Go → Kimi via OpenRouter) adds latency, eat into the cost savings.
- Hooking Hindsight to OpenRouter + Kimi k2.6 burned $20-30/day on Reflect (timeouts at 240s) — switch to **Recall** for time-sensitive jobs, **Reflect** for batched syntheses.

**Grok 4.3 explicitly called bad at**: browser harness, reasoning/summarizing/connecting dots, multi-turn agent tool calling. x_search defaults to Grok 4.3 automatically; use DeepSeek v4 as the base model and only invoke x_search for the X-specific search step.

## The 6-Stage Research Pipelines

### Pattern 1 — Real-time research (May 18 post)

```
1. x_search             (targeted X search; timeout 240-300s in config.yaml)
2. Cookie MCP           (KOL leaderboards, sentiment trends)
3. Browser CDP          (manual Grok prompt for high-quality synthesis)
4. DeepSeek v4          (synthesis of 1-3)
5. Hindsight Recall     (cross-reference with past insights)
6. (output)             (delivered to Discord / morning brief)
```

**Prompt template Jeff uses:**
> *"Deep dive on geopolitics, macro, and their impact on stock market and crypto — focus on current state of things and forward looking things that could happen and what to watch out for in the next 2 weeks"*

### Pattern 2 — Onchain forensics (May 25 post)

```
1. Pool discovery       | DexScreener (free)                   $0
2. Wallet forensics     | Nansen TGM via @agentcash x402       $0.03-0.07
3. RPC cross-check      | Base RPC (drpc.org)                  $0
4. Token Unlocks        | Tokenomist API                       $0
5. Social sentiment     | Cookie MCP (3 queries)               $0
6. Synthesis            | cross-reference matrix → verdict     —
```

**Cost reality**: 15-20 runs of this pipeline = $1.50 total. Same coverage via individual Nansen subscriptions = $100+/mo.

**Dump-risk classification** (output dimension): investor dump, smart money, bot accumulation, institutional interest. Backed by wallet age (4 RPC calls per wallet, free binary search), CEX deposit detection (Coinbase Base Bridge label scan), and upcoming Tokenomist unlock cross-reference.

**Health check**: runs every 3 days on portfolio.

### Pattern 3 — X bookmark daily digest

```
1. X API v2             → fetch bookmarks
2. dedupe by URL        (30-day rolling window)
3. → Discord            (titles, handles, links listing)
4. for article-detail:  Hermes summarizes
5. fallback for blocked: Browser Harness extracts → summarize
```

**Cost reality**: before x_search, $0.5/day X API. After (x_search handles content, X API only for bookmark fetch): $0.1/day. Saves $0.4/day = $146/year.

## Skill Bundling Pattern (mandatory at scale)

**Anti-pattern**: one giant 2000+ word prompt per workflow. Bloats context; re-derives from scratch every session.

**Pattern**: treat each skill as a directory:

```
<skill-name>/
├── SKILL.md           (~100 lines — pipeline logic, when to fire)
├── references/        (API specs, endpoint shapes, field quirks, query templates)
│   ├── nansen-agentcash.md
│   ├── base-rpc-endpoints.md
│   └── cookie-mcp-queries.md
└── scripts/           (executable tools)
    └── check_wallets.sh
```

**Math**: ~500 tokens to load skill vs 5000+ tokens to re-explain context per session. Over 60+ days × hundreds of sessions, the savings compound massively.

> Note: our own `gbrain` and `jeff-substack` skills already follow this pattern. Worth auditing whether the others in `~/.claude/skills/` are bundled or just one-pager SKILL.md.

## Tool Inventory (Jeff's stack)

| Tool | Use | Cost | Notes |
|---|---|---|---|
| **Hindsight** | external memory (Recall + Reflect) | — | non-negotiable per his series; Recall for time-sensitive, Reflect for batched |
| **Browser Harness / Browser CDP** | web access | — | Browser CDP beats Playwright on Cloudflare-protected sites |
| **x_search** (via xai-oauth) | X search | included with Grok sub | timeout 240-300s in config |
| **Cookie MCP** (by @cookiedotfun) | KOL / sentiment | — | structured leaderboards |
| **Nansen TGM + Balances** | onchain forensics | $0.03-0.07 per call via @agentcash x402 | core, BlockRun as fallback |
| **DexScreener** | pool discovery | free | |
| **Base RPC** (drpc.org) | RPC cross-check | free | |
| **Tokenomist** | token unlocks | free | API access from team, x402 coming |
| **Exa, Firecrawl** | structured web search / JS-heavy sites | — | better than manual browser for these |
| **X API v2** | bookmark fetch | $0.1/day after x_search migration | |
| **@askVenice** | private inference (TEE) | DIEM, $1/day credit | for privacy-sensitive prompts |
| **@dphnAI POD** | upcoming platform credits | — | "investing + getting free inference" |

## Feedback Loop Discipline (the learning mechanism)

> *"Feedback loop follows 6 steps:*
> *1. Hermes produces something*
> *2. I read it immediately and flag what's wrong*
> *3. I give a specific correction/next steps*
> *4. Hermes encodes the correction as a permanent rule*
> *5. Next output becomes tighter*
> *6. Repeat the loop*
> *This helps me clean up the outputs to the format that's easy for me to digest."*

**Key word**: PERMANENT rule. The encoding happens in Soul.md / User.md / a skill's SKILL.md — not as a one-off "remember this." If the correction doesn't land in a persistent layer, you'll re-discover it next session.

**Echo-chamber failure mode Jeff calls out**: sources gravitate to existing holdings + big-cap names (NVIDIA, TSMC, MU, VRT, SIVE). Fix is explicit: tell the agent to *exclude* what it's already biased toward, or rotate sources.

## Gold Quotes (verbatim) — for citing in conversation

1. **On architecture** (Jun 1) — *"Building an agent is 90% architecture, 10% AI."*
2. **On role distinction** (Apr 27) — *"Hermes is not a builder, he's an operator."*
3. **On Soul layer** (May 11) — *"Without it, I'm a generic chatbot with tools. With it, I'm Jeff's second brain that writes in his voice and knows what he'd care about before he finishes typing."*
4. **On tool steering** (Jun 1) — *"Most of your job as a user is to point the agent to the right tool(s) for the right job. Course correct Hermes to prevent him from using the wrong tool."*
5. **On x402** (Jun 1) — *"Before x402, I found myself spending a lot of time trying to find the right tool for the right job... After x402, I can just set up an agentic wallet with 1 install command. Seed it with $5-10 in USDC and start exploring hundreds of premium tools."*
6. **On provider choice** (Jun 1) — *"The best way to go is to pick 1 provider and stick with them. Going direct tend to net you with better discount/connectivity."*
7. **On skill bundling** (Jun 1) — *"A well-bundled skill costs ~500 tokens to load... but saves 5000+ tokens of re-explaining context in every session. Over 60+ days and hundreds of sessions, the cost saving & the efficiency compounds."*
8. **On token economy** (Apr 20) — *"It's balancing what I get (which is productivity boost + more learning) to what I pay for (which is inference cost + time/headaches fixing bugs)."*

## gbrain Promotion Candidates

For each, the operator can decide whether to promote into `gbrain` as a `type=concept` page. Recommended priority order:

| Candidate slug (lowercase-kebab) | Type | Why promote | Source posts |
|---|---|---|---|
| `agent-90-10-architecture-vs-ai` | concept | The central thesis; affects every other agent we build | Jun 1 |
| `hermes-operator-not-builder` | concept | The role-split discipline; we should respect it in our own ops | Apr 27, Jun 1 |
| `agent-3-layer-stack-soul-knowledge-tools` | concept | The Identity/Knowledge/Tools framework; applicable to gbrain + Hermes wiring | May 11 |
| `hermes-skill-bundling-pattern` | concept | Validates our existing skill structure; encode as a hard rule for new skills | May 25, Jun 1 |
| `agent-feedback-loop-6-steps` | concept | The "permanent rule" encoding discipline; fits gbrain's append-only timeline | Jun 1 |
| `onchain-forensics-6-stage-pipeline` | concept | Specific pipeline shape we could reuse for our own watch-list | May 25 |
| `inference-provider-stickiness-rule` | decision | Adopt-or-reject: pick ONE inference provider; needs BRAID-over-SERV rationale | Jun 1 |
| `x402-pay-per-use-tools-thesis` | concept | The cost-architecture lesson; pairs with our own MCP-server setup | May 25, Jun 1 |

**Promotion procedure**: per `~/.claude/skills/gbrain/SKILL.md`, read the resolver first, file as `type=concept`, two-layer page format, lowercase kebab slug, T5 citation in the Timeline pointing back to this blueprint + the specific Substack post URL.

## Known gaps in this blueprint

- **May 4 post** ("Hermes as the Ultimate Analyst — I've found the gist") is partially extracted (referenced in cross-cutting patterns but no dedicated section). The extraction subagent ran out of context mid-stream. Action: read `references/archive/2026/05/2026-05-04-hermes-as-the-ultimate-analyst-i-ve-found-the-gist-for-my-ul.md` separately and append.
- **Apr 20 post detail** is partial — only quote #8 cites it directly. Full extraction pending.
- This blueprint is a SYNTHESIS, not a substitute for reading the captures. Specific claims, costs, prompts should be re-validated against the source post before being treated as canonical.

## Source captures

All eight posts live under `~/.claude/skills/jeff-substack/references/` (current or archive/2026/<MM>/). Use `find` for the canonical paths; they move as new captures land.

| Date | Slug |
|---|---|
| 2026-04-20 | hermes-200-and-30-skills-later-here |
| 2026-04-27 | 1-month-with-hermes-i-ve-been-using |
| 2026-05-04 | hermes-as-the-ultimate-analyst-ive |
| 2026-05-11 | hermes-analyst-workflow-essentials |
| 2026-05-11 | the-analyst-agent-tools |
| 2026-05-18 | hermes-as-a-real-time-analyst |
| 2026-05-25 | hermes-as-a-onchain-analyst |
| 2026-06-01 | 6-workflows-6-lessons-60-days |
