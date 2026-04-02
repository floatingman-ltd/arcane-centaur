#!/usr/bin/env bash
# confluence_publish.sh — Publish a local markdown file to its Confluence page,
#                         pull the current Confluence page back to local markdown,
#                         or fetch page comments.
#
# Usage:
#   confluence_publish.sh [options] <path-to-markdown-file>
#
# Modes (default: publish local markdown → Confluence):
#   --pull       Fetch the current Confluence page and overwrite the local
#                markdown file.  A .bak backup is created before overwriting.
#   --comments   Fetch all page comments and write them to <file>.comments.md.
#                Can be combined with --pull, or used standalone (no publish).
#
# Publish options:
#   --force      Skip the conflict check and publish even if Confluence has
#                been edited since the last recorded publish.
#
# Authentication (required environment variables):
#   CONFLUENCE_EMAIL       Your Atlassian account email address
#   CONFLUENCE_API_TOKEN   Your Atlassian API token
#                          Generate at: https://id.atlassian.com/manage-profile/security/api-tokens
#
# Optional environment variables:
#   PLANTUML_SERVER        Base URL of local PlantUML server (default: http://localhost:8080)
#
# Conflict detection:
#   When publishing, the script records the published version number in
#   docs/.confluence-state.json.  On subsequent publishes it compares the
#   recorded version to the live Confluence version.  If they differ, someone
#   has edited the page directly on Confluence; the publish is aborted unless
#   --force is passed.  Run with --pull first to import those changes.
#   Commit docs/.confluence-state.json so the whole team benefits.
#
# Dependencies:
#   pandoc   sudo apt install pandoc     (required for publish and --pull)
#   curl     sudo apt install curl
#   jq       sudo apt install jq
#   python3  (pre-installed on most systems; required for --pull)
#
# The Confluence page ID is resolved from docs/confluence-page-map.md at the
# git repository root of the target file.

set -euo pipefail

PLANTUML_SERVER="${PLANTUML_SERVER:-http://localhost:8080}"
PAGE_MAP_RELATIVE="docs/confluence-page-map.md"
STATE_FILE_RELATIVE="docs/.confluence-state.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Helpers ───────────────────────────────────────────────────────────────────

die() { echo "Error: $*" >&2; exit "${2:-1}"; }

# Temp file receives the response body of each curl call.
# On failure the cleanup trap prints its path so the full Confluence error is inspectable.
CURL_TMP="$(mktemp /tmp/confluence_publish_XXXXXX.json)"

cleanup() {
  local code=$?
  if [[ $code -ne 0 && -s "$CURL_TMP" ]]; then
    echo "Response body written to: $CURL_TMP" >&2
  else
    rm -f "$CURL_TMP"
  fi
}
trap cleanup EXIT

# ── Flag parsing ──────────────────────────────────────────────────────────────

MODE="publish"
FETCH_COMMENTS=false
FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pull)     MODE="pull";         shift ;;
    --comments) FETCH_COMMENTS=true; shift ;;
    --force)    FORCE=true;          shift ;;
    --)         shift; break ;;
    -*)         die "Unknown option: $1" ;;
    *)          break ;;
  esac
done

