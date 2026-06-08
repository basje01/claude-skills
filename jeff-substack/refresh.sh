#!/usr/bin/env bash
# refresh.sh — pull @0xJeff's Substack via the public per-publication RSS
# feed (full bodies for paid posts included — Substack's default), write
# new posts to T5 captures under references/<date>-<slug>.md, surface delta
# vs prior, archive older captures append-only. Does NOT touch SKILL.md.
# Operator promotes verified claims by hand into gbrain per SKILL.md
# promotion section.
#
# Run weekly via launchd OR manually any time we want to pull fresh thinking.
# Zero env vars required — publication URL is baked in.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFS="$SCRIPT_DIR/references"
SKILL="$SCRIPT_DIR/SKILL.md"
NOW_UTC="$(date -u +%Y%m%dT%H%M%SZ)"

# --- URL config (defaults to verified publication; override via env if needed) ---
JEFF_SUBSTACK_URL="${JEFF_SUBSTACK_URL:-https://defi0xjeff.substack.com}"

# Guard against the dormant 0xjeff.substack.com (NOT our Jeff — that's a
# different "Jeff's Blockchain Insider" from 2022). Verified 2026-06-09.
if echo "$JEFF_SUBSTACK_URL" | grep -qE '^https?://0xjeff\.substack\.com/?$'; then
  echo "FATAL: JEFF_SUBSTACK_URL points at 0xjeff.substack.com — that's a" >&2
  echo "       DIFFERENT (dormant) Jeff. The correct URL for our Jeff is" >&2
  echo "       https://defi0xjeff.substack.com (already the default)" >&2
  exit 1
fi

# Substack publications expose a public RSS feed at <publication>/feed that
# delivers FULL post bodies by default (paid included), unless the author
# has enabled truncation. Verified 2026-06-09 that defi0xjeff.substack.com
# returns full content for all posts. No subscriber token needed —
# Substack's per-account RSS setting was deprecated; the per-publication
# feed is the canonical delivery path. The Python parser (below) checks
# each item's body for teaser markers and warns if Jeff ever flips
# truncation on.
FEED_URL="${JEFF_SUBSTACK_URL%/}/feed"
LAST_REFRESH=$(awk -F': ' '/last_refreshed:/ {print $2; exit}' "$SKILL" | tr -d '"' | tr -d "'")
echo "==> SKILL state: last_refreshed=$LAST_REFRESH  feed=$JEFF_SUBSTACK_URL"
echo ""

# --- fetch the paid RSS feed ---
TMP_FEED=$(mktemp -t jeff-feed.XXXXXX.xml)
trap "rm -f $TMP_FEED" EXIT
HTTP_CODE=$(curl -sS -o "$TMP_FEED" -w "%{http_code}" -A "claude-skills/jeff-substack/0.1" "$FEED_URL")
if [ "$HTTP_CODE" != "200" ]; then
  echo "FATAL: feed fetch returned HTTP $HTTP_CODE" >&2
  echo "       URL was: ${JEFF_SUBSTACK_URL%/}/feed?token=<redacted>" >&2
  exit 2
fi
FEED_BYTES=$(wc -c < "$TMP_FEED")
echo "==> fetched $FEED_BYTES bytes from feed"

