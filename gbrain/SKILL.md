---
name: gbrain
description: >
  Personal-knowledge MCP memory server by Garry Tan (github.com/garrytan/gbrain).
  Runs on hermes-hz at :3131 behind a scoped Bearer key. This skill encodes the
  Garry-aligned discipline: agent reads RESOLVER before any put_page, files
  into one of 7 MECE types (concept / decision / infrastructure / project /
  prompt / inbox / archive), writes two-layer pages (compiled-truth above the
  line, append-only timeline below), uses lowercase kebab-case slugs (uppercase
  triggers an addTag race), and searches gbrain FIRST when answering any
  question. Covers wiring + auth (bootstrap → scoped API key in
  MCP_GBRAIN_API_KEY), tool scoping (47/82 tools allowed), the weekly auto-
  update timer (Garry ships ~daily), and the ZeroEntropy embedding provider
  Garry uses on his own 350k-page brain.
metadata:
  triggers: >-
    gbrain, mcp_servers.gbrain, gbrain:put_page, gbrain:get_page, gbrain:query,
    gbrain:list_pages, MCP_GBRAIN_API_KEY, hermes-hz memory, hermes memory,
    127.0.0.1:3131, /admin/api/api-keys, RESOLVER, compiled truth, timeline
    page, MECE filing, Karpathy wiki, store this in memory, what do I know
    about, search my brain, gbrain.service, zembed-1, zerank-2, ZeroEntropy
    embedding, garry tan brain, gbrain-update.timer, qwen3-embedding,
    ollama:qwen3-embedding, GBRAIN_EMBEDDING_MODEL, gbrain doctor, gbrain
    retrieval-upgrade, write_page, retrieve_page, addTag failed
  category: ops
  schema_version: '1'
  version: 1.0.0
  last_refreshed: 2026-06-08
  upstream_repo: https://github.com/garrytan/gbrain
  upstream_branch: master
  installed_version: 0.42.36.0
  host: hermes-hz
  port: 3131
---

# gbrain — Garry Tan's personal-knowledge memory layer

Garry's [gbrain](https://github.com/garrytan/gbrain) is a Postgres-native
(PGLite + pgvector) personal knowledge brain with hybrid (BM25 + vector + graph)
RAG search. We run it on **hermes-hz at `127.0.0.1:3131`** as an MCP server
that Hermes routes through.

This skill exists because **the wiring is easy, the usage discipline is
non-obvious, and Garry ships ~daily** (35 patches in 8 days as of 2026-06-08).
Without explicit discipline, the brain rots into a flat tag soup that violates
the founding principles Garry calls out as anti-patterns.

## Founding principles (verbatim from upstream `docs/GBRAIN_RECOMMENDED_SCHEMA.md`)

> "Knowledge management has failed for 30 years because maintenance falls on
> humans. LLM agents change the equation — they don't get bored, don't forget
> to update cross-references, and can touch 50 files in one pass. Your wiki
> stays alive because the cost of maintenance is near zero."

> "GBrain is a compiled intelligence system. Not a note-taking app. Not 'chat
> with your notes.' Every page is an intelligence assessment."

The three founding principles:

1. **MECE directories** — every fact has one primary home. Resolver-driven.
2. **Compiled truth + timeline** — two-layer pages: synthesis above the line,
   append-only evidence log below.
3. **Enrichment fires on every signal** — meetings/emails/tweets auto-update
   entity pages. The agent maintains the wiki; the operator just curates.

Full design rationale: `references/upstream-schema-excerpt.md`.

## The seven types (our personal-bot adaptation)

Garry's design ships 16 directories suited to a YC company brain. We use a
narrower 7-type MECE tuned to a single-operator infrastructure stack. The
canonical decision tree is the **`resolver`** page on the live host:

```bash
ssh hermes-wg '/home/bas/.local/bin/hermes chat -q "Use gbrain:get_page slug=resolver; show me the page."'
```

The types:

- **concept** — gotchas, mental models, "ohhh that's why" lessons, verified architectural facts
- **decision** — operator choices with rationale
- **infrastructure** — hosts, services, deployments (entity-like, one page per thing)
- **project** — active workstreams
- **prompt** — reusable LLM prompt library
- **inbox** — unsorted captures awaiting triage
- **archive** — dead pages, completed projects

## Page format — every type, no exceptions

