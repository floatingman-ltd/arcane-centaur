# Working with Haskell

Haskell support is provided by [haskell-tools.nvim](https://github.com/mrcjkb/haskell-tools.nvim), which bundles LSP integration, a GHCi REPL, and Hoogle search into a single plugin.

All Haskell plugins lazy-load only when you open a `.hs` or `.lhs` file.

## Prerequisites

| Dependency | Purpose | Install hint |
|---|---|---|
| **GHC + cabal / stack** | Haskell compiler and build tools | [ghcup](https://www.haskell.org/ghcup/) |
| **haskell-language-server** | LSP server | `ghcup install hls` |

## LSP

`haskell-tools` manages the `hls` LSP connection automatically — no manual `lspconfig` setup is needed. See [readme.md](../../readme.md#lsp-support) for the shared LSP keybindings (`gd`, `K`, `gr`, etc.).

## REPL (GHCi)

haskell-tools provides a built-in GHCi REPL. Keybindings are defined in `after/ftplugin/haskell.lua`.

| Keys | Action |
|---|---|
| `,rr` | Toggle GHCi REPL for the current package |
| `,rf` | Toggle GHCi REPL for the current file |
| `,rq` | Quit the REPL |
| `,rl` | Reload the REPL |

## Configuration

Plugin spec lives in `lua/plugins/` and ftplugin overrides live in `after/ftplugin/haskell.lua`.