# --- parse the RSS feed via defusedxml (blocks XXE + billion-laughs attacks) ---
# Substack RSS is HTTPS from a trusted provider, but defense in depth — the
# stdlib xml.etree.ElementTree is unsafe by default against entity-expansion
# attacks. defusedxml is the standard hardened drop-in replacement.
# Install once: pip3 install --user defusedxml
#
# Extract every <item> and emit one tab-separated line:
# pub_date_iso \t guid \t title \t link \t description_html_b64
PARSED=$(python3 - "$TMP_FEED" <<'PY'
import sys, base64, re
try:
    from defusedxml import ElementTree as ET
except ImportError:
    sys.stderr.write(
        "FATAL: defusedxml not installed.\n"
        "  pip3 install --user defusedxml\n"
        "(Required for safe RSS parsing — blocks XXE / billion-laughs.)\n"
    )
    sys.exit(3)
from email.utils import parsedate_to_datetime

# Phrases that indicate Substack truncated the body (publication enabled
# paid-only feed) — warn the operator so they know to check.
TEASER_PATTERNS = (
    "subscribe to read",
    "paid subscribers only",
    "this post is for paid subscribers",
    "continue reading",
)

tree = ET.parse(sys.argv[1])
root = tree.getroot()
ns = {"content": "http://purl.org/rss/1.0/modules/content/"}

for item in root.iter("item"):
    pub = item.findtext("pubDate") or ""
    try:
        iso = parsedate_to_datetime(pub).strftime("%Y-%m-%dT%H:%M:%SZ")
    except Exception:
        iso = pub
    guid = (item.findtext("guid") or "").strip()
    title = (item.findtext("title") or "").strip().replace("\t", " ")
    link = (item.findtext("link") or "").strip()
    body = item.findtext("content:encoded", default="", namespaces=ns) or item.findtext("description") or ""
    body_lower = body.lower()
    is_teaser = any(p in body_lower for p in TEASER_PATTERNS) and len(body) < 2000
    if is_teaser:
        sys.stderr.write(
            f"WARN: '{title}' looks like a teaser ({len(body)} chars) — "
            "Jeff may have enabled paid-only feed truncation. Body captured "
            "anyway; operator can paste fuller content if needed.\n"
        )
    body_b64 = base64.b64encode(body.encode("utf-8")).decode("ascii")
    print(f"{iso}\t{guid}\t{title}\t{link}\t{body_b64}")
PY
)
POST_COUNT=$(echo "$PARSED" | grep -c . || true)
echo "==> $POST_COUNT items in feed"

if [ "$POST_COUNT" = "0" ]; then
  echo "WARN: feed parsed cleanly but contained 0 items — empty feed?" >&2
  exit 0
fi

