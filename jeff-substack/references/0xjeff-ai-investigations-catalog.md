---
title: 0xJeff AI Field Investigations — Catalog
type: catalog
source: jeff-substack
source_trust: T5 (index of analyst content, not promotion)
cataloged_at: 2026-06-09
posts_indexed: 131 total (38 substantive AI investigations + 55 weekly market recaps + Hermes series elsewhere)
pairs_with: [gbrain, jeff-substack/SKILL.md, 0xjeff-hermes-blueprint.md]
status: index — backfill on demand via ./backfill.sh
---

# 0xJeff AI Field Investigations — Catalog

A categorized index of every Substack post @0xJeff has published that
qualifies as substantive AI/agent/crypto-AI investigation. The Hermes
operational series (8 posts) is captured separately in
`0xjeff-hermes-blueprint.md`; this catalog covers the **broader
analytical work**.

Posts are **not all backfilled to disk** — only the 20 most recent live
in `references/` (current + archive). To pull a specific historical
post, run:

```bash
~/.claude/skills/jeff-substack/backfill.sh --filter "<regex>" --dry-run
~/.claude/skills/jeff-substack/backfill.sh --filter "<regex>"
```

Regex patterns to copy-paste:
- `inference` — the AI inference market series (5 posts)
- `decentralized|deai` — the decentralized AI thesis arc (5 posts + 4 DeAI state-of)
- `bittensor` — the Bittensor coverage (4 posts)
- `agent|ecosystem` — agent meta / ecosystem leaders (8 posts)
- `state-of|trends|landscape` — landscape pieces (5 posts)

## 🎯 Highest-leverage reads for OUR work

These directly overlap projects we already have on disk. **Backfill first.**

| Date | Slug | Why we care |
|---|---|---|
| 2026-04-09 | inference-is-the-new-oil-the-economics | Frames the SERV/OpenServ economics; pairs with our `serv-reasoning` skill |
| 2026-04-24 | the-compute-the-intelligence-and | The inference-stack thesis; same anchor as SERV work |
| 2026-05-15 | onchain-ai-inference-landscape | Maps providers including OpenServ; cross-check with our SERV tier ladder |
| 2026-05-21 | the-inference-api-market-the-tam | TAM + landscape + opportunity; investment-grade synthesis |
| 2025-09-04 | state-of-predictionai-q32025 | **DIRECT** to our hyperliquid-prediction bot — Q3'25 landscape |
| 2025-08-14 | state-of-defai-q32025 | Broader DeFAI Q3 — context for our trading agents |
| 2025-06-06 | state-of-defai-q22025 | Earlier Q2 snapshot — evolution baseline |

Backfill all of the above with one command:

```bash
~/.claude/skills/jeff-substack/backfill.sh \
  --filter "inference-is-the-new-oil|the-compute-the-intelligence|onchain-ai-inference-landscape|the-inference-api-market-the-tam|state-of-predictionai|state-of-defai"
```

## Inference market arc (5 posts — chronological)

The clearest single thesis arc Jeff has on a topic that overlaps our work.

| Date | Slug | Title |
|---|---|---|
| 2026-04-09 | inference-is-the-new-oil-the-economics | Inference Is the New Oil — The Economics of AI |
| 2026-04-24 | the-compute-the-intelligence-and | The Compute, the Intelligence, and the Inference |
| 2026-05-15 | onchain-ai-inference-landscape | Onchain AI Inference Landscape |
| 2026-05-17 | the-after-hour-ep55-another-week | The After Hour EP.55 — Another Week Another Inference |
| 2026-05-21 | the-inference-api-market-the-tam | The Inference API Market: The TAM, The Landscape, The Opportunity |

**Pair with**: `~/.claude/skills/serv-reasoning/SKILL.md` for our own SERV
tier ladder. Jeff's landscape pieces should be cross-referenced when
deciding whether a new inference provider is worth integrating.

## Decentralized AI arc (5 posts — chronological)

Jeff's evolving DeAI thesis spans 9 months — strongest case for compounding
over time.

