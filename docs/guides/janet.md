# Working with Janet

Janet is a lightweight, expressive Lisp dialect designed for scripting, system automation, and embedding. This configuration provides REPL-driven development via Conjure, structural editing, and LSP support.

| Plugin | Role |
|---|---|
| [Conjure](https://github.com/Olical/conjure) | Connect to a REPL and evaluate code without leaving the editor |
| [vim-sexp](https://github.com/guns/vim-sexp) + [mappings](https://github.com/tpope/vim-sexp-mappings-for-regular-people) | Structural editing — slurp, barf, and move S-expressions |
| [nvim-parinfer](https://github.com/gpanders/nvim-parinfer) | Keeps parentheses balanced automatically as you edit indentation |
| [rainbow-delimiters.nvim](https://github.com/HiPhish/rainbow-delimiters.nvim) | Color-codes matching delimiters so you can see nesting at a glance |

All four plugins lazy-load only when you open a **Janet** file (`.janet`).

[conform.nvim](https://github.com/stevearc/conform.nvim) is also loaded for Janet and provides **format-on-save** as well as a manual **`<leader>f`** keybinding (normal and visual mode) to reformat the current buffer or selection.

## Prerequisites

### Installing Janet

| Platform | Command |
|---|---|
| **macOS (Homebrew)** | `brew install janet` |
| **Ubuntu / Debian** | Build from source — see [janet-lang.org](https://janet-lang.org/) |
| **Arch Linux** | `sudo pacman -S janet` |
| **Windows** | Download from [janet-lang.org](https://janet-lang.org/) |

Verify the installation:

```sh
janet -v
```

### Installing jpm (Janet Package Manager)

`jpm` is required to install the LSP server and manage Janet projects. It is typically bundled with Janet installations. If it is not available, build it from source:

```sh
git clone https://github.com/janet-lang/jpm.git
cd jpm
janet bootstrap.janet
```

See [janet-lang/jpm](https://github.com/janet-lang/jpm) for full instructions.

## LSP

The `janet_lsp` server is configured in `lua/config/lsp.lua`. Install it via jpm:

```sh
jpm install janet-lsp
```

Make sure `janet-lsp` is on your `$PATH` (typically `~/.jpm/bin/`). See [readme.md](../../readme.md#lsp-support) for the shared LSP keybindings.

## Quick Start

1. **Open a Janet source file** — plugins load automatically:

   ```sh
   nvim hello.janet
   ```

2. **Evaluate code** using Conjure (local leader is `,`):

   Conjure spawns a Janet REPL process automatically when you first evaluate code in a `.janet` buffer — no manual server setup is needed.

   | Keys | Action |
   |---|---|
   | `,ee` | Evaluate the form under the cursor |
   | `,er` | Evaluate the root (outermost) form |
   | `,eb` | Evaluate the entire buffer |
   | `,e!` | Replace the form with its result |
   | `,lv` | Open the REPL log in a vertical split |
   | `,ls` | Open the REPL log in a horizontal split |
   | `,lq` | Close the REPL log window |

3. **Edit structure** with vim-sexp (normal mode):

   | Keys | Action |
   |---|---|
   | `>)` | **Slurp forward** — pull the next sibling into the form |
   | `<)` | **Barf forward** — push the last element out of the form |
   | `<(` | **Slurp backward** — pull the previous sibling into the form |
   | `>(` | **Barf backward** — push the first element out of the form |
   | `<f` | Move the current form left among its siblings |
   | `>f` | Move the current form right among its siblings |
   | `<e` | Move the current element left |
   | `>e` | Move the current element right |
   | `cse(` or `cse)` | Surround the element with `()` |
   | `cse[` or `cse]` | Surround the element with `[]` |
   | `dsf` | Delete surrounding function call (splice) |

4. **Parinfer** runs in the background — just adjust indentation and parens follow. No keys needed.

## Typical Workflow

```
 ┌──────────────────────────────────────────────┐
 │  Neovim                                      │
 │  ┌───────────────────┬──────────────────┐    │
 │  │  source.janet     │  Conjure log     │    │
 │  │                   │  (REPL output)   │    │
 │  │  (defn greet [n]  │  => "Hello!"     │    │
 │  │    (string "Hello │                  │    │
 │  │      " n "!"))    │                  │    │
 │  │                   │                  │    │
 │  │  ,ee to eval ─────┘                  │    │
 │  └───────────────────┴──────────────────┘    │
 └──────────────────────────────────────────────┘
```

1. Write or edit code in the left pane.
2. Press `,ee` to evaluate the expression under the cursor — the result appears in the Conjure log.
3. Use `,lv` to open the log in a vertical split if it isn't visible.
4. Use vim-sexp motions (`>)`, `<(`, etc.) to restructure S-expressions without counting parentheses.
5. Parinfer keeps parens balanced automatically as you change indentation.
6. Rainbow delimiters let you visually match nesting depth.

## Troubleshooting

### Conjure does not start the REPL

Make sure `janet` is on your `$PATH`:

```sh
which janet
```

If Janet is installed but Neovim cannot find it, check your shell `PATH` and ensure it is inherited by Neovim.

### LSP features not working

Verify `janet-lsp` is installed and accessible:

```sh
which janet-lsp
```

Use `:LspInfo` inside Neovim to check whether the server is attached. See `:LspLog` for error details.