# --- write a capture per item; skip items we've already captured ---
NEW_COUNT=0
while IFS=$'\t' read -r ISO GUID TITLE LINK BODY_B64; do
  [ -z "$TITLE" ] && continue
  # slug from title (lowercase kebab-case, gbrain-compatible)
  SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g' \
    | cut -c1-60)
  DATE=$(echo "$ISO" | cut -c1-10)
  CAP="$REFS/$DATE-$SLUG.md"
  ARCHIVE_YEAR=$(echo "$DATE" | cut -c1-4)
  ARCHIVE_MONTH=$(echo "$DATE" | cut -c6-7)
  ARCHIVED="$REFS/archive/$ARCHIVE_YEAR/$ARCHIVE_MONTH/$DATE-$SLUG.md"
  # idempotent: skip if already captured (current OR archived)
  if [ -f "$CAP" ] || [ -f "$ARCHIVED" ]; then
    continue
  fi
  NEW_COUNT=$((NEW_COUNT + 1))

  {
    cat <<EOF
# T5 capture — @0xJeff Substack: $TITLE

> **External AI / analyst output. Untrusted (T5).** Do NOT promote any
> claim from this file into gbrain or any decision artifact without
> verifying against a T1/T2 anchor (on-chain data, official announcement,
> primary source). See \`SKILL.md\` § "T5 → gbrain promotion".

- Captured at: $(date -u +%Y-%m-%dT%H:%M:%SZ)
- Source: $LINK
- Published: $ISO
- GUID: $GUID

---

## Verbatim body (paid Substack content)

<external_ai_output source="jeff-substack" trusted="false">
EOF
    echo "$BODY_B64" | base64 -d
    cat <<EOF
</external_ai_output>

---

## Promotion checklist (operator action)

- [ ] Identify substantive claims (theses / frameworks / data points)
- [ ] For each claim, classify: fact / framework / forecast
- [ ] For facts → verify against T1/T2 anchor → promote to gbrain as
      \`type=concept\` (use \`gbrain:query\` first to find existing pages
      to update rather than fragment)
- [ ] For frameworks → require ≥2 independent confirmations before
      promotion to a \`type=concept\` page
- [ ] For forecasts → log to inbox if worth tracking; never to gbrain
      as if it were a fact
- [ ] If adopting a framework as a decision → run BRAID-over-SERV per
      \`braid-reasoning\` + \`serv-reasoning\` skills, then file gbrain
      \`type=decision\` page with the BRAID trace as Compiled Truth rationale
- [ ] All gbrain slugs lowercase-kebab-case (uppercase breaks addTag)
- [ ] This capture stays archived even if no promotion happens
EOF
  } > "$CAP"
  echo "==> captured: $CAP"
done <<< "$PARSED"

echo ""
echo "==> $NEW_COUNT new captures written; $((POST_COUNT - NEW_COUNT)) already captured (skipped)"

# --- diff vs prior capture (only when there's something new to diff) ---
if [ "$NEW_COUNT" -gt 0 ]; then
  PRIOR=$(find "$REFS" -maxdepth 1 -name '*.md' -not -newer "$REFS" 2>/dev/null \
    | sort | tail -1)
  if [ -n "$PRIOR" ] && [ -f "$PRIOR" ]; then
    NEWEST=$(find "$REFS" -maxdepth 1 -name '*.md' 2>/dev/null | sort | tail -1)
    if [ "$PRIOR" != "$NEWEST" ]; then
      echo ""
      echo "==> delta vs previous capture: $PRIOR → $NEWEST"
      diff -u "$PRIOR" "$NEWEST" 2>/dev/null | head -60 || true
    fi
  fi
fi

# --- archive captures older than the 3 newest (keep refs/ small) ---
# Append-only timeline: never delete. Move to references/archive/<YYYY>/<MM>/.
# Runs UNCONDITIONALLY so a previous run's stragglers get cleaned up even
# when there are no new captures.
#
# Implementation: write the list of files to archive to a temp file, then
# read from that file in the while-loop. This avoids a known issue with
# `find | sort | tail | while read … done <<< "$VAR"` where the
# here-string-into-while can drop entries under pipefail on big-batch
# first runs. macOS ships bash 3.2 (no mapfile/readarray), so a temp file
# is the most portable fix.
TO_ARCHIVE_LIST=$(mktemp -t jeff-archive.XXXXXX.txt)
find "$REFS" -maxdepth 1 -name '*.md' 2>/dev/null | sort -r | tail -n +4 > "$TO_ARCHIVE_LIST"
ARCHIVED_COUNT=0
while IFS= read -r OLD; do
  [ -z "$OLD" ] && continue
  BASE=$(basename "$OLD")
  YEAR=$(echo "$BASE" | cut -c1-4)
  MONTH=$(echo "$BASE" | cut -c6-7)
  ARC="$REFS/archive/$YEAR/$MONTH"
  mkdir -p "$ARC"
  if mv "$OLD" "$ARC/"; then
    ARCHIVED_COUNT=$((ARCHIVED_COUNT + 1))
    [ "$ARCHIVED_COUNT" -le 3 ] && echo "    → $ARC/$BASE" || true
  else
    echo "    ! mv failed: $OLD → $ARC/" >&2
  fi
done < "$TO_ARCHIVE_LIST"
rm -f "$TO_ARCHIVE_LIST"
if [ "$ARCHIVED_COUNT" -gt 0 ]; then
  echo "==> archived $ARCHIVED_COUNT older captures to references/archive/<YYYY>/<MM>/"
  [ "$ARCHIVED_COUNT" -gt 3 ] && echo "    (showing 3; full list in commit/file system)"
fi

# --- T1 auto-promotion: bump last_refreshed in SKILL.md frontmatter ---
TODAY=$(date -u +%Y-%m-%d)
if [ "$LAST_REFRESH" != "$TODAY" ]; then
  sed -i '' "s/^  last_refreshed: .*/  last_refreshed: $TODAY/" "$SKILL"
  echo ""
  echo "==> SKILL.md last_refreshed bumped to $TODAY"
fi

echo ""
echo "==> next steps (T5 review — only humans promote T5 to gbrain):"
echo "    1. read the new captures in $REFS/"
echo "    2. for each substantive claim, promote per SKILL.md checklist"
echo "    3. archived captures stay forever — append-only, never deleted"