| Date | Slug | Title |
|---|---|---|
| 2025-09-24 | a-case-for-decentralized-ai | A Case for Decentralized AI |
| 2025-11-18 | close-ai-to-open-ai-to-decentralized | Close AI to Open AI to Decentralized AI |
| 2025-12-03 | the-decentralized-ai-economies-of | The Decentralized AI Economies of Scale |
| 2026-05-27 | all-roads-lead-to-decentralized-ai | All Roads Lead to Decentralized AI |
| 2026-06-03 | why-ai-needs-to-be-open-and-decentralized | Why AI Needs to be Open and Decentralized |
| 2025-11-26 | how-deai-compete-with-centralized | How DeAI Compete with Centralized AI |

**Promotion candidate**: if the arc resolves into a coherent thesis we
share, file as gbrain `type=concept` (slug: `decentralized-ai-thesis-evolution`)
with a Timeline citing all 6 posts as evidence stages.

## Bittensor / subnet / agent ecosystem (8 posts)

Bittensor as a topic recurs heavily. Useful if we ever evaluate TAO-related
investments or build for the subnet ecosystem.

| Date | Slug | Title |
|---|---|---|
| 2025-04-17 | into-the-bittensor-ecosystem | Into the Bittensor Ecosystem |
| 2025-06-03 | flock-the-new-bittensor-for-ai-applications | Flock — The New Bittensor for AI Applications |
| 2025-06-24 | bid-the-bid-the-rise-of-bittensor | Bid the BID — The Rise of Bittensor Agent |
| 2025-10-15 | beginners-guide-to-bittensor-tao | Beginner's Guide to Bittensor (TAO) |
| 2026-03-19 | survive-and-thrive-in-bittensor-ecosystem | Survive and Thrive in Bittensor Ecosystem — 2026 Handbook |
| 2026-03-25 | bittensor-subnets-vs-virtuals-agents | Bittensor Subnets vs Virtuals Agents |
| 2026-03-15 | the-after-hour-ep46-bittensor-is | The After Hour EP.46 — Bittensor is Back |

## Crypto AI ecosystem / landscape pieces (8 posts)

State-of-the-market and trend synthesis pieces. Best read in chronological
order to track Jeff's evolving framework.

| Date | Slug | Title |
|---|---|---|
| 2025-04-20 | the-next-crypto-ai-meta | The Next Crypto AI Meta |
| 2025-04-24 | unfiltered-random-web3-ai-thoughts | Unfiltered Random Web3 AI Thoughts |
| 2025-04-29 | the-ai-agent-recovery | The AI Agent Recovery |
| 2025-05-03 | ai-trends-in-the-trenches | AI Trends in the Trenches |
| 2025-05-08 | ai-agents-ecosystem-leaders | AI Agents: Ecosystem Leaders |
| 2025-05-20 | the-ai-guide-to-capturing-mindshare | The "AI" Guide to Capturing Mindshare (for Projects) |
| 2025-08-08 | i-play-around-with-20-web3-ai-products | I play around with 20+ Web3 AI products, here's what I found |
| 2025-09-12 | ai-trends-in-the-trenches-2 | AI Trends in the Trenches 2 |
| 2025-10-22 | darwinian-ai-the-ai-hunger-games | Darwinian AI — The AI Hunger Games |
| 2025-10-29 | whats-the-point-of-crypto-ai-agents | What's the point of Crypto AI Agents? |
| 2025-12-10 | evolution-of-crypto-x-ai-in-2025 | Evolution of Crypto x AI in 2025 and where things are heading |

## State-of reports / quarterly snapshots (4 posts)

Quarterly state-of reports are highest analytical density. Useful baselines.

| Date | Slug | Title |
|---|---|---|
| 2025-06-06 | state-of-defai-q22025 | State of DeFAI Q2/2025 |
| 2025-08-14 | state-of-defai-q32025 | State of DeFAI Q3/2025 |
| 2025-09-04 | state-of-predictionai-q32025 | State of PredictionAI Q3/2025 |
| 2025-11-06 | beginners-guide-to-crypto-ai-landscape | Beginner's Guide to Crypto AI Landscape |
| 2026-01-07 | ai-by-the-numbers-token-performance | AI by the Numbers — Token Performance Review Across AI Narratives |

