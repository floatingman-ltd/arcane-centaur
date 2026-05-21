# Guide: clojure-nrepl — Clojure nREPL + Conjure

## Quick start

```sh
# From your Clojure project directory:
clj -Sdeps '{:deps {nrepl/nrepl {:mvn/version "1.0.0"} cider/cider-nrepl {:mvn/version "0.30.0"}}}' \
    -M -m nrepl.cmdline \
    --middleware '["cider.nrepl/cider-middleware"]'
```

Conjure auto-connects when you open a `.clj` / `.cljc` / `.cljs` file
(detects the `.nrepl-port` file), or press `,cc` to connect manually.

---

## With Leiningen

```sh
# In your project.clj, add to :plugins:
#   [cider/cider-nrepl "0.30.0"]

lein repl
```

---

## Connect manually

Press `,cc` in a Clojure buffer, then enter:

- Host: `localhost`
- Port: shown in the nREPL startup output (usually `nrepl://localhost:<port>`)

---

> Full guide: `docs/modules/ROOT/pages/guides/lisp.adoc` or the Antora site.
