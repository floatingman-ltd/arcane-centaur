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
| **.NET SDK ≥ 6** | F# compiler and `dotnet fsi` REPL | <https://dotnet.microsoft.com/download> |
| **fsautocomplete** | F# LSP server | `dotnet tool install -g fsautocomplete` |
| **A [Nerd Font][]** *(optional)* | File-type icons in the tree and fuzzy-finder | See below |

[Nerd Font]: https://www.nerdfonts.com/

### Recommended Terminal — GNOME Terminal

[GNOME Terminal](https://help.gnome.org/users/gnome-terminal/stable/) is the
default terminal emulator for this configuration.  It ships with most GNOME-based
Linux distributions and is powered by the VTE library.  Key features:

* **Nerd Font support** — icons render correctly once a Nerd Font is installed
  and selected as the profile font (*Preferences → Profiles → Custom font*).
* **True-colour support** — 24-bit RGB colour is supported natively.
* **System integration** — tightly integrated with the GNOME desktop
  environment, no additional installation required on Ubuntu/Fedora/Debian.

GNOME Terminal does **not** auto-detect Nerd Font usage (see [Terminal
Auto-Detection](#terminal-auto-detection) below).  After installing a Nerd
Font, set the override in `lua/options.lua`:

```lua
vim.g.have_nerd_font = true
```

#### Installing GNOME Terminal

GNOME Terminal is pre-installed on most GNOME-based distributions.  If it is
not present:

| Platform | Command |
|---|---|
| **Ubuntu / Debian** | `sudo apt install gnome-terminal` |
| **Fedora** | `sudo dnf install gnome-terminal` |
| **Arch Linux** | `sudo pacman -S gnome-terminal` |

#### Secondary Terminal — TTY Console

The Linux TTY console (accessed with **Ctrl+Alt+F2** through **F6**) is
supported as a secondary terminal.  It is useful in minimal or headless
environments where no graphical display is available.

Keep in mind that the TTY console does not support Nerd Font glyphs or
24-bit colour, so icon-based plugins fall back to plain Unicode glyphs
automatically.  Undercurl is rendered as a plain underline.

> **Other terminals that work well:** [Alacritty](https://alacritty.org/)
> also has full Nerd Font and undercurl support.  The Neovim config
> auto-detects it and enables the appropriate features.

#### Nerd Font Setup

`nvim-tree` and `fzf-lua` can display file-type icons when a patched
[Nerd Font](https://www.nerdfonts.com/) is installed **and** selected as the
terminal font.  Without one the config automatically falls back to plain
Unicode glyphs, so icons are entirely optional.

To install a Nerd Font:

1. Download a Nerd Font (e.g. *JetBrainsMono Nerd Font*) from
   <https://www.nerdfonts.com/font-downloads>.
2. Install it system-wide or for the current user.
3. Select it in your terminal emulator (GNOME Terminal: *Preferences → Profiles → Custom font*,
   or see your terminal's documentation).

#### Terminal Auto-Detection

The configuration automatically detects which terminal emulator is running
(via `$TERM_PROGRAM`, `$VTE_VERSION`, and related environment variables) and
adjusts its behaviour:

| Terminal | Nerd Font icons | Undercurl | Notes |
|---|---|---|---|
| **GNOME Terminal** (VTE) | ❌ fallback glyphs | ❌ → underline | **Default** — set `vim.g.have_nerd_font = true` in `lua/options.lua` after installing a Nerd Font |
| **TTY Console** | ❌ fallback glyphs | ❌ → underline | Secondary — no graphical font support |
| **Alacritty** | ✅ auto-enabled | ✅ native | |
| **Other / unknown** | ❌ fallback glyphs | ❌ → underline | Override as above if your terminal supports Nerd Fonts |

Detection logic lives in `lua/config/terminal.lua`.  If the auto-detection is
wrong for your setup you can still force the flag in `lua/options.lua`:

```lua
vim.g.have_nerd_font = true   -- or false
```

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

Two LSP servers are configured in `lua/config/lsp.lua`. Both share the same keybindings (available in any LSP-enabled buffer):

| Server | Language | Notes |
|---|---|---|
| `cl_lsp` | Common Lisp | Install via Quicklisp |
| `fsautocomplete` | F# | `dotnet tool install -g fsautocomplete` |

Keybindings:

| Keys | Action |
|---|---|
| `gd` | Go to definition |
| `K` | Hover documentation |
| `gr` | Find references |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>e` | Show diagnostic float |
| `[d` / `]d` | Previous / next diagnostic |

## Working with F#

F# support uses [iron.nvim](https://github.com/Vigemus/iron.nvim) for REPL interaction and `fsautocomplete` for LSP-powered completions, go-to-definition, hover docs, and formatting.

All F# plugins lazy-load only when you open a `.fs`, `.fsx`, or `.fsi` file.

### Quick Start

1. **Ensure prerequisites are installed:**

   ```sh
   # .NET SDK (includes dotnet fsi)
   dotnet --version

   # F# language server
   dotnet tool install -g fsautocomplete
   ```

2. **Open a source file** — plugins and LSP attach automatically:

   ```sh
   nvim hello.fs
   ```

3. **Start the REPL** and send code (local leader is `,`):

   | Keys | Action |
   |---|---|
   | `,sl` | Send current line to `dotnet fsi` |
   | `,sc` | Send motion / visual selection |
   | `,sp` | Send paragraph |
   | `,sf` | Send entire file |
   | `,si` | Interrupt the REPL |
   | `,sq` | Quit the REPL |
   | `,cl` | Clear the REPL buffer |

   The REPL opens as a horizontal split at the bottom of the window (40% height).

4. **LSP features** work the same as for Common Lisp — `gd`, `K`, `gr`, `<leader>rn`, `<leader>ca`, `<leader>e`, `[d`/`]d`.

5. **Format on save** is enabled via `conform.nvim` using the fsautocomplete formatter.
   You can also trigger it manually with `<leader>f`.

### Typical Workflow

```
 ┌──────────────────────────────────────────────────────┐
 │  Neovim                                              │
 │  ┌─────────────────────────┬────────────────────┐   │
 │  │  hello.fs               │  dotnet fsi REPL   │   │
 │  │                         │                    │   │
 │  │  let greet name =       │  > val greet :     │   │
 │  │    printfn "Hi %s" name │    string -> unit  │   │
 │  │                         │  > Hi Walt         │   │
 │  │  ,sl to send line ──────┘                    │   │
 │  └─────────────────────────┴────────────────────┘   │
 └──────────────────────────────────────────────────────┘
```

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
| `Ctrl-j` | Insert | Accept full Copilot suggestion |
| `Alt-f` | Insert | Accept next word of Copilot suggestion |
| `<leader>c` | Normal | Focus CopilotChat window |
| `<leader>t` | Normal | Toggle terminal split |
| `<leader>f` | Normal / Visual | Format buffer (or selection) |

## Supported Languages

| Language | Treesitter | LSP | REPL (Conjure) | Structural Editing |
|---|---|---|---|---|
| Common Lisp | ✅ | ✅ cl_lsp | ✅ Swank (Conjure) | ✅ vim-sexp + parinfer |
| Clojure | ✅ | — | ✅ nREPL (Conjure) | ✅ vim-sexp + parinfer |
| Scheme | ✅ | — | ✅ built-in (Conjure) | ✅ vim-sexp + parinfer |
| Fennel | — | — | ✅ (Conjure) | ✅ parinfer |
| Lua | ✅ | — | — | — |
| F# | ✅ | ✅ fsautocomplete | ✅ dotnet fsi (iron.nvim) | — |
| Haskell | — | ✅ haskell-tools | ✅ GHCi | — |

## Copilot Model Configuration

Edit `lua/plugins/copilot.lua` and uncomment the desired `vim.g.copilot_model` line:

```lua
config = function()
  vim.g.copilot_model = "claude-sonnet-4-5"   -- active
  -- vim.g.copilot_model = "gpt-4o"
  -- vim.g.copilot_model = "gpt-4.1"
  -- vim.g.copilot_model = "claude-opus-4-5"
end,
```

Common values: `"gpt-4o"`, `"gpt-4.1"`, `"claude-sonnet-4-5"`.

## GitHub Copilot CLI

[`gh copilot`](https://github.com/github/gh-extension-copilot) is a separate CLI tool that brings Copilot assistance to your shell, complementing the in-editor plugins.

### Installation

```sh
# Requires the GitHub CLI (gh)
brew install gh          # or: sudo apt install gh

# Install the Copilot extension
gh extension install github/gh-copilot
```

### Usage

| Command | What it does |
|---|---|
| `gh copilot suggest "find files modified in last 7 days"` | Suggests a shell command; offers to run, copy, or revise it |
| `gh copilot explain "tar -xzf archive.tar.gz --strip-components=1"` | Explains what a command does in plain English |

### Using from inside Neovim

Press **`<leader>t`** to open the built-in terminal split, then run `gh copilot` commands directly in the shell:

```sh
gh copilot suggest "recursively delete all .DS_Store files"
```

Press **`Esc`** to leave terminal insert mode, then `<C-k>` to jump back to your editor window.

> **Tip:** `gh copilot` focuses on shell/CLI tasks. Use **CopilotChat** (`:CopilotChat`) for code-aware questions with buffer context.

## Plugin Overview

Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim) and organized in `lua/plugins/`:

| File | Plugins |
|---|---|
| `init.lua` | vim-repeat, vim-sensible, vim-surround, vim-unimpaired, airline, lspconfig |
| `copilot.lua` | Copilot inline completions |
| `treesitter.lua` | nvim-treesitter |
| `nvim-cmp.lua` | nvim-cmp + completion sources |
| `lisp.lua` | Conjure, vim-sexp, nvim-parinfer, rainbow-delimiters |
| `fzf-lua.lua` | Fuzzy finder |
| `nvim-tree.lua` | File explorer tree |
| `vim-commentary.lua` | Toggle comments with `gcc` |
| `fsharp.lua` | iron.nvim REPL integration for F# (`dotnet fsi`) |
| `conform.lua` | Formatting (format-on-save + `<leader>f`) for Lisp and F# filetypes |

## Project Structure

```
init.lua                    # Entry point
lua/
  options.lua               # Editor options (tabs, search, UI)
  keymaps.lua               # Global keybindings
  loader/init.lua           # lazy.nvim bootstrap
  config/
    lsp.lua                 # LSP server setup (cl_lsp, fsautocomplete)
    terminal.lua            # Terminal detection & capability flags
    treesitter.lua          # (config managed in plugins/treesitter.lua)
  plugins/
    init.lua                # Bare-string plugins (tpope, airline, lspconfig)
    copilot.lua             # Copilot inline completions + model setting
    treesitter.lua          # nvim-treesitter
    nvim-cmp.lua            # Completion engine + sources
    lisp.lua                # Lisp ecosystem plugins
    fsharp.lua              # F# REPL via iron.nvim (dotnet fsi)
    fzf-lua.lua             # Fuzzy finder
    nvim-tree.lua           # File tree
    vim-commentary.lua      # Comment toggling
    conform.lua             # Formatting for Lisp and F# filetypes
after/ftplugin/
  lisp.lua                  # Lisp indent settings & lispwords
  clojure.lua               # Clojure indent settings
  scheme.lua                # Scheme indent settings
  fsharp.lua                # F# indent settings (4-space) & localleader
  haskell.lua               # Haskell-tools keybindings
```
