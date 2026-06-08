---
name: serv-reasoning
description: >
  SERV Reasoning API (OpenServ Inference at inference-api.openserv.ai) — the
  OpenAI-compatible chat-completions endpoint we already use for structured
  extraction across the icm-analytics-website pipeline. This skill encodes
  what's verified from our own production backend (T1): the 6 tier IDs
  (serv-nano / serv-swift / serv-mini / serv-standard / serv-pro / serv-ultra),
  which tiers are reasoning-bias (serv-pro / serv-standard have a ~120s
  server-side timeout characteristic of reasoning models), how we get
  reasoning today (a "reasoning" field in the strict JSON schema — prompt
  engineering, not an API parameter), the strict-mode schema-hardening rules
  (no validation keywords on primitives, additionalProperties=false
  required), and the BRAID pairing pattern (BRAID is from the same lab —
  OpenServ Labs, arXiv:2512.15959 — so wrapping a SERV call in BRAID's
  bounded-reasoning trace is the documented way to get reasoning lift on
  decision-class prompts). Use when: choosing a SERV tier, designing a
  reasoning-bias prompt, integrating SERV into a new pipeline, deciding
  whether to wrap a call in BRAID, or evaluating a claim about SERV
  reasoning capabilities you haven't verified.
metadata:
  triggers: >-
    SERV, SERV API, SERV reasoning, serv-nano, serv-mini, serv-pro, serv-ultra,
    serv-standard, serv-swift, OpenServ, OpenServ Inference, openserv.ai,
    inference-api.openserv.ai, /v1/chat/completions reasoning, serv_backend.py,
    SERV_FAST_TIER, SERV_LONG_FORM_TIER, SERV_MODEL_TIER, LLM_BACKEND=serv,
    SERV_ENABLED_MODULES, BRAID over SERV, reasoning layer, reasoning tier,
    Nemotron 3 Ultra, DeFi benchmark, +11.17, response_format json_schema,
    SERV strict mode, serv_schema_400, serv_timeout
  category: ops
  schema_version: '1'
  version: 0.1.0
  last_refreshed: 2026-06-08
  upstream_endpoint: https://inference-api.openserv.ai/v1/chat/completions
  pairs_with: [braid-reasoning, gbrain]
---

# serv-reasoning — OpenServ Inference / SERV Reasoning API

> **One-line:** SERV is an OpenAI-compatible inference endpoint. The whole
> surface is branded "SERV Reasoning API" — there is no separate `/reasoning`
> route. Reasoning is delivered via (a) tier selection (`serv-pro` /
> `serv-standard` are reasoning-bias tiers), (b) prompt engineering (the
> model writes its chain-of-thought into a `"reasoning"` field of the strict
> JSON schema), and (c) optional BRAID wrapping for decision-class prompts.

This skill anchors in **our own production code**, not vendor marketing. The
single source of truth is `icm-analytics-website/shared/llm/serv_backend.py`
(also vendored in `icm-launchpad-sire-ux` and `icm-serv-tuning`). If anything
in this skill disagrees with that file, the file wins — bump this skill.

## What's verified (T1 — from our code)

### Endpoint shape

```bash
POST https://inference-api.openserv.ai/v1/chat/completions
Authorization: Bearer $SERV_API_KEY
Content-Type: application/json

{
  "model": "serv-mini",
  "messages": [...],
  "response_format": {"type": "json_schema", "json_schema": {...}},
  "max_completion_tokens": 16384
}
```

