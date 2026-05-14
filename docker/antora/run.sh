#!/usr/bin/env bash
# Antora site builder wrapper. Runs antora/antora via Docker; no global
# Node.js or antora install required.
set -euo pipefail

exec docker run --rm \
  -v "$(pwd)":/antora \
  antora/antora "$@"
