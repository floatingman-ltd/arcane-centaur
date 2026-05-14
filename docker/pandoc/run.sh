#!/usr/bin/env bash
# Native-first pandoc wrapper. Uses system pandoc if available; falls back to
# docker run pandoc/minimal so callers need not install pandoc globally.
set -euo pipefail

if command -v pandoc &>/dev/null; then
  exec pandoc "$@"
fi

exec docker run --rm \
  -v "$(pwd)":/data \
  pandoc/minimal "$@"
