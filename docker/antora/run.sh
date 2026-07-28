#!/usr/bin/env bash
# Antora site builder wrapper. Runs antora/antora via Docker; no global
# Node.js or antora install required.
set -euo pipefail

# --user maps the container process to the invoking host user, so the
# generated site under build/ is owned by you rather than root. Without it
# the output is root-owned and `rm -rf build/` fails without sudo.
exec docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd)":/antora \
  antora/antora "$@"