```
---
type: <one of the 7>
tags: [bare-list, of, kebab-tags]
state: { status: <verified|provisional|stale>, evidence: <how we know> }
---

# Title

## Compiled Truth
Synthesis. Always current. Rewrite when evidence changes.
Lead with executive summary. Then State, Open Threads, See Also.

State:
- field: value

Open Threads:
- [ ] still-active item

See Also:
- [[other-page-slug]]

---

## Timeline
Append-only. Reverse-chronological evidence log. UTC dates.

- 2026-MM-DDTHH:MMZ source: <how we know>. <what was observed>
```

## Slug convention (load-bearing)

**Slugs MUST be lowercase kebab-case.** Verified 2026-06-08 on v0.42.36.0:
passing `slug=RESOLVER` (uppercase) makes `put_page` return
`created_or_updated` but then trips `addTag failed: page "RESOLVER"
(source=default) not found` because the canonical row stores lowercase but the
tag pass looks up the original casing. The page ends up half-created (no tags)
and effectively invisible to `list_pages`. Always `slug=lower-kebab-case`.

## Auth + wiring (TL;DR — full procedure in references)

**Authoritative reference**: `~/Code/bas-personal-bot/docs/gbrain-memory.md`.
What this skill captures so you don't have to chase it:

- `GBRAIN_ADMIN_BOOTSTRAP_TOKEN` in `/etc/gbrain/gbrain.env` is for
  `/admin/login` only — NOT for `/mcp`. Returns 401 on every MCP call.
- Real flow: bootstrap → `POST /admin/login` `{token: ...}` → session cookie
  → `POST /admin/api/api-keys` → scoped key in `MCP_GBRAIN_API_KEY`.
- The MCP scope lives in `~/.hermes/config.yaml` under
  `mcp_servers.gbrain.tools` and **must be a `{include: [...]}` dict**.
  A bare list silently disables scoping AND crashes
  `hermes tools enable gbrain:<tool>`.
- `/mcp` requires `Accept: application/json, text/event-stream`. Just
  `Authorization: Bearer …` returns 406.
- Bootstrap token format: `^[A-Za-z0-9_-]{32,}$`. Standard
  `openssl rand -base64 32` includes `=` padding and fails the regex. Use
  `head -c 32 /dev/urandom | base64 | tr -d "+/=" | head -c 48`.

## When you write to gbrain — the algorithm

1. **Search first.** `gbrain:list_pages tag=<topic>` or `gbrain:query
   query="…"`. If a related page exists, **update it** — don't fragment.
2. **Read the resolver.** `gbrain:get_page slug=resolver`. The page tells you
   which type the incoming signal belongs to. Cache the answer mentally for
   the rest of the session; don't re-fetch.
3. **Match to one type.** When in doubt, file as `inbox` and surface it to
   the operator so the schema can evolve.
4. **Compose two-layer.** Frontmatter + Compiled Truth + `---` + Timeline.
   Include `See Also: [[slug]]` cross-references to related pages.
5. **Lowercase kebab slug.** Don't paste a user-supplied uppercase id.
6. **Put_page once.** Verify via `gbrain:get_page slug=<your-slug>`.

## When you READ from gbrain — the algorithm

1. **Prefer `gbrain:query`** (hybrid retrieval) over `gbrain:search` (keyword
   only). With embeddings configured, query catches semantic neighbors that
   BM25 misses.
2. **`gbrain:traverse_graph slug=<seed>`** to follow `See Also` edges when
   reasoning across related pages.
