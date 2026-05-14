#!/usr/bin/env bash
# Convert all docs/*.md and readme.md to AsciiDoc counterparts.
#
# Sentinel header injected into every auto-generated .adoc:
#   // :auto-generated: true
#   // :source: <relative-path-to-source.md>
#   // Remove this header to take manual ownership of this file
#
# Files whose .adoc counterpart already exists WITHOUT the sentinel are skipped
# (the file has been manually graduated to AsciiDoc).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PANDOC="${REPO_ROOT}/docker/pandoc/run.sh"

if [[ ! -x "$PANDOC" ]]; then
  echo "ERROR: $PANDOC not found or not executable" >&2
  exit 1
fi

convert_file() {
  local src="$1"          # relative path from repo root, e.g. docs/guides/lisp.md
  local dst="${src%.md}.adoc"

  # Skip if .adoc exists and has no sentinel (manually owned)
  if [[ -f "${REPO_ROOT}/${dst}" ]]; then
    if ! grep -q '^// :auto-generated: true' "${REPO_ROOT}/${dst}" 2>/dev/null; then
      echo "  SKIP (manual): $dst"
      return
    fi
  fi

  echo "  CONVERT: $src -> $dst"

  local tmp
  tmp="$(mktemp)"

  # Inject sentinel header then pandoc output.
  # Run from REPO_ROOT so Docker's -v "$(pwd)":/data maps to the repo root
  # and we can pass the relative src path into the container.
  {
    echo "// :auto-generated: true"
    echo "// :source: $src"
    echo "// Remove this header to take manual ownership of this file"
    echo ""
    (cd "$REPO_ROOT" && "$PANDOC" -f markdown -t asciidoc "$src")
  } > "$tmp"

  mv "$tmp" "${REPO_ROOT}/${dst}"
}

echo "==> Converting docs/**/*.md ..."
while IFS= read -r -d '' f; do
  rel="${f#${REPO_ROOT}/}"
  convert_file "$rel"
done < <(find "${REPO_ROOT}/docs" -name "*.md" -print0 | sort -z)

echo "==> Converting readme.md ..."
convert_file "readme.md"

echo "==> Done."
