#!/usr/bin/env bash
# backfill.sh — pull historical Jeff posts beyond the most-recent-20 that the
# RSS feed returns. Iterates the Substack archive API in batches of 25 with
# offset pagination (offset=0,25,50,...,~125) to enumerate every post, then
# fetches each post's body_html via the per-slug API endpoint
# (<pub>.substack.com/api/v1/posts/<slug>) for any post we don't already
# have in references/ (current or archive).
#
# Each capture matches refresh.sh's format — same envelope, same promotion
# checklist — so the gbrain promotion workflow applies identically.
#
# Filters:
#   --filter <regex>   — only backfill posts whose slug OR title matches
#                        (e.g. --filter hermes, --filter "agent|inference")
#   --dry-run          — list what would be fetched without writing
#   --limit <N>        — stop after N fetches (rate-limit hygiene)
#
# Defaults to filter=hermes (the highest-leverage backfill).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFS="$SCRIPT_DIR/references"
SKILL="$SCRIPT_DIR/SKILL.md"

JEFF_SUBSTACK_URL="${JEFF_SUBSTACK_URL:-https://defi0xjeff.substack.com}"
BASE="${JEFF_SUBSTACK_URL%/}"

FILTER="hermes"
DRY_RUN=0
LIMIT=999
while [ $# -gt 0 ]; do
  case "$1" in
    --filter) FILTER="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --limit) LIMIT="$2"; shift 2 ;;
    --all) FILTER=".*"; shift ;;
    -h|--help)
      sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

echo "==> backfill: BASE=$BASE  filter=/$FILTER/i  limit=$LIMIT  dry_run=$DRY_RUN"

# --- enumerate all posts via the archive API ---
ALL_POSTS=$(mktemp -t jeff-archive-list.XXXXXX.txt)
trap "rm -f $ALL_POSTS" EXIT
for OFFSET in 0 25 50 75 100 125; do
  curl -sS "$BASE/api/v1/archive?sort=new&offset=$OFFSET&limit=25" \
    | python3 -c "
import sys, json
for p in json.load(sys.stdin):
    slug = p.get('slug', '')
    title = (p.get('title') or '').replace('\t', ' ').replace('\n', ' ')
    post_date = p.get('post_date', '')
    audience = p.get('audience', '')
    print(f'{post_date[:10]}\t{slug}\t{audience}\t{title}')
" 2>/dev/null >> "$ALL_POSTS"
done
TOTAL=$(wc -l < "$ALL_POSTS" | tr -d ' ')
echo "==> enumerated $TOTAL posts across the archive"

# --- filter for posts matching the regex ---
MATCHED=$(mktemp -t jeff-matched.XXXXXX.txt)
trap "rm -f $ALL_POSTS $MATCHED" EXIT
awk -F'\t' -v re="$FILTER" 'BEGIN{IGNORECASE=1} $2 ~ re || $4 ~ re' "$ALL_POSTS" > "$MATCHED"
MATCHED_COUNT=$(wc -l < "$MATCHED" | tr -d ' ')
echo "==> $MATCHED_COUNT posts match /$FILTER/i"

# --- for each matched post, check if we already have it; if not, fetch + write ---
FETCHED=0
SKIPPED_EXISTS=0
SKIPPED_LIMIT=0
while IFS=$'\t' read -r POST_DATE SLUG AUDIENCE TITLE; do
  [ -z "$SLUG" ] && continue
  if [ $FETCHED -ge $LIMIT ]; then
    SKIPPED_LIMIT=$((SKIPPED_LIMIT + 1))
    continue
  fi

  # filename slug from title (matches refresh.sh's convention)
  FILE_SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g' \
    | cut -c1-60)
  CAP="$REFS/$POST_DATE-$FILE_SLUG.md"
  ARCHIVE_YEAR=$(echo "$POST_DATE" | cut -c1-4)
  ARCHIVE_MONTH=$(echo "$POST_DATE" | cut -c6-7)
  ARCHIVED="$REFS/archive/$ARCHIVE_YEAR/$ARCHIVE_MONTH/$POST_DATE-$FILE_SLUG.md"

  if [ -f "$CAP" ] || [ -f "$ARCHIVED" ]; then
    SKIPPED_EXISTS=$((SKIPPED_EXISTS + 1))
    continue
  fi

  if [ $DRY_RUN -eq 1 ]; then
    echo "  would fetch: $POST_DATE  $SLUG  ($AUDIENCE)  '$TITLE'"
    FETCHED=$((FETCHED + 1))
    continue
  fi

  echo "==> fetching: $POST_DATE  $SLUG  '$TITLE'"
  POST_JSON=$(curl -sS "$BASE/api/v1/posts/$SLUG" 2>/dev/null)
  BODY_HTML=$(echo "$POST_JSON" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('body_html', '') or '')
except Exception as e:
    sys.stderr.write(f'parse error: {e}\n')
    sys.exit(1)
")
  if [ -z "$BODY_HTML" ]; then
    echo "    ! empty body — skipping (slug may have moved or post is paid-only without preview)" >&2
    continue
  fi

  # write the capture using the same envelope shape as refresh.sh
  ARCHIVE_DIR_FOR_THIS=$(dirname "$ARCHIVED")
  mkdir -p "$ARCHIVE_DIR_FOR_THIS"
  # Write directly to archive (not refs/) since backfilled posts are by
  # definition older than the current top-of-feed — keeps refs/ clean for
  # genuinely fresh captures.
  {
    cat <<EOF
# T5 capture — @0xJeff Substack: $TITLE

> **External AI / analyst output. Untrusted (T5).** Do NOT promote any
> claim from this file into gbrain or any decision artifact without
> verifying against a T1/T2 anchor (on-chain data, official announcement,
> primary source). See \`SKILL.md\` § "T5 → gbrain promotion".

- Captured at: $(date -u +%Y-%m-%dT%H:%M:%SZ) (backfilled via archive API)
- Source: $BASE/p/$SLUG
- Published: ${POST_DATE}T00:00:00Z
- Audience: $AUDIENCE
- Slug: $SLUG

---

## Verbatim body (Substack content via /api/v1/posts/<slug>)

<external_ai_output source="jeff-substack" trusted="false">
$BODY_HTML
</external_ai_output>

---

## Promotion checklist (operator action)

- [ ] Identify substantive claims (theses / frameworks / data points)
- [ ] For each claim, classify: fact / framework / forecast
- [ ] Facts → verify against T1/T2 anchor → promote to gbrain \`type=concept\`
- [ ] Frameworks → require ≥2 independent confirmations → \`type=concept\`
- [ ] Forecasts → log to inbox if worth tracking; never gbrain as fact
- [ ] Adopting a framework → BRAID-over-SERV → \`type=decision\` page
- [ ] All gbrain slugs lowercase-kebab-case
- [ ] This capture stays archived even if no promotion happens
EOF
  } > "$ARCHIVED"
  echo "    → $ARCHIVED"
  FETCHED=$((FETCHED + 1))
  # be polite to Substack — ~5 req/s is generous, but not abusive
  sleep 0.2
done < "$MATCHED"

echo ""
echo "==> backfill summary: fetched=$FETCHED  skipped_exists=$SKIPPED_EXISTS  skipped_limit=$SKIPPED_LIMIT"
[ $FETCHED -gt 0 ] && [ $DRY_RUN -eq 0 ] && echo "==> next: read the captures, promote substantive frameworks per SKILL.md"
