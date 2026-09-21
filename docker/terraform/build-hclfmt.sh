#!/usr/bin/env bash
# Build `hclfmt` and install it to ~/.local/bin.
#
# hclfmt formats the `hcl` filetype, which is distinct from `terraform` --
# `terraform fmt` does not parse generic HCL. conform bundles a definition for
# it but not the binary, and hashicorp/hcl publishes no prebuilt releases, so it
# has to be compiled.
#
# The compiler runs in a container; the result does not. That is the repository
# rule rather than an exception to it: a formatter the editor spawns on every
# write is editor machinery and belongs on the host, alongside stylua and
# terraform-ls. Containerising the *toolchain* avoids installing Go to build a
# single static binary.
set -euo pipefail

VERSION="${1:-latest}"
DEST="${DEST:-$HOME/.local/bin}"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

docker run --rm -v "$WORK:/out" \
  -e CGO_ENABLED=0 \
  golang:1.25-alpine \
  sh -c "go install github.com/hashicorp/hcl/v2/cmd/hclfmt@${VERSION} && cp /go/bin/hclfmt /out/hclfmt"

mkdir -p "$DEST"
install -m 755 "$WORK/hclfmt" "$DEST/hclfmt"
echo "installed $DEST/hclfmt"
