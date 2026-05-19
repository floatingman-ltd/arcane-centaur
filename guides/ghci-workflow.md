# Guide: ghci-workflow — GHCi via haskell-tools

## Quick start

```
<leader>rr    Toggle GHCi REPL for the current package
<leader>rf    Toggle GHCi REPL for the current file only
<leader>rq    Quit the REPL
```

haskell-tools manages the GHCi session. Open any `.hs` file and press
`<leader>rr` — GHCi starts automatically using the project's cabal/stack
configuration.

---

## Code lens & search

```
Space-cl    Run code lenses (type hints, suggested actions)
Space-hs    Hoogle search for the type under the cursor
Space-ea    Evaluate all code snippets in the buffer
```

---

## Verify GHCi is available

```sh
ghci --version
# e.g. GHCi, version 9.x.x
```

Install via GHCup if missing:

```sh
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
```

---

> Full guide: `docs/modules/ROOT/pages/guides/haskell.adoc` or the Antora site.