[[ $# -ge 1 ]] || { grep '^#' "$0" | sed 's/^# \{0,1\}//' | head -40 >&2; exit 1; }

# ── Dependency checks ─────────────────────────────────────────────────────────

command -v curl >/dev/null || die "curl is not installed"
command -v jq   >/dev/null || die "jq is not installed. Run: sudo apt install jq"

if [[ "$MODE" == "publish" ]] && ! $FETCH_COMMENTS; then
  command -v pandoc >/dev/null || die "pandoc is not installed. Run: sudo apt install pandoc"
fi

if [[ "$MODE" == "pull" ]]; then
  command -v pandoc  >/dev/null || die "pandoc is not installed. Run: sudo apt install pandoc"
  command -v python3 >/dev/null || die "python3 is required for --pull"
  [[ -f "$SCRIPT_DIR/confluence_preproc.py" ]] \
    || die "confluence_preproc.py not found alongside this script"
fi

MD_FILE="$(realpath "$1")"
[[ -f "$MD_FILE" ]] || die "file not found: $MD_FILE"

: "${CONFLUENCE_EMAIL:?CONFLUENCE_EMAIL must be set (see docs/guides/confluence.md)}"
: "${CONFLUENCE_API_TOKEN:?CONFLUENCE_API_TOKEN must be set (see docs/guides/confluence.md)}"

# ── Git root and page map ─────────────────────────────────────────────────────

GIT_ROOT="$(git -C "$(dirname "$MD_FILE")" rev-parse --show-toplevel 2>/dev/null)" \
  || die "file is not inside a git repository"

PAGE_MAP="$GIT_ROOT/$PAGE_MAP_RELATIVE"
[[ -f "$PAGE_MAP" ]] || die "page map not found at $PAGE_MAP"

STATE_FILE="$GIT_ROOT/$STATE_FILE_RELATIVE"
DOCS_DIR="$GIT_ROOT/docs"
REL_PATH="$(realpath --relative-to="$DOCS_DIR" "$MD_FILE")"

CONF_URL="$(grep -oP "^\|\s*\`${REL_PATH//./\\.}\`\s*\|[^|]+\|\s*\K(https?://[^\s|]+)" "$PAGE_MAP" || true)"
[[ -n "$CONF_URL" ]] \
  || die "'$REL_PATH' not found in $PAGE_MAP_RELATIVE (or no Confluence URL assigned)" 2

DISPLAY_NAME="$(grep -oP "^\|\s*\`${REL_PATH//./\\.}\`\s*\|\s*\K([^|]+?)(?=\s*\|)" "$PAGE_MAP" \
  | head -1 | xargs)"

PAGE_ID="$(echo "$CONF_URL" | grep -oP '(?<=/pages/)\d+')" \
  || die "could not parse page ID from: $CONF_URL"
BASE_URL="$(echo "$CONF_URL" | grep -oP 'https?://[^/]+')" \
  || die "could not parse base URL from: $CONF_URL"

AUTH="$(printf '%s:%s' "$CONFLUENCE_EMAIL" "$CONFLUENCE_API_TOKEN" | base64 -w 0)"

# ── State file helpers ────────────────────────────────────────────────────────

state_get_version() {
  if [[ -f "$STATE_FILE" ]]; then
    jq -r --arg key "$REL_PATH" '.[$key].version // empty' "$STATE_FILE" 2>/dev/null || true
  fi
}

state_set_version() {
  local ver="$1"
  local now tmp
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  tmp="$(mktemp)"
  if [[ -f "$STATE_FILE" ]]; then
    jq --arg key "$REL_PATH" --argjson ver "$ver" --arg at "$now" \
      '.[$key] = {version: $ver, at: $at}' "$STATE_FILE" > "$tmp"
  else
    jq -n --arg key "$REL_PATH" --argjson ver "$ver" --arg at "$now" \
      '{($key): {version: $ver, at: $at}}' > "$tmp"
  fi
  mv "$tmp" "$STATE_FILE"
}

# ── Comments helper ───────────────────────────────────────────────────────────

fetch_comments() {
  local comments_file="${MD_FILE%.md}.comments.md"
  echo "  Fetching    comments for page $PAGE_ID"

  HTTP_CODE="$(curl -s -o "$CURL_TMP" -w "%{http_code}" \
    -H "Authorization: Basic $AUTH" \
    -H "Accept: application/json" \
    "$BASE_URL/wiki/rest/api/content/$PAGE_ID/child/comment?expand=body.view,version,history&limit=100&depth=all")" \
    || die "GET comments for page $PAGE_ID failed" 3

  [[ "$HTTP_CODE" -ge 200 && "$HTTP_CODE" -lt 300 ]] \
    || die "GET comments returned HTTP $HTTP_CODE" 3

  local count
  count="$(jq -r '.size' "$CURL_TMP")"

  if [[ "$count" -eq 0 ]]; then
    echo "  Comments    none found"
    return
  fi

  echo "  Comments    $count found — writing to $(basename "$comments_file")"

  {
    echo "# Confluence Comments: $DISPLAY_NAME"
    echo ""
    echo "> Auto-generated by confluence_publish.sh — do not edit manually."
    echo "> Source: $CONF_URL"
    echo "> Fetched: $(date -u +"%Y-%m-%d %H:%M UTC")"
    echo ""

    jq -r '
      .results[] |
      "---\n\n**" + (.version.by.displayName // "Unknown") +
      "** · " + ((.version.when // "") | split("T")[0]) + "\n\n" +
      (.body.view.value // "")
    ' "$CURL_TMP" | python3 -c "
import sys, re

text = sys.stdin.read()
text = re.sub(r'<br\s*/?>', '\n', text)
text = re.sub(r'</?p[^>]*>', '\n', text)
text = re.sub(r'<strong[^>]*>(.*?)</strong>', r'**\1**', text, flags=re.DOTALL)
text = re.sub(r'<em[^>]*>(.*?)</em>', r'*\1*', text, flags=re.DOTALL)
text = re.sub(r'<code[^>]*>(.*?)</code>', r'\`\1\`', text, flags=re.DOTALL)
text = re.sub(r'<a[^>]+href=[\"\'](.*?)[\"\'][^>]*>(.*?)</a>', r'[\2](\1)', text, flags=re.DOTALL)
text = re.sub(r'<[^>]+>', '', text)
for ent, char in [('&amp;','&'),('&lt;','<'),('&gt;','>'),('&quot;','\"'),('&#39;',\"'\")]:
    text = text.replace(ent, char)
text = re.sub(r'\n{3,}', '\n\n', text)
print(text.strip())
"
  } > "$comments_file"

  echo "  Written     $comments_file"
}

# ── Fetch page info ───────────────────────────────────────────────────────────

echo "  Fetching    page $PAGE_ID ($DISPLAY_NAME)"

EXPAND="version"
[[ "$MODE" == "pull" ]] && EXPAND="version,body.storage"

HTTP_CODE="$(curl -s -o "$CURL_TMP" -w "%{http_code}" \
  -H "Authorization: Basic $AUTH" \
  -H "Accept: application/json" \
  "$BASE_URL/wiki/rest/api/content/$PAGE_ID?expand=$EXPAND")" \
  || die "GET $BASE_URL/wiki/rest/api/content/$PAGE_ID failed" 3

[[ "$HTTP_CODE" -ge 200 && "$HTTP_CODE" -lt 300 ]] \
  || die "GET $BASE_URL/wiki/rest/api/content/$PAGE_ID returned HTTP $HTTP_CODE" 3

PAGE_INFO="$(cat "$CURL_TMP")"

CURRENT_VERSION="$(echo "$PAGE_INFO" | jq -r '.version.number')"
TITLE="$(echo "$PAGE_INFO"           | jq -r '.title')"

echo "  Version     $CURRENT_VERSION — $TITLE"

# ── Pull mode ─────────────────────────────────────────────────────────────────

if [[ "$MODE" == "pull" ]]; then
  echo "  Converting  Confluence storage → markdown"

  STORAGE_BODY="$(echo "$PAGE_INFO" | jq -r '.body.storage.value')"

  MD_OUT="$(echo "$STORAGE_BODY" \
    | python3 "$SCRIPT_DIR/confluence_preproc.py" \
    | pandoc --from=html --to=commonmark --wrap=none)"

  cp "$MD_FILE" "${MD_FILE}.bak"
  echo "  Backed up   ${MD_FILE##*/} → ${MD_FILE##*/}.bak"

  printf '%s\n' "$MD_OUT" > "$MD_FILE"
  echo "  Written     $MD_FILE"

  state_set_version "$CURRENT_VERSION"
  echo "  State       recorded version $CURRENT_VERSION"

  $FETCH_COMMENTS && fetch_comments

  echo "  Done        pulled version $CURRENT_VERSION"
  exit 0
fi

# ── Comments-only mode (--comments without --pull) ────────────────────────────

if $FETCH_COMMENTS; then
  fetch_comments
  exit 0
fi

# ── Conflict detection ────────────────────────────────────────────────────────

LAST_PUBLISHED="$(state_get_version)"

if [[ -n "$LAST_PUBLISHED" && "$CURRENT_VERSION" -gt "$LAST_PUBLISHED" ]]; then
  echo "" >&2
  echo "  ⚠  Conflict detected!" >&2
  echo "     Confluence page is at version $CURRENT_VERSION;" >&2
  echo "     last recorded publish was version $LAST_PUBLISHED." >&2
  echo "     Someone may have edited the page directly on Confluence." >&2
  echo "     Run --pull to import those changes, or use --force to overwrite." >&2
  echo "" >&2
  $FORCE || exit 4
  echo "  --force     conflict check skipped" >&2
fi

# ── Convert markdown → Confluence storage HTML ───────────────────────────────

echo "  Converting  $REL_PATH"

export CONFLUENCE_PAGE_MAP="$PAGE_MAP"
export CONFLUENCE_SELF_URL="$CONF_URL"
export CONFLUENCE_DOCS_DIR="$DOCS_DIR"
export CONFLUENCE_FILE_PATH="$MD_FILE"
export PLANTUML_SERVER

HTML="$(pandoc \
  --from=markdown \
  --to=html5 \
  --wrap=none \
  --lua-filter="$SCRIPT_DIR/confluence_filter.lua" \
  "$MD_FILE")"

# ── Publish ───────────────────────────────────────────────────────────────────

NEXT_VERSION=$((CURRENT_VERSION + 1))
echo "  Publishing  version $NEXT_VERSION"

PAYLOAD="$(jq -n \
  --arg  title "$TITLE" \
  --arg  body  "$HTML"  \
  --argjson ver  "$NEXT_VERSION" \
  '{
    version: { number: $ver },
    title:   $title,
    type:    "page",
    body: {
      storage: {
        value:          $body,
        representation: "storage"
      }
    }
  }')"

HTTP_CODE="$(curl -s -o "$CURL_TMP" -w "%{http_code}" \
  -X PUT \
  -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "$PAYLOAD" \
  "$BASE_URL/wiki/rest/api/content/$PAGE_ID")" \
  || die "PUT $BASE_URL/wiki/rest/api/content/$PAGE_ID failed" 3

[[ "$HTTP_CODE" -ge 200 && "$HTTP_CODE" -lt 300 ]] \
  || die "PUT $BASE_URL/wiki/rest/api/content/$PAGE_ID returned HTTP $HTTP_CODE" 3

RESULT="$(cat "$CURL_TMP")"

state_set_version "$NEXT_VERSION"

WEB_PATH="$(echo "$RESULT" | jq -r '._links.webui // ""')"
echo "  Published   $BASE_URL$WEB_PATH"
