# Magical NeoVIM

Representing a NeoVIM installation that looks and feels like I'm in coding land.

## Installation

Clone this repo into your Neovim config directory:

```sh
git clone https://github.com/floatingman-ltd/arcane-centaur ~/.config/nvim
```

On first launch, [lazy.nvim](https://github.com/folke/lazy.nvim) will bootstrap itself and install all plugins automatically.

### Prerequisites

| Dependency | Purpose | Install hint |
|---|---|---|
| **Neovim ≥ 0.9** | Editor | `brew install neovim` / `sudo apt install neovim` |
| **build-essential, tree** | General tooling | `sudo apt install build-essential tree -y` |
| **cl_lsp** | Common Lisp LSP server | Install via Quicklisp or your CL package manager |
| **A Lisp REPL** | Conjure connects to a running REPL | SBCL, Clojure nREPL, or MIT Scheme (see below) |

## Working with Lisp

This configuration is built around an interactive, REPL-driven Lisp workflow. Four plugins work together to give you a seamless experience:

| Plugin | Role |
|---|---|
| [Conjure](https://github.com/Olical/conjure) | Connect to a REPL and evaluate code without leaving the editor |
| [vim-sexp](https://github.com/guns/vim-sexp) + [mappings](https://github.com/tpope/vim-sexp-mappings-for-regular-people) | Structural editing — slurp, barf, and move S-expressions |
| [nvim-parinfer](https://github.com/gpanders/nvim-parinfer) | Keeps parentheses balanced automatically as you edit indentation |
| [rainbow-delimiters.nvim](https://github.com/HiPhish/rainbow-delimiters.nvim) | Color-codes matching delimiters so you can see nesting at a glance |

All four plugins lazy-load only when you open a **Lisp**, **Clojure**, **Scheme**, or **Fennel** file.

[conform.nvim](https://github.com/stevearc/conform.nvim) is also loaded for these filetypes and provides **format-on-save** as well as a manual **`<leader>f`** keybinding (normal and visual mode) to reformat the current buffer or selection.

### Quick Start

1. **Start your REPL** in a terminal (Conjure connects to it):

   ```sh
   # Common Lisp (SBCL via Swank)
   sbcl --load ~/.quicklisp/setup.lisp --eval '(ql:quickload :swank)' --eval '(swank:create-server :dont-close t)'

   # Clojure (nREPL)
   clj -Sdeps '{:deps {nrepl/nrepl {:mvn/version "1.0.0"} cider/cider-nrepl {:mvn/version "0.30.0"}}}' -M -m nrepl.cmdline --middleware '["cider.nrepl/cider-middleware"]'

   # Scheme (MIT Scheme)
   mit-scheme   # Conjure connects via its built-in Scheme client
   ```

2. **Open a source file** in Neovim — plugins load automatically:

   ```sh
   nvim hello.lisp    # or hello.clj, hello.scm, hello.fnl
   ```

3. **Evaluate code** using Conjure (local leader is `,`):

   | Keys | Action |
   |---|---|
   | `,ee` | Evaluate the form under the cursor |
   | `,er` | Evaluate the root (outermost) form |
   | `,eb` | Evaluate the entire buffer |
   | `,e!` | Replace the form with its result |
   | `,lv` | Open the REPL log in a vertical split |
   | `,ls` | Open the REPL log in a horizontal split |
   | `,lq` | Close the REPL log window |

4. **Edit structure** with vim-sexp (normal mode):

   | Keys | Action |
   |---|---|
   | `>)` | Slurp forward — pull the next element into the current form |
   | `<)` | Barf forward — push the last element out of the current form |
   | `<(` | Slurp backward |
   | `>(` | Barf backward |
   | `<f` | Move the current form left among its siblings |
   | `>f` | Move the current form right among its siblings |
   | `<e` | Move the current element left |
   | `>e` | Move the current element right |
   | `cse(` or `cse)` | Surround the element with `()` |
   | `cse[` or `cse]` | Surround the element with `[]` |
   | `dsf` | Delete surrounding function call (splice) |

5. **Parinfer** runs in the background — just adjust indentation and parens follow. No keys needed.

6. **Stop the Swank server** when you are done (Common Lisp only):

   From within Neovim, evaluate the following with `,ee` (cursor on the form) or `,eb` (entire buffer):

   ```lisp
   (swank:stop-server 4005)
   ```

   Alternatively, switch to the terminal running SBCL and call the same form at the REPL prompt, or quit the process entirely:

   ```lisp
   (quit)
   ```

### Typical Workflow

```
 ┌──────────────────────────────────────────────┐
 │  Terminal A: REPL server (SBCL/nREPL/etc.)   │
 └──────────────────────────────────────────────┘
         ▲  Conjure connects automatically
         │
 ┌──────────────────────────────────────────────┐
 │  Neovim                                      │
 │  ┌───────────────────┬──────────────────┐    │
 │  │  source.lisp      │  Conjure log     │    │
 │  │                   │  (REPL output)   │    │
 │  │  (defun greet (n) │  => "Hello!"     │    │
 │  │    (format t      │                  │    │
 │  │      "Hello ~a" n)│                  │    │
 │  │  )                │                  │    │
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

## LSP Support

The Common Lisp LSP (`cl_lsp`) is configured in `lua/config/lsp.lua` with these keybindings (available in any LSP-enabled buffer):

| Keys | Action |
|---|---|
| `gd` | Go to definition |
| `K` | Hover documentation |
| `gr` | Find references |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>e` | Show diagnostic float |
| `[d` / `]d` | Previous / next diagnostic |

## General Keybindings

Leader key is **Space**.

| Keys | Mode | Action |
|---|---|---|
| `Ctrl-h/j/k/l` | Normal | Navigate between splits |
| `Ctrl-↑/↓/←/→` | Normal | Resize splits |
| `<` / `>` | Visual | Indent/outdent and reselect |
| `<leader>n` or `Ctrl-n` | Normal | Open file tree |
| `Ctrl-t` | Normal | Toggle file tree |
| `Ctrl-f` | Normal | Find current file in tree |
| `Ctrl-j` | Insert | Accept Copilot suggestion |
| `<leader>f` | Normal / Visual | Format buffer (or selection) |

## Supported Languages

| Language | Treesitter | LSP | REPL (Conjure) | Structural Editing |
|---|---|---|---|---|
| Common Lisp | ✅ | ✅ cl_lsp | ✅ Swank | ✅ vim-sexp + parinfer |
| Clojure | ✅ | — | ✅ nREPL | ✅ vim-sexp + parinfer |
| Scheme | ✅ | — | ✅ built-in | ✅ vim-sexp + parinfer |
| Fennel | — | — | ✅ | ✅ parinfer |
| Lua | ✅ | — | — | — |
| F# | ✅ | — | — | — |
| Haskell | — | ✅ haskell-tools | ✅ GHCi | — |

## Copilot Model Configuration

This config ships two Copilot plugins, each with its own model setting.

### Inline completions — `github/copilot.vim`

Edit `lua/plugins/init.lua` and change the `vim.g.copilot_model` value:

```lua
config = function()
  vim.g.copilot_model = "gpt-4o"   -- change to any supported model
end,
```

Common values: `"gpt-4o"`, `"gpt-4.1"`, `"claude-sonnet-4-5"`.

### Chat — `CopilotC-Nvim/CopilotChat.nvim`

Edit `lua/plugins/CopilotChat.lua` and change the `model` field inside `opts`:

```lua
opts = {
  model = 'claude-opus-4-5',   -- change to any supported model
  ...
}
```

Common values: `"gpt-4o"`, `"gpt-4.1"`, `"claude-opus-4-5"`, `"claude-sonnet-4-5"`.

You can also switch models interactively inside a chat buffer with the `/model` command.

## Plugin Overview

Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim) and organized in `lua/plugins/`:

| File | Plugins |
|---|---|
| `init.lua` | Copilot, vim-repeat, vim-sensible, vim-surround, vim-unimpaired, airline, treesitter, lspconfig, nvim-cmp |
| `lisp.lua` | Conjure, vim-sexp, nvim-parinfer, rainbow-delimiters |
| `CopilotChat.lua` | Copilot Chat integration |
| `fzf-lua.lua` | Fuzzy finder |
| `nvim-tree.lua` | File explorer tree |
| `vim-commentary.lua` | Toggle comments with `gcc` |
| `conform.lua` | Formatting (format-on-save + `<leader>f`) for Lisp filetypes |

## Project Structure

```
init.lua                    # Entry point
lua/
  options.lua               # Editor options (tabs, search, UI)
  keymaps.lua               # Global keybindings
  loader/init.lua           # lazy.nvim bootstrap
  config/
    lsp.lua                 # LSP server setup (cl_lsp)
    treesitter.lua          # (config managed in plugins/init.lua)
  plugins/
    init.lua                # Core plugins
    lisp.lua                # Lisp ecosystem plugins
    CopilotChat.lua         # AI chat
    fzf-lua.lua             # Fuzzy finder
    nvim-tree.lua           # File tree
    vim-commentary.lua      # Comment toggling
    conform.lua             # Formatting for Lisp filetypes
after/ftplugin/
  lisp.lua                  # Lisp indent settings & lispwords
  clojure.lua               # Clojure indent settings
  scheme.lua                # Scheme indent settings
  haskell.lua               # Haskell-tools keybindings
```