## StableAI / niche AI (1 post)

| Date | Slug | Title |
|---|---|---|
| 2025-06-11 | stableai-where-stablecoin-and-ai | StableAI — Where Stablecoin and AI converges |
| 2025-07-08 | deai-at-scale | DeAI at Scale |

## Investing philosophy (1 post)

| Date | Slug | Title |
|---|---|---|
| 2026-05-13 | my-reality-of-investing-in-crypto | My Reality of Investing in Crypto |
| 2026-02-19 | the-market-is-dead-but-dragonfly | The Market is Dead, but Dragonfly Just Raised $650M. Why? |

## Onchain AI (specific) (2 posts)

| Date | Slug | Title |
|---|---|---|
| 2026-05-07 | the-onchain-re-rating-is-here | The Onchain Re-rating is Here |
| 2026-05-24 | the-after-hour-ep56-onchain-ai-moat | The After Hour EP.56 — Onchain AI Moat is Here |

## After Hour weekly recaps (55 posts) — lower-density market chatter

Jeff's weekly market-recap series goes back to **EP.1 (2025-05-10)** and
runs through **EP.58 (2026-06-07)** — that's a year+ of weekly crypto
commentary. Lower analytical density than the standalone pieces above.

**Backfill on demand only** if you need a specific week's framing.
Example: backfill the EP for the week of a major event.

The 12 most-recent (Apr 2026 → Jun 2026) are likely the highest signal
for current decisions; older eps are useful as historical context.

```bash
# Backfill all After Hour posts (cost: ~55 fetches, take a few minutes)
~/.claude/skills/jeff-substack/backfill.sh --filter "after-hour"

# Backfill just the last quarter
~/.claude/skills/jeff-substack/backfill.sh --filter "after-hour-ep5[2-8]"
```

## Methodology + caveats

- The categorization is heuristic (slug + title keyword match). A few posts
  may fit multiple categories; they appear in the primary one.
- After-Hour weekly recaps are flagged as lower-density but they DO contain
  substantive single-topic deep dives sometimes (EP.55 "Another Week Another
  Inference" is in our inference arc, EP.56 is onchain-AI). Don't dismiss
  them wholesale.
- The categorization is from June 2026 archive enumeration. New posts land
  ~weekly+; rerun `backfill.sh` periodically (the regular `refresh.sh`
  catches anything in the RSS top-20, backfill handles deeper history).
- Source trust per `~/.claude/rules/external-ai-output.md`: **T5 (analyst
  commentary)**. Backfilling captures verbatim text; promotion to gbrain
  requires the operator-driven T5 → T1 verification (find an independent
  T1/T2 anchor for any claim before filing as concept/decision).

## Recommended next moves

1. **Backfill the high-leverage 7 first** (inference arc + state-of-DeFAI/PredictionAI):
   ```bash
   ~/.claude/skills/jeff-substack/backfill.sh \
     --filter "inference-is-the-new-oil|the-compute-the-intelligence|onchain-ai-inference-landscape|the-inference-api-market-the-tam|state-of-predictionai|state-of-defai"
   ```
2. **Read `state-of-predictionai-q32025`** before the next hyperliquid-prediction
   strategic review — it's literally a state-of-the-art write-up of the
   thing we're building.
3. **Read the 5-post inference market arc chronologically** before our
   next SERV review — pairs with `serv-reasoning` skill.
4. **Decentralized AI arc** is good background reading but not urgent
   unless we're considering a DeAI integration.
5. **Bittensor coverage** — defer unless we evaluate TAO.

## Source captures

All backfilled posts land in `references/archive/<YYYY>/<MM>/<date>-<slug>.md`.
The blueprint document at `references/0xjeff-hermes-blueprint.md` covers
the Hermes operational series (8 posts) separately.
