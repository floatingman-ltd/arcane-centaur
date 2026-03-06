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
| **PlantUML Docker server** *(diagrams)* | Render PlantUML diagrams | `docker run -d -p 8080:8080 plantuml/plantuml-server` |
| **Node.js / npm** *(diagrams)* | Build step for markdown-preview.nvim | `sudo apt install nodejs npm` |
| **marksman** *(optional, diagrams)* | Markdown LSP | `sudo apt install marksman` |
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

## Working with Diagrams

→ See **[docs/diagrams.md](docs/diagrams.md)** for the full guide: PlantUML in Markdown, standalone `.puml` files, Docker server setup, and keybindings.

## Working with Lisp

→ See **[docs/lisp.md](docs/lisp.md)** for the full guide: Conjure, vim-sexp, parinfer, rainbow-delimiters, Quick Start, and Typical Workflow.

## Working with F#

→ See **[docs/fsharp.md](docs/fsharp.md)** for the full guide: iron.nvim REPL, fsautocomplete LSP, Quick Start, and Typical Workflow.

## Working with Haskell

→ See **[docs/haskell.md](docs/haskell.md)** for the full guide: haskell-tools.nvim, hls LSP, and GHCi REPL keybindings.

## LSP Support

LSP servers are configured in `lua/config/lsp.lua`. See each language's doc for server-specific setup. All servers share these keybindings (available in any LSP-enabled buffer):

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

| Language | Treesitter | LSP | REPL | Structural Editing | Guide |
|---|---|---|---|---|---|
| Common Lisp | ✅ | ✅ cl_lsp | ✅ Swank (Conjure) | ✅ vim-sexp + parinfer | [docs/lisp.md](docs/lisp.md) |
| Clojure | ✅ | — | ✅ nREPL (Conjure) | ✅ vim-sexp + parinfer | [docs/lisp.md](docs/lisp.md) |
| Scheme | ✅ | — | ✅ built-in (Conjure) | ✅ vim-sexp + parinfer | [docs/lisp.md](docs/lisp.md) |
| Fennel | — | — | ✅ (Conjure) | ✅ parinfer | [docs/lisp.md](docs/lisp.md) |
| Lua | ✅ | — | — | — | — |
| F# | ✅ | ✅ fsautocomplete | ✅ dotnet fsi (iron.nvim) | — | [docs/fsharp.md](docs/fsharp.md) |
| Haskell | — | ✅ haskell-tools | ✅ GHCi | — | [docs/haskell.md](docs/haskell.md) |
| Markdown | ✅ | ✅ marksman | — | — | [docs/diagrams.md](docs/diagrams.md) |
| PlantUML | ✅ | — | — | — | [docs/diagrams.md](docs/diagrams.md) |

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
| `colorscheme.lua` | TokyoNight theme (moon / storm / night / day variants) |
| `conform.lua` | Formatting (format-on-save + `<leader>f`) for Lisp and F# filetypes |
| `markdown.lua` | markdown-preview.nvim (browser preview, PlantUML via Docker server) |
| `plantuml.lua` | plantuml-syntax + `:PumlPreview` command (browser preview via Docker server) |

## Project Structure

```
init.lua                    # Entry point
lua/
  options.lua               # Editor options (tabs, search, UI)
  keymaps.lua               # Global keybindings
  loader/init.lua           # lazy.nvim bootstrap
  config/
    lsp.lua                 # LSP server setup (cl_lsp, fsautocomplete, marksman)
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
    colorscheme.lua         # TokyoNight theme (moon/storm/night/day)
    conform.lua             # Formatting for Lisp and F# filetypes
    markdown.lua            # markdown-preview.nvim (browser preview)
    plantuml.lua            # plantuml-syntax + PumlPreview command
after/ftplugin/
  lisp.lua                  # Lisp indent settings & lispwords
  clojure.lua               # Clojure indent settings
  scheme.lua                # Scheme indent settings
  fsharp.lua                # F# indent settings (4-space) & localleader
  haskell.lua               # Haskell-tools keybindings
  markdown.lua              # Markdown localleader & preview keymap
  plantuml.lua              # PlantUML localleader & PumlPreview keymap
docker/
  plantuml-server/          # Docker Compose for PlantUML render server
  sbcl-swank/               # Docker Compose for SBCL/Swank REPL
docs/
  lisp.md                   # Lisp / Clojure / Scheme / Fennel guide
  fsharp.md                 # F# guide
  haskell.md                # Haskell guide
  diagrams.md               # Markdown + PlantUML diagram guide
```
