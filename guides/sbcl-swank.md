# Guide: sbcl-swank — Common Lisp Docker REPL

## Quick start

```sh
# 1. Build the image (once, and after pulling config updates)
docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml build

# 2. Start Swank server (blocks until healthy — Conjure can connect immediately)
LISP_DIR=$PWD docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml up -d --build --wait

# 3. Stop when done
LISP_DIR=$PWD docker compose -f ~/.config/nvim/docker/sbcl-swank/docker-compose.yml down
```

Swank listens on **localhost:4005**. Conjure auto-connects when you open
a `.lisp` file, or press `,cc` to connect manually.

---

## What `LISP_DIR` does

The container mounts `LISP_DIR` as `/lisp` inside the container.
Set it to your project root so your files are accessible to SBCL:

```sh
LISP_DIR=~/projects/my-lisp-project docker compose ... up -d --build --wait
```

If omitted, it defaults to `$PWD`.

---

## Alternative: local SBCL (no Docker)

```sh
sbcl --load ~/.quicklisp/setup.lisp \
     --eval '(ql:quickload :swank)' \
     --eval '(ignore-errors (setf swank::*use-dedicated-output-stream* nil))' \
     --eval '(swank:create-server :dont-close t :style :spawn)'
```

Then `,cc` → `localhost` → `4005`.

---

> Full guide: `docs/modules/ROOT/pages/guides/lisp.adoc` or the Antora site.
