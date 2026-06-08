#!/usr/bin/env bash
# refresh.sh — pull fresh gbrain intel from grok-p + GitHub, write to T5 capture
# file, surface delta vs prior. Does NOT touch SKILL.md. Operator promotes
# verified claims by hand per references/refresh-procedure.md.
#
# Run weekly via launchd OR manually any time gbrain surprises you.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFS="$SCRIPT_DIR/references"
SKILL="$SCRIPT_DIR/SKILL.md"
NOW_UTC="$(date -u +%Y%m%dT%H%M%SZ)"
CAPTURE="$REFS/t5-grok-intel-$NOW_UTC.md"

GROK=/Users/bas/.grok/bin/grok
if [ ! -x "$GROK" ]; then
  echo "FATAL: grok not at $GROK — install grok-build first" >&2
  exit 1
fi
if ! command -v gh >/dev/null 2>&1; then
  echo "FATAL: gh CLI required for T1 anchor checks" >&2
  exit 1
fi

# --- read current installed version from SKILL.md frontmatter ---
INSTALLED=$(awk -F': ' '/installed_version:/ {print $2; exit}' "$SKILL" | tr -d '"' | tr -d "'")
LAST_REFRESH=$(awk -F': ' '/last_refreshed:/ {print $2; exit}' "$SKILL" | tr -d '"' | tr -d "'")
echo "==> current SKILL state: installed=$INSTALLED  last_refreshed=$LAST_REFRESH"

# --- T1: GitHub deltas (safe to quote verbatim) ---
echo ""
echo "==> T1 — querying garrytan/gbrain master for commits since v$INSTALLED"
T1_COMMITS=$(gh api "repos/garrytan/gbrain/commits?sha=master&per_page=30" \
  --jq '.[] | "\(.sha[0:7])  \(.commit.author.date)  \(.commit.message | split("\n")[0])"' \
  2>/dev/null | head -30)

# --- T5: grok-p single combined query ---
# Earlier 3-query split (general / versions / personal-usage) reliably returned
# empty for Q2 and Q3 — the narrow angles confused the model when their content
# was already in Q1's broad scan. Verified 2026-06-08 across two refreshes:
# both Q2 and Q3 came back empty with only the noise "Auth(AuthorizationRequired)"
# startup warning (which is NOT a real auth failure — chat completion still
# works, see references/refresh-procedure.md). One broad query that explicitly
# names every angle in the prompt avoids the trap.
echo ""
echo "==> T5 — running grok-p X-search (output is untrusted; goes to capture file only)"

