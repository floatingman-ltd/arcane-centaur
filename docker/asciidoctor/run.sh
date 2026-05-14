#!/usr/bin/env bash
# Wrapper for asciidoctor/docker-asciidoctor.
# Mounts the current working directory as /documents inside the container.
# All arguments are forwarded directly to the asciidoctor CLI.
#
# Usage:
#   ./run.sh myfile.adoc -o output.html
#   ./run.sh --version

set -euo pipefail

if ! command -v docker &>/dev/null; then
  echo "ERROR: docker not found. Install Docker to use asciidoctor." >&2
  exit 1
fi

if ! docker info &>/dev/null; then
  echo "ERROR: Docker daemon is not running. Start Docker and try again." >&2
  exit 1
fi

exec docker run --rm \
  -v "$(pwd)":/documents \
  -v /tmp:/tmp \
  asciidoctor/docker-asciidoctor \
  asciidoctor "$@"
