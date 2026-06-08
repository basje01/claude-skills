# Refreshing the gbrain skill from grok-p — safety procedure

Garry ships gbrain ~daily. The X feed and CHANGELOG drift faster than any
static skill can stay current. This procedure captures fresh intel without
silently injecting unverified claims into the skill body.

## What "refresh" means here

**Two source tiers, two write surfaces:**

| Source | Tier | Goes into | Auto-promote? |
|---|---|---|---|
| `garrytan/gbrain` master + CHANGELOG | T1 (verified) | SKILL.md frontmatter (`installed_version`, version notes) + body | yes |
| `@garrytan` X posts via grok-p | T5 (untrusted lead) | `references/t5-grok-intel-<UTC>.md` — never SKILL.md directly | **no** |
| operator-verified observation | T1 (verified) | SKILL.md body, with anchor | yes |

The hard rule: **T5 never enters SKILL.md without operator promotion.** A
grok-p search returns synthesis from a fallback model that may hallucinate
attributions, dates, or API surfaces. Letting it flow straight in is how
skills rot.

## How refresh.sh works

`~/.claude/skills/gbrain/refresh.sh` does five things, in order:

1. **Read current state.** Parses `SKILL.md` for `installed_version` and
   `last_refreshed`.
2. **Pull T1 deltas.** Hits `github.com/garrytan/gbrain` for: latest master
   sha, commit messages since installed_version, CHANGELOG diff. These are
   safe to surface verbatim (T1).
3. **Run one broad grok-p query.** Single search with explicit category tags
   (`[version]` / `[setup]` / `[recommendation]` / `[general]`) so the operator
   can scan the capture by intent. Output to
   `references/t5-grok-intel-<UTC>.md`.

   > Earlier the refresh used 3 separate narrow queries — Q1 always
   > succeeded; Q2 ("versions/features/breaking changes") and Q3 ("Garry's
   > personal setup") reliably came back empty across two refreshes
   > 2026-06-08. The relevant posts for Q2/Q3 were in Q1's broad scan anyway.
   > Collapsed to one well-formed query 2026-06-08 (`refresh.sh` commit
   > history has the diff). Lesson: narrow grok-p queries return empty
   > rather than "no match" when the desired content is covered by an
   > adjacent query — explicit category tags in one broad query work better.
4. **Diff vs prior capture.** Shows the operator what changed in the T5
   capture vs the last one. Same-as-before claims get de-duped; novel claims
   are highlighted.
5. **Print a promotion checklist.** For each T5 claim worth caring about,
   suggests a verification action: "to promote, find the corresponding
   commit/PR in `garrytan/gbrain`, then update SKILL.md with the anchor."

## Cadence

- **Weekly automatic** — there's a launchd plist at
  `~/Library/LaunchAgents/com.bas.gbrain-skill-refresh.plist` (install with
  `install-refresh-launchd.sh`). Fires Sunday 17:00 local — quiet but not
  overnight, so the operator sees the diff in their normal review window.
- **Manual** — any time the operator hits something surprising in gbrain
  (new tool, weird behavior, doc that's clearly stale):
  ```bash
  ~/.claude/skills/gbrain/refresh.sh
  ```

## What "promotion" looks like in practice

Worked example for a typical T5 → SKILL.md promotion:

1. grok-p surfaces in the capture: *"Garry on May 31: 'gbrain v0.42.1 just
   dropped, implements Microsoft SkillOpt, auto-improves SKILL.md files'"*
2. Operator opens the cited tweet URL — sanity check it exists, attributed
   correctly.
3. Operator opens `github.com/garrytan/gbrain/commits/master` — finds the
   `v0.42.1.0 feat: gbrain skillopt — self-evolving skills` commit.
4. Operator hand-edits SKILL.md to add a SkillOpt section with the commit
   sha + the tweet URL as dual anchors (T1 + T5 attribution).
5. Bumps `metadata.last_refreshed` to today.
6. Deletes the T5 capture file once its claims have all been promoted or
   dismissed.

Never `cat references/t5-*.md >> SKILL.md`. Always read, verify, hand-pick.

## What this procedure refuses

- **No auto-promoting** even "obvious" T5 claims. The whole point of the
  T5/T1 distinction is that "obvious" can still be hallucinated.
- **No deleting prior captures** until their claims are reviewed.
- **No skipping the verification anchor.** Every SKILL.md edit that
  references an external claim cites the tweet URL OR the commit sha.
- **No promoting claims about future versions** ("Garry teased v0.43"). Fact
  it when it ships, not when it's promised.

## External-AI-output rule alignment

This procedure aligns with `~/.claude/rules/external-ai-output.md` — grok-p
output is classified T5, captured behind a verbatim
`<external_ai_output source="grok-build" trusted="false">` envelope in the
dated capture file, and never executed as instructions.

## Real-world noise to ignore in captures

Grok-p's output often starts with an ANSI-colored line that LOOKS like a
fatal error:

```
[2m2026-06-08T19:23:12.853523Z[0m [31mERROR[0m worker quit with fatal: Transport channel closed, when Auth(AuthorizationRequired)
```

**That is startup noise, not a real failure.** Verified 2026-06-08: grok-p
returned the correct verbatim content of `x.com/garrytan/status/2063785286367392095`
(the v0.42.30 idea-lineage tweet) immediately after the error printed. Chat
completion + X search both work despite the warning. Treat the line as visual
clutter; don't promote it to a "the refresh broke" alarm.