3. **`gbrain:list_pages tag=<topic>`** for inventory questions ("what
   decisions have I made about X?").
4. **Trust the bytes, not the LLM's framing.** When the model summarizes a
   gbrain page, the QUOTED content is real; the connective tissue (especially
   on a fallback model like xiaomi/mimo) is generative and may invent
   attribution.

## Garry-aligned anti-patterns to avoid

Garry has called these out explicitly on X. Avoiding them is a hard rule:

- **Vague / monolithic agents.** "Vague agents just create vague output
  faster... Bad agents do not become good because you connected more tools."
  Specialist agents with narrow scope + clear definition of done.
- **Context bleed across domains.** Especially relevant if you ever multi-
  tenant gbrain. Scoped pods, not generalists with everyone's data.
- **Single-strategy retrieval.** Vector-only is "measurably weaker" per
  Garry's own benchmarks. Always hybrid (BM25 + vector + graph).
- **Stale or unprovenanced data.** Every Compiled Truth claim must trace to
  a Timeline entry with date + source.
- **Plug-and-play before 1.0.** From [@garrytan Apr 26 2026](https://x.com/garrytan/status/2048446829537136888):
  *"GBrain is still in experimental mode and not easy to use yet. It won't be
  until it hits 1.0 which is not for a little bit!"* Expect rough edges; be
  fast to back up before any destructive operation.

## Embedding provider — Garry's recommendation (T5, anchored)

From [@garrytan May 17 2026](https://x.com/garrytan/status/2056119107133870149):

> *"GBrain now ships with ZeroEntropy as the recommended default embedding
> and re-ranking option over OpenAI and Voyage AI. ... For personal AI
> scenarios against my 120k markdown brain ZeroEntropy has earned the top slot."*

Setup (after `dashboard.zeroentropy.dev` signup for the key):

```bash
ssh -t hermes-wg '
sudo tee -a /etc/gbrain/gbrain.env > /dev/null <<EOF
ZEROENTROPY_API_KEY=ze_...
GBRAIN_EMBEDDING_MODEL=zeroentropyai:zembed-1
GBRAIN_EMBEDDING_DIMENSIONS=1024
EOF
sudo systemctl restart gbrain
sleep 5
sudo -u gbrain HOME=/var/lib/gbrain bash -c "cd /opt/gbrain/app && /opt/bun/bin/bun run src/cli.ts retrieval-upgrade --to zeroentropyai:zembed-1 --reindex"
'
```

Zero-cost fallback: `ollama:qwen3-embedding:4b` (MTEB 69.45, ~2.5GB disk +
~3-4GB RAM). Same `retrieval-upgrade` flow.

## Auto-update (Garry ships ~daily)

We installed a weekly timer at
`~/Code/bas-personal-bot/deploy/gbrain-update.{sh,service,timer}` that:

- Sun 03:17 UTC + 15min jitter, plus `Persistent=true` (boot catch-up)
- Snapshots PGLite to `/var/lib/gbrain/.gbrain/backups/auto-<UTC>/` BEFORE
  stopping the service
- `git fetch + reset --hard origin/master + bun install + apply-migrations`
- Waits for `/health` 200 (60s); on failure rolls back to snapshot + previous
  HEAD
- Keeps last 5 snapshots, prunes via find+mtime
- Persists status to `/var/lib/gbrain/.gbrain/last-update-status.json` for
  the bot's daily health check

Manual catch-up to pick up a same-day ship:
```bash
ssh hermes-wg 'sudo systemctl start gbrain-update.service'
journalctl -u gbrain-update.service -n 30 --no-pager
```

## Keeping this skill fresh — the refresh ritual

Garry posts about gbrain on X multiple times per week, often ahead of the
docs. The grok-p path (with native X search) is how we keep this skill
anchored to current intent without polling the timeline manually.

**Refresh command** (run weekly, or any time we hit something gbrain-related
that surprises us):

```bash
~/.claude/skills/gbrain/refresh.sh
```

The script:
1. Runs grok-p X-search queries for new Garry posts about gbrain since
   `metadata.last_refreshed` in the SKILL.md frontmatter.
2. Reads upstream `master/CHANGELOG.md` for version bumps since
   `metadata.installed_version`.
3. Writes findings to `references/t5-grok-intel-<UTC>.md` — **T5,
   unverified, NOT in the skill body until reviewed.**
4. Prints a diff vs the latest prior capture so the operator sees what's
   new.
5. Surfaces a prompt: "promote any verified claim from this T5 dump into
   SKILL.md by hand, with anchor URLs."

**T5 → SKILL.md promotion rule**: only happens after cross-checking against
the gbrain repo (T1). A grok-p claim of "v0.43.0 ships next week" is a lead;
the actual fact lives in `garrytan/gbrain` master commits + CHANGELOG.

Last refresh: see `metadata.last_refreshed` above. Refresh procedure:
`references/refresh-procedure.md`.

## Local-only references (this directory)

- `references/upstream-schema-excerpt.md` — quoted from
  `garrytan/gbrain/master/docs/GBRAIN_RECOMMENDED_SCHEMA.md` (T1 anchor)
- `references/refresh-procedure.md` — operator playbook for refreshing this
  skill from grok-p without violating the external-ai-output safety rules
- `references/t5-grok-intel-<UTC>.md` — dated captures of grok-p findings
  (T5, untrusted until promoted)

## On the host (live source of truth)

- `gbrain:get_page slug=resolver` — the canonical decision tree
- `gbrain:list_pages` — all current pages, grouped by type
- `~/Code/bas-personal-bot/docs/gbrain-memory.md` — the wiring procedure +
  lessons captured
- `~/Code/bas-personal-bot/docs/architecture.md` — system map; gbrain is the
  memory layer for the personal bot
- `~/Code/bas-personal-bot/config/SOUL.md` — Hermes agent persona; codifies
  "read resolver before put_page" as a hard rule
