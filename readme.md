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
| **Neovim ≥ 0.9** | Editor | `sudo snap install nvim --classic` |
| **build-essential, tree** | General tooling | `sudo apt install build-essential tree -y` |
| **Lua ≥ 5.1** *(5.4 recommended)* | Required by lazy.nvim's LuaRocks support | `sudo apt install lua5.4` |
| **LuaRocks** | Plugin dependency manager used by lazy.nvim | `sudo apt install luarocks` |
| **A [Nerd Font][]** *(optional)* | File-type icons in the tree and fuzzy-finder | See below |

[Nerd Font]: https://www.nerdfonts.com/

Language-specific prerequisites (LSP servers, REPLs, runtimes) are documented in each language guide:
[Markdown](docs/guides/markdown.md) · [Diagrams](docs/guides/diagrams.md) · [Confluence](docs/guides/confluence.md) · [F#](docs/guides/fsharp.md) · [Haskell](docs/guides/haskell.md) · [Lisp / Clojure / Scheme](docs/guides/lisp.md) · [Presentations / MARP](docs/guides/presentations.md) · [REST Client](docs/guides/rest.md)

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

#### Windows Terminal (WSL)

[Windows Terminal](https://aka.ms/terminal) is fully supported when running
Neovim inside **WSL** (Windows Subsystem for Linux).  The config auto-detects
it via the `WT_SESSION` environment variable and enables Nerd Font icons and
undercurl automatically.

**Clipboard integration** — on WSL the config uses
[`win32yank.exe`](https://github.com/equalsraf/win32yank) for fast system
clipboard access.  Install it once on the **Windows** side:

```powershell
# From a Windows PowerShell / Terminal prompt:
scoop install win32yank      # or: choco install win32yank
```

The executable must be on your Windows `PATH` (which WSL inherits by default).
Verify with:

```sh
which win32yank.exe   # should print a /mnt/c/... path
```

**Nerd Font setup for Windows Terminal** — install a Nerd Font on Windows,
then select it in Windows Terminal settings:

1. Download *FiraCode Nerd Font* from
   <https://www.nerdfonts.com/font-downloads>.
2. Install it on **Windows** (right-click → *Install for all users*).
3. Open Windows Terminal → *Settings → Profiles → Defaults → Appearance →
   Font face* and select **FiraCode Nerd Font**.

> **Tip:** If `win32yank.exe` is not available, Neovim falls back to its
> built-in clipboard provider detection (`xclip`, `xsel`, etc.), which may be
> slower or require an X server.

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

1. Download *FiraCode Nerd Font* from
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
| **Windows Terminal** (WSL) | ✅ auto-enabled | ✅ native | Clipboard via `win32yank.exe`; see [Windows Terminal (WSL)](#windows-terminal-wsl) |
| **TTY Console** | ❌ fallback glyphs | ❌ → underline | Secondary — no graphical font support |
| **Alacritty** | ✅ auto-enabled | ✅ native | |
| **Other / unknown** | ❌ fallback glyphs | ❌ → underline | Override as above if your terminal supports Nerd Fonts |

Detection logic lives in `lua/config/terminal.lua`.  If the auto-detection is
wrong for your setup you can still force the flag in `lua/options.lua`:

```lua
vim.g.have_nerd_font = true   -- or false
```

## Working with Markdown

→ See **[docs/guides/markdown.md](docs/guides/markdown.md)** for the full guide: single-file browser preview, markserv Docker server for cross-page links, in-editor navigation, and PDF export.

- **`,p`** — toggle `markdown-preview.nvim` (single file with PlantUML/Mermaid)
- **`,sp`** — open in markserv Docker server — cross-page links and PlantUML/Mermaid diagrams rendered
- **`<CR>`** — follow a link to another `.md` file in the editor (mkdnflow.nvim)
- **`,cc`** — publish current file to Confluence (`MdToConfluence`)

## Working with Confluence

→ See **[docs/guides/confluence.md](docs/guides/confluence.md)** for the full guide: authentication, page map setup, diagram rendering, conflict detection, and troubleshooting.

| Keys | Action |
|---|---|
| `,cc` | Publish current file to Confluence (`MdToConfluence`) |
| `,cf` | Pull current Confluence page back to local file (`MdFromConfluence`) |
| `,ck` | Fetch Confluence page comments to sidecar file (`MdConfluenceComments`) |

## Working with Diagrams

→ See **[docs/guides/diagrams.md](docs/guides/diagrams.md)** for the full guide: PlantUML and Mermaid in Markdown, standalone `.puml` files, Docker server setup, keybindings, and **exporting to PDF**.

Mermaid fenced code blocks (`` ```mermaid `` … `` ``` ``) render natively in the browser preview — **no extra plugin required**. PlantUML rendering uses a local Docker server.

## Working with F#

→ See **[docs/guides/fsharp.md](docs/guides/fsharp.md)** for the full guide: iron.nvim REPL, fsautocomplete LSP, Quick Start, and Typical Workflow.

## Working with Haskell

→ See **[docs/guides/haskell.md](docs/guides/haskell.md)** for the full guide: haskell-tools.nvim, hls LSP, and GHCi REPL keybindings.

## Working with Lisp

→ See **[docs/guides/lisp.md](docs/guides/lisp.md)** for the full guide: Conjure, vim-sexp, parinfer, rainbow-delimiters, Quick Start, and Typical Workflow.

## Working with Presentations (MARP)

→ See **[docs/guides/presentations.md](docs/guides/presentations.md)** for the full guide: MARP live preview via Docker, export to PPTX / HTML / PDF, and keybindings.

## Working with Git

Git integration is provided by two complementary plugins:

* **vim-fugitive** — full git command interface (`:Git status`, `:Git commit`, `:Git log`, etc.)
* **gitsigns.nvim** — live gutter signs showing added / changed / removed lines, with hunk-level staging, resetting, and inline blame

### Quick keybindings

| Keys | Action |
|---|---|
| `<leader>gs` | Open git status window |
| `<leader>gb` | Blame current file |
| `<leader>gl` | Git log |
| `<leader>gd` | Diff unstaged changes |
| `<leader>gp` | Push |
| `]h` / `[h` | Jump to next / previous changed hunk |
| `<leader>hs` | Stage hunk under cursor |
| `<leader>hr` | Reset hunk under cursor |
| `<leader>hb` | Show full blame for current line |

→ See **[docs/cheatsheets/git.md](docs/cheatsheets/git.md)** for the complete reference.

> **Conflict note:** `<leader>hs` is also bound to *Hoogle search* in Haskell
> buffers (buffer-local, so it takes priority there). Use the fugitive status
> window to stage changes while editing Haskell files.

## Working with REST APIs (kulala.nvim)

→ See **[docs/guides/rest.md](docs/guides/rest.md)** for the full guide: writing `.http` files, environment variables, and typical workflow.

Write HTTP requests in `.http` files and run them directly from Neovim with the [kulala.nvim](https://github.com/mistweaverco/kulala.nvim) plugin.

> **Prerequisite:** the `tree-sitter` CLI must be on your `PATH`. kulala.nvim compiles a custom `kulala_http` grammar on first launch. Install it with `npm install -g tree-sitter-cli` (or `cargo install tree-sitter-cli`). See [docs/guides/rest.md](docs/guides/rest.md) for full install instructions.

| Keys | Action |
|---|---|
| `,r` | Run request under cursor |
| `,l` | Re-run last request |
| `,o` | Open result pane |
| `,e` | Select environment |

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

→ See **[docs/cheatsheets/index.md](docs/cheatsheets/index.md)** for the complete one-page keybinding reference.

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
| `<leader>t` | Normal | Toggle terminal split |
| `<leader>f` | Normal / Visual | Format buffer (or selection) |
| `<leader>gcs` | Normal / Visual | Copilot CLI: suggest (send to `gh copilot suggest`) |
| `<leader>gce` | Normal / Visual | Copilot CLI: explain (send to `gh copilot explain`) |
| `<leader>osn` | Normal | OpenSpec: create new change |
| `<leader>oss` | Normal | OpenSpec: show status |
| `<leader>osl` | Normal | OpenSpec: list all changes |

## Auto-Completion

Auto-completion is powered by [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) and draws from LSP, snippets, open buffers, file paths, and (when spell-checking is active) the spell dictionary.

### Triggering the menu

The completion menu opens automatically as you type.  To open it on demand in
insert mode, press **`Alt+Space`** (`<M-Space>`).

### Navigating the menu

Once the menu is open, use **`j`** and **`k`** to move through suggestions —
matching the standard Neovim screen-movement keys.  Both keys fall back to
inserting the literal character when the menu is not visible.

| Key | Action |
|---|---|
| `j` | Move to the next suggestion |
| `k` | Move to the previous suggestion |
| `Ctrl-f` | Scroll the documentation preview down |
| `Ctrl-b` | Scroll the documentation preview up |

### Selecting the highlighted entry

Press **`Enter`** (`<CR>`) to confirm and insert the currently highlighted
suggestion.  If nothing is highlighted, `Enter` inserts a newline as normal
(selection is never forced automatically).

### Cancelling the menu

Press **`Ctrl+e`** to dismiss the completion menu and return to normal typing.

## Supported Languages

| Language | Treesitter | LSP | REPL | Structural Editing | Guide |
|---|---|---|---|---|---|
| Clojure | ✅ | — | ✅ nREPL (Conjure) | ✅ vim-sexp + parinfer | [docs/guides/lisp.md](docs/guides/lisp.md) |
| Common Lisp | ✅ | ✅ cl_lsp | ✅ Swank (Conjure) | ✅ vim-sexp + parinfer | [docs/guides/lisp.md](docs/guides/lisp.md) |
| F# | ✅ | ✅ fsautocomplete | ✅ dotnet fsi (iron.nvim) | — | [docs/guides/fsharp.md](docs/guides/fsharp.md) |
| Fennel | — | — | ✅ (Conjure) | ✅ parinfer | [docs/guides/lisp.md](docs/guides/lisp.md) |
| Haskell | — | ✅ haskell-tools | ✅ GHCi | — | [docs/guides/haskell.md](docs/guides/haskell.md) |
| HTTP | ✅ | — | — | — | [docs/guides/rest.md](docs/guides/rest.md) |
| Lua | ✅ | — | — | — | — |
| Markdown | ✅ | ✅ marksman | — | — | [docs/guides/markdown.md](docs/guides/markdown.md) |
| Mermaid *(in Markdown)* | ✅ *(markdown)* | — | — | — | [docs/guides/diagrams.md](docs/guides/diagrams.md) |
| MARP (slides) | ✅ *(markdown)* | — | — | — | [docs/guides/presentations.md](docs/guides/presentations.md) |
| PlantUML | ✅ | — | — | — | [docs/guides/diagrams.md](docs/guides/diagrams.md) |
| Scheme | ✅ | — | ✅ built-in (Conjure) | ✅ vim-sexp + parinfer | [docs/guides/lisp.md](docs/guides/lisp.md) |

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
# Install the GitHub CLI (gh) — Ubuntu / WSL
sudo apt install gh

# Install the Copilot extension
gh extension install github/gh-copilot
```

### Usage

| Command | What it does |
|---|---|
| `gh copilot suggest "find files modified in last 7 days"` | Suggests a shell command; offers to run, copy, or revise it |
| `gh copilot explain "tar -xzf archive.tar.gz --strip-components=1"` | Explains what a command does in plain English |

### Using from inside Neovim

Use the built-in keymaps to drive Copilot CLI without leaving the editor:

| Keys | Action |
|---|---|
| `<leader>gcs` | Send current selection (or buffer) to `gh copilot suggest` |
| `<leader>gce` | Send current selection (or buffer) to `gh copilot explain` |

Results appear in a floating window. Close with `q` or `<Esc>`.

You can also press **`<leader>t`** to open the built-in terminal split and run `gh copilot` commands directly in the shell.

> **Prerequisites:** Install [GitHub CLI](https://cli.github.com/) and the Copilot extension:
> ```sh
> gh extension install github/gh-copilot
> ```

→ See **[docs/guides/ai-tools.md](docs/guides/ai-tools.md)** for the full guide including OpenSpec and Serena setup.

> **Serena MCP server prerequisites:** Node.js 18+ is required. Install Serena with:
> ```sh
> npm install -g @oramasearch/serena
> ```
> Or run it without a global install via `npx @oramasearch/serena`.

## Plugin Overview

Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim) and organized in `lua/plugins/`:

| File | Plugins | Cheatsheet |
|---|---|---|
| `colorscheme.lua` | TokyoNight theme (moon / storm / night / day variants) | — |
| `conform.lua` | Formatting (format-on-save + `<leader>f`) for Lisp and F# filetypes | [formatting.md](docs/cheatsheets/formatting.md) |
| `copilot.lua` | Copilot inline completions + Serena MCP server config | [copilot.md](docs/cheatsheets/copilot.md) · [ai-tools.md](docs/cheatsheets/ai-tools.md) |
| `dotnet.lua` | iron.nvim REPL integration for F# (`dotnet fsi`) and C# (`csharprepl`); roslyn.nvim C# LSP | [fsharp.md](docs/cheatsheets/fsharp.md) · [dotnet.md](docs/cheatsheets/dotnet.md) |
| `fzf-lua.lua` | Fuzzy finder | [fzf.md](docs/cheatsheets/fzf.md) |
| `git.lua` | vim-fugitive (`:Git` commands) + gitsigns.nvim (hunk signs & staging) | [git.md](docs/cheatsheets/git.md) |
| `haskell.lua` | haskell-tools.nvim (GHCi REPL + HLS integration) | [haskell.md](docs/cheatsheets/haskell.md) |
| `html.lua` | Bracey HTML live preview | [html.md](docs/cheatsheets/html.md) |
| `init.lua` | vim-repeat, vim-sensible, vim-surround, vim-unimpaired, vim-airline (statusline), lspconfig | [lsp.md](docs/cheatsheets/lsp.md) · [surround.md](docs/cheatsheets/surround.md) · [unimpaired.md](docs/cheatsheets/unimpaired.md) |
| `lisp.lua` | Conjure, vim-sexp, nvim-parinfer, rainbow-delimiters | [lisp.md](docs/cheatsheets/lisp.md) |
| `markdown.lua` | markdown-preview.nvim (browser preview, PlantUML via Docker server); `:MdToPdf` PDF export; `:MdToConfluence` / `:MdFromConfluence` / `:MdConfluenceComments` | [markdown.md](docs/cheatsheets/markdown.md) |
| `mkdnflow.lua` | mkdnflow.nvim (cross-page link navigation: `<CR>` follow, `<BS>` back) | [markdown.md](docs/cheatsheets/markdown.md) |
| `nvim-cmp.lua` | nvim-cmp + completion sources | [completion.md](docs/cheatsheets/completion.md) |
| `nvim-tree.lua` | File explorer tree | [file-tree.md](docs/cheatsheets/file-tree.md) |
| `plantuml.lua` | plantuml-syntax + `:PumlPreview` command (browser preview via Docker server) | [plantuml.md](docs/cheatsheets/plantuml.md) |
| `rest.lua` | kulala.nvim HTTP client (run requests from `.http` files) | [rest.md](docs/cheatsheets/rest.md) |
| `treesitter.lua` | nvim-treesitter | — |
| `vim-commentary.lua` | Toggle comments with `gcc` | [comments.md](docs/cheatsheets/comments.md) |

## Project Structure

```
init.lua                    # Entry point
lua/
  options.lua               # Editor options (tabs, search, UI)
  keymaps.lua               # Global keybindings
  loader/init.lua           # lazy.nvim bootstrap
  config/
    confluence.lua          # Confluence publish command (MdToConfluence)
    copilot_cli.lua         # CopilotSuggest / CopilotExplain commands (gh copilot)
    lsp.lua                 # LSP server setup (cl_lsp, fsautocomplete, marksman)
    marp.lua                # MARP presentation commands (preview + export)
    mdpdf.lua               # Markdown → PDF export command (MdToPdf)
    mdpreview.lua           # Markdown markserv server preview command (MdServerPreview)
    openspec.lua            # OpenspecNew / OpenspecStatus / OpenspecList commands
    terminal.lua            # Terminal detection & capability flags
    treesitter.lua          # (config managed in plugins/treesitter.lua)
    util.lua                # Shared helpers (open_url: cross-platform browser opener)
  plugins/
    colorscheme.lua         # TokyoNight theme (moon/storm/night/day)
    conform.lua             # Formatting for Lisp and F# filetypes
    copilot.lua             # Copilot inline completions + Serena MCP server config
    dotnet.lua              # F# + C# REPLs via iron.nvim; roslyn.nvim C# LSP
    fzf-lua.lua             # Fuzzy finder
    git.lua                 # Git (vim-fugitive + gitsigns.nvim)
    haskell.lua             # haskell-tools.nvim (GHCi REPL + HLS)
    html.lua                # Bracey HTML live preview
    init.lua                # Bare-string plugins (tpope, airline, lspconfig)
    lisp.lua                # Lisp ecosystem plugins
    markdown.lua            # markdown-preview.nvim (browser preview)
    mkdnflow.lua            # mkdnflow.nvim (cross-page link navigation)
    nvim-cmp.lua            # Completion engine + sources
    nvim-tree.lua           # File tree
    plantuml.lua            # plantuml-syntax + PumlPreview command
    rest.lua                # kulala.nvim HTTP client (run requests from .http files)
    treesitter.lua          # nvim-treesitter
    vim-commentary.lua      # Comment toggling
after/ftplugin/
  clojure.lua               # Clojure indent settings
  fsharp.lua                # F# indent settings (4-space) & localleader
  haskell.lua               # Haskell-tools keybindings
  http.lua                  # REST client localleader & keymaps
  lisp.lua                  # Lisp indent settings & lispwords
  markdown.lua              # Markdown localleader, preview keymap, MARP commands, MdToPdf, MdServerPreview, MdToConfluence
  plantuml.lua              # PlantUML localleader & PumlPreview keymap
  scheme.lua                # Scheme indent settings
docker/
  marp/                     # Docker Compose for MARP presentation server
  markserv/                 # Docker + Compose for markdown preview server (cross-page links, PlantUML/Mermaid diagrams)
  md2pdf/                   # Pandoc Lua filter for Markdown → PDF with PlantUML
  plantuml-server/          # Docker Compose for PlantUML render server
  sbcl-swank/               # Docker Compose for SBCL/Swank REPL
docs/
  cheatsheets/
    comments.md             # vim-commentary
    completion.md           # nvim-cmp
    copilot.md              # GitHub Copilot
    editing.md              # Visual-mode editing
    file-tree.md            # nvim-tree
    formatting.md           # conform.nvim
    fsharp.md               # iron.nvim / dotnet fsi
    fzf.md                  # fzf-lua fuzzy finder
    haskell.md              # haskell-tools REPL & HLS
    html.md                 # Bracey HTML live preview
    index.md              # Main keybinding reference (links to plugin sheets)
    lisp.md                 # Conjure + vim-sexp
    lsp.md                  # LSP keybindings
    markdown.md             # Markdown preview + MARP + markserv + Confluence
    navigation.md           # Window navigation & terminal
    plantuml.md             # PlantUML preview
    rest.md                 # REST client (kulala.nvim)
  guides/
    confluence.md           # Confluence publishing guide (MdToConfluence)
    diagrams.md             # Markdown + PlantUML diagram guide
    fsharp.md               # F# guide
    haskell.md              # Haskell guide
    lisp.md                 # Lisp / Clojure / Scheme / Fennel guide
    markdown.md             # Markdown preview guide (markserv, cross-page links)
    presentations.md        # MARP presentation guide
    rest.md                 # REST client guide (kulala.nvim, .http files)
```