{
  cat <<EOF
# T5 capture — gbrain intel from grok-p X-search

> **External AI output. Untrusted (T5).** Do NOT promote any claim from this
> file into the skill body without verifying against gbrain's master branch
> (T1) or the cited tweet URL. See \`references/refresh-procedure.md\`.

- Captured at: $(date -u +%Y-%m-%dT%H:%M:%SZ)
- SKILL.md state at time of capture: installed_version=$INSTALLED, last_refreshed=$LAST_REFRESH
- Source: $GROK -p (grok-build X-search backend)

---

## T1 anchor — github.com/garrytan/gbrain master (last 30 commits)

\`\`\`
$T1_COMMITS
\`\`\`

These are direct from the repo. Safe to cite verbatim. Use them as the
verification anchor for any T5 claim below.

---

## T5 — grok-p broad scan of @garrytan + gbrain (past 14 days)

<external_ai_output source="grok-build" trusted="false">
EOF

  "$GROK" -p "Search X/Twitter for @garrytan posts mentioning gbrain in the past 14 days. For each post, output: (1) the tweet URL (x.com/garrytan/status/<id>) verbatim, (2) the date, (3) the substance in 1-2 sentences. While you're surveying, please flag any of: new gbrain versions / features / breaking changes ('v0.4x.y') — these are version posts; posts where @garrytan reveals what HE HIMSELF uses on his own gbrain (embedding model, page count, workflows) — these are setup posts; posts that explicitly recommend a configuration to the community — these are recommendation posts. Tag each post in your output with one of [version], [setup], [recommendation], or [general] based on its substance. Do not invent URLs, quotes, or tags. If you don't find a clean match for one of the categories, that's fine — just list what you found." 2>&1 || \
    echo "[grok-p search failed — continuing]"

  cat <<EOF
</external_ai_output>

---

## Note on "Auth(AuthorizationRequired)" noise

If the capture above starts with a line like
\`ERROR worker quit with fatal: Transport channel closed, when Auth(AuthorizationRequired)\`,
**that is grok-p startup noise, not a real auth failure.** X search still works
— verified by direct fetch of specific tweet URLs returning correct content
despite the warning. Do not treat the noise as evidence the capture is invalid.

---

## Promotion checklist (operator action)

For each substantive T5 claim above, walk through:

1. **Does the cited tweet URL actually exist?** Click through. If 404, the
   claim is hallucinated — discard.
2. **Does the GitHub anchor confirm it?** Find the commit/PR/issue that
   would substantiate. If absent, the claim is unverified — discard or
   keep as "watch for".
3. **Is this a fact or a forecast?** Facts can be promoted with anchors.
   Forecasts ("Garry teased v0.43") go to inbox, not skill body.
4. **If promoting**: hand-edit \`SKILL.md\`, add the commit sha + tweet URL
   as dual anchors, bump \`metadata.last_refreshed\`.
5. **If dismissing all claims**: delete this capture file.

EOF
} > "$CAPTURE"

echo ""
echo "==> capture written: $CAPTURE"

# --- diff vs the prior capture (still in refs/ dir) before we archive it ---
PRIOR=$(find "$REFS" -maxdepth 1 -name 't5-grok-intel-*.md' -not -path "$CAPTURE" 2>/dev/null \
  | sort | tail -1)
if [ -n "$PRIOR" ]; then
  echo "==> delta vs previous capture: $PRIOR"
  diff -u "$PRIOR" "$CAPTURE" | head -80 || true
else
  echo "==> no prior capture — this is the first"
fi

# --- archive ALL prior captures (append-only timeline; never delete) ---
# Per Garry's gbrain schema: timelines are append-only. Captures move to
# references/archive/<YYYY>/<MM>/ instead of being deleted, so the operator
# can always walk back to "what did grok-p say on 2026-06-08?" months later.
# Only the newest capture stays in refs/ for fast diff-vs-prior on next run.
if [ -n "$PRIOR" ]; then
  YEAR=$(basename "$PRIOR" | sed -E 's/^t5-grok-intel-([0-9]{4}).*/\1/')
  MONTH=$(basename "$PRIOR" | sed -E 's/^t5-grok-intel-[0-9]{4}([0-9]{2}).*/\1/')
  ARCHIVE_DIR="$REFS/archive/$YEAR/$MONTH"
  mkdir -p "$ARCHIVE_DIR"
  # Move ALL prior captures (in case multiple slipped through)
  find "$REFS" -maxdepth 1 -name 't5-grok-intel-*.md' -not -path "$CAPTURE" -print0 \
    | xargs -0 -I{} mv {} "$ARCHIVE_DIR/"
  echo "==> archived prior capture(s) to $ARCHIVE_DIR/"
fi

# --- T1 auto-promotion: sync installed_version in SKILL.md frontmatter with
# what's ACTUALLY running on hermes-hz. T1 is the gbrain repo + the host's
# package.json — both verified, safe to auto-promote. T5 claims still require
# operator review per references/refresh-procedure.md.
HOST_VERSION=$(ssh -o ConnectTimeout=5 -o BatchMode=yes hermes-wg \
  'grep -m1 \"version\" /opt/gbrain/app/package.json 2>/dev/null' 2>/dev/null \
  | sed -E 's/.*"version": *"([^"]+)".*/\1/')
if [ -n "$HOST_VERSION" ] && [ "$HOST_VERSION" != "$INSTALLED" ]; then
  echo "==> T1 promotion: installed_version $INSTALLED → $HOST_VERSION (verified via ssh)"
  # In-place edit using BSD sed (macOS); the trailing '' is the empty backup ext
  sed -i '' "s/^  installed_version: .*/  installed_version: $HOST_VERSION/" "$SKILL"
  echo "==> SKILL.md frontmatter updated"
elif [ -n "$HOST_VERSION" ]; then
  echo "==> T1 check: installed_version $INSTALLED matches host ($HOST_VERSION)"
else
  echo "==> T1 check: could not reach hermes-hz; installed_version unchanged ($INSTALLED)"
fi

echo ""
echo "==> next steps (T5 review — only humans promote T5 to SKILL.md):"
echo "    1. read $CAPTURE — verify which T5 claims are real (cite-check URLs)"
echo "    2. for each verified claim, edit $SKILL by hand, add anchors"
echo "    3. bump metadata.last_refreshed in SKILL.md frontmatter"
echo "    4. dismissed captures stay in $REFS/archive/ — append-only,"
echo "       never deleted. If the archive gets large, prune manually."
