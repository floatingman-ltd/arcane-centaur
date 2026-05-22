# docker/antora

Docker wrapper for building the Antora documentation site. No Node.js or
global `antora` install required.

## First-use Docker pull

```sh
docker pull antora/antora
```

The image is pulled automatically on first use; subsequent runs use the cache.

## Local build

From the repo root:

```sh
./docker/antora/run.sh antora-playbook.yml
```

The generated site is written to `build/site/`. Open `build/site/index.html`
in a browser to preview locally.

## Usage in CI

The GitHub Actions workflow (`.github/workflows/docs.yml`) runs the same
command in the `antora/antora` container and deploys `build/site/` to the
`gh-pages` branch.

## Image

`antora/antora` — official Antora image. See https://hub.docker.com/r/antora/antora
