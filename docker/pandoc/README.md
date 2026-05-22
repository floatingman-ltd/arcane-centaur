# docker/pandoc

Native-first `pandoc` wrapper used by the docs conversion scripts.

## Strategy

1. If `pandoc` is installed locally it is used directly (fastest, no Docker overhead).
2. If `pandoc` is not found, `docker run --rm pandoc/minimal` is used as a transparent fallback.

## First-use Docker pull

The first time Docker fallback runs, Docker will pull the image automatically:

```sh
docker pull pandoc/minimal
```

Subsequent runs use the cached image.

## Usage

```sh
# Convert a Markdown file to AsciiDoc
./docker/pandoc/run.sh -f markdown -t asciidoc input.md -o output.adoc

# Used internally by scripts/convert-docs.sh
./scripts/convert-docs.sh
```

## Image

`pandoc/minimal` — official minimal Pandoc image (~30 MB). Supports all standard
input/output formats. See https://hub.docker.com/r/pandoc/minimal