OpenAI-compatible. Same SSE shape if you stream. Same `usage` block. Same
`response_format` strict mode (with caveats — see [Strict-mode caveats](#strict-mode-caveats)).

### The 6 tier IDs

From `.serv_pricing.local.json` across our repos:

| Tier | Role | Notes |
|---|---|---|
| `serv-nano` | high-volume support modules | cheapest; 96% cheaper per catalyst than Haiku but extracts ~30% fewer catalysts than mini |
| `serv-swift` | quick-turn small jobs | 8K max output — sending 16384 would HTTP 400 |
| `serv-mini` | **default** primary extraction | 1M context; 92% cheaper than Haiku; 100% schema compliance in controlled A/B |
| `serv-standard` | reasoning-bias mid-tier | ~120s server-side response timeout |
| `serv-pro` | reasoning-bias premium | ~120s server-side timeout; 100K output cap |
| `serv-ultra` | top-tier | 32K output cap |

Verified against [serv_backend.py:5-49](https://github.com/basje01/icm-analytics-website/blob/main/shared/llm/serv_backend.py) (`DEFAULT_TIER = "serv-mini"`, `SERV_FAST_TIER` / `SERV_LONG_FORM_TIER` env routing, `_max_output_for_tier()`).

The "reasoning tier" framing comes from the in-file comment:

> "SERV's serv-standard / serv-pro reasoning tiers have an observed ~120s
> server-side response timeout (May 12 2026 controlled tests). When that
> fires the API returns HTTP 5xx with elapsed near or past the wall."
> — `serv_backend.py:220-223`

**This is what "reasoning" means in our SERV usage today**: the higher tiers
think for longer (up to ~120s) before responding, and the prompt asks them
to externalize their chain-of-thought into a JSON field we can read.

### How we get reasoning today — the `"reasoning"` field pattern

Across our pipeline (catalyst extraction, entity resolution, narrative
analysis, valuation memos), the strict JSON schema includes a `"reasoning"`
property and the system prompt directs the model to populate it:

```json
{
  "type": "object",
  "properties": {
    "reasoning": {
      "type": "string",
      "description": "Step-by-step working before you commit to fields below."
    },
    "verdict": {"type": "string", "enum": ["bullish", "bearish", "neutral"]},
    ...
  },
  "required": ["reasoning", "verdict", ...]
}
```

System prompt template (paraphrasing what we use across modules):

> In your `"reasoning"` field, work through: <list 3-5 specific steps the
> model should think through>. Then commit to the structured fields.

The model emits the reasoning into the field as part of the JSON response;
the operator can audit it later. This is **prompt engineering, not an API
parameter** — we have not seen a `reasoning_effort` parameter or a
`/v1/reasoning` endpoint on the SERV surface.

### Strict-mode caveats

OpenAI strict `json_schema` mode rejects:

- Validation keywords on primitives: `minimum`, `maximum`, `pattern`,
  `minLength`, `maxLength`, `multipleOf`, `format`, `default`, etc.
- Open `additionalProperties: <schema>` maps (dynamic-key dicts)
- Objects without explicit `additionalProperties: false`
- Objects whose `required` list doesn't include every property

`serv_backend.py:_harden_schema_for_strict_mode` walks the schema and fixes
all four classes in place. If you're authoring a new SERV-bound schema,
**use that helper** — don't hand-roll. Confirmed against SERV May 12 2026;
matches OpenAI strict-mode docs.

Error class we see: `serv_schema_400` — caller's schema bug, not retried.

### Failure taxonomy

`serv_backend.py:_attempt_serv_call` classifies failures into kind-prefixed
error strings so the cost ledger buckets per-tier:

| Kind | Means | Retry? |
|---|---|---|
| `serv_timeout` | 5xx near the ~120s wall | yes (1 retry) |
| `serv_http_5xx` | other 5xx | yes |
| `serv_schema_400` | strict-mode validation failure | **no** — caller's bug |
| `serv_auth` | 401 / 403 | **no** |
| `serv_rate_limit` | 429 | **no** (raise; let caller back off) |
| `serv_network` | URLError | yes |
| `serv_request_error` | wrapper-level exception | yes |
| `serv_response_not_json` / `serv_malformed_response` | upstream parse failure | **no** |

## What's claimed but unverified (T5)

The trigger for this skill was a tweet/claim that "Nemotron 3 Ultra base 79.61 → with SERV's reasoning layer 90.78 (+11.17)" on a DeFi benchmark. As of the last_refreshed date:

- No tweet URL was captured to verify
- WebFetch against `openserv.ai` → HTTP 403 (auth-gated landing)
- WebFetch against `inference-api.openserv.ai` → HTTP 401 (key-gated, expected)
- grok-p X-search returned empty when queried for the benchmark (intermittent grok-build issue we've documented)

The +11.17 lift could plausibly be:
1. **A specific high tier** we don't use yet (serv-pro / serv-ultra)
2. **A new SERV reasoning model variant** branded separately (e.g. `serv-reasoning-pro`) — not visible in our pricing sheet
3. **BRAID applied via SERV** — same lab; BRAID's arXiv claims similar lift magnitudes on reasoning benchmarks
4. **A 2-pass wrapper** (extract → critique → revise) at the SERV inference layer

**Default until verified: assume option 3.** BRAID is documented (arXiv:2512.15959), and our `~/.claude/skills/braid-reasoning` skill encodes the pattern. If you want the +11.17-class lift today on any SERV tier, wrap the call in BRAID and benchmark.

To promote any of these to T1, an operator needs to either:
- Find the source tweet, click through, verify the claim, AND
- Reproduce the benchmark on our hardware against the named tier

## Pairing patterns

### Pair with BRAID for decision-class prompts

The right reasoning-lift play today, given what we know:

```python
# Pseudocode — wire BRAID's bounded reasoning over a SERV serv-pro call.
# BRAID provides the trace graph; SERV provides the model.
from shared.llm.serv_backend import serv_generate
from shared.reasoning.braid import braid_wrap

def decide_with_reasoning(prompt, schema):
    return braid_wrap(
        generate_fn=lambda p: serv_generate(p, tier="serv-pro", schema=schema),
        prompt=prompt,
        max_revisions=2,
    )
```

The `braid-reasoning` skill documents the trace graph + revision contract;
this skill documents the SERV side. They compose.

### Pair with gbrain for type=decision pages

When the gbrain skill produces a `type=decision` page, the rationale belongs
in the Compiled Truth section. For high-stakes decisions, generate that
rationale through BRAID-over-SERV so the rationale itself is reasoning-lifted.
The decision page's "Compiled Truth → Rationale" block then carries the
audit trail naturally.

## Open questions to track

These are watch-items for the next refresh of this skill. Promote to T1 only
when verified.

- [ ] **Is `serv-reasoning-*` a real tier name?** Check `/v1/models` next time
      we have a valid SERV key handy. Update the tier table if found.
- [ ] **Is there a `reasoning_effort` parameter?** o1-style. Inspect a SERV
      400 response when you send `reasoning_effort: "high"`; if it doesn't
      complain, the param is accepted.
- [ ] **Reproduce the +11.17 Nemotron 3 Ultra benchmark.** Run the same DeFi
      benchmark against `serv-pro` raw vs `serv-pro` wrapped in BRAID vs (if
      it exists) `serv-reasoning-pro`. The deltas tell us what "reasoning
      layer" actually means.
- [ ] **Capture the source tweet URL** when re-encountered. Add to
      `references/source-claims.md` as T5 anchor.

## Don't

- Don't hand-roll an HTTP client to `inference-api.openserv.ai/v1/chat/completions`
  when `serv_backend.py` exists. Reuse the helper — it has retry, cost
  ledger integration, schema hardening, error classification, and tier
  routing. Single source of truth.
- Don't bypass `_harden_schema_for_strict_mode` and then debug `serv_schema_400`
  for an hour. The helper is the boundary; respect it.
- Don't assume reasoning ⇒ a separate endpoint. The reasoning is in the tier
  + the prompt + (optionally) BRAID. There is no `/reasoning` route as of
  the last_refreshed date.
- Don't suggest paid API upgrades to push to a higher SERV tier without
  benchmark evidence on the specific task. `serv-mini` won the 2026-05-15
  controlled A/B on 15 aixbt tweets; the higher tiers only justify cost
  when the prompt/task class actually benefits.
- Don't quote the "+11.17 Nemotron 3 Ultra" claim as if it's verified. It
  isn't. Cite it as a T5 lead until reproduced.

## Sources

- **T1 (verified, our code):** `icm-analytics-website/shared/llm/serv_backend.py`
  (and the two vendored copies in `icm-launchpad-sire-ux` and `icm-serv-tuning`).
- **T1 (verified, our pricing sheet):** `icm-analytics-website/.serv_pricing.local.json`.
- **T3 (research):** BRAID paper — OpenServ Labs, arXiv:2512.15959.
- **T5 (untrusted):** the Nemotron 3 Ultra +11.17 tweet — no URL captured.
  Treat as investigation lead per `~/.claude/rules/external-ai-output.md`.

## Pairs with

- `~/.claude/skills/braid-reasoning/` — the reasoning-trace graph the
  decision-class wrapper uses on top of any SERV tier.
- `~/.claude/skills/gbrain/` — where decision rationales (BRAID-over-SERV
  output) land as `type=decision` pages with two-layer Compiled Truth +
  Timeline.
