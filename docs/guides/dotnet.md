# .NET / C# Guide

Full C# editing support: syntax highlighting, LSP (Roslyn), formatting (CSharpier), and an interactive REPL (csharprepl via iron.nvim). F# support is unchanged — see [docs/guides/fsharp.md](fsharp.md).

---

## Prerequisites

Install the following .NET global tools:

```sh
dotnet tool install -g csharpier    # Formatter
dotnet tool install -g csharprepl   # Interactive REPL
```

### Neovim Version Requirement

> **roslyn.nvim requires Neovim ≥ 0.12.** Run `nvim --version` to check. If you are on an older version, see [Upgrading Neovim](#upgrading-neovim) below before proceeding.

### Installing the Roslyn Language Server

The Roslyn LSP is the official Microsoft C# language server used in VS Code's C# Dev Kit. It is **not** installed via `dotnet tool install`; download the native binary for your platform from the NuGet feed.

**Linux / WSL2 (x64):**

```sh
# 1. Create an install directory
mkdir -p ~/.local/share/roslyn

# 2. Download the latest linux-x64 package.
#    Find the current version at:
#    https://www.nuget.org/packages/Microsoft.CodeAnalysis.LanguageServer.linux-x64
VERSION="5.0.0-1.25277.114"   # replace with the latest shown on the NuGet page
curl -L "https://api.nuget.org/v3-flatcontainer/microsoft.codeanalysis.languageserver.linux-x64/${VERSION}/microsoft.codeanalysis.languageserver.linux-x64.${VERSION}.nupkg" \
     -o /tmp/roslyn.nupkg

# 3. Extract into the install directory and make executable
unzip -o /tmp/roslyn.nupkg -d ~/.local/share/roslyn
chmod +x ~/.local/share/roslyn/content/LanguageServer/linux-x64/Microsoft.CodeAnalysis.LanguageServer

# 4. Add to PATH (~/.bashrc for bash, ~/.zshrc for zsh — reload after)
echo 'export PATH="$HOME/.local/share/roslyn/content/LanguageServer/linux-x64:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Zsh:
echo 'export PATH="$HOME/.local/share/roslyn/content/LanguageServer/linux-x64:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 5. Verify
Microsoft.CodeAnalysis.LanguageServer --version
```

> **Tip:** The NuGet page above lists all available versions. Always pick the highest stable version. Use the NuGet v3 API URL shown above — the older v2 URL (`nuget.org/api/v2/package/…`) may return a 404 HTML page for some versions, which will cause `unzip` to fail with "not a zip file".

### Upgrading Neovim

The system package manager (`apt`, `dnf`, etc.) and Snap often lag well behind the latest Neovim release. **Use the AppImage or tarball methods below** — they pull directly from GitHub Releases and are guaranteed to be current.

**AppImage (simplest, runs without installation):**

```sh
curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage
chmod u+x nvim-linux-x86_64.appimage

# Optional: install system-wide
sudo mv nvim-linux-x86_64.appimage /usr/local/bin/nvim
```

**Tarball (extract anywhere, no root required):**

```sh
curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
tar -xzf nvim-linux-x86_64.tar.gz -C ~/.local
# Adds nvim-linux-x86_64/bin/nvim — make sure ~/.local/nvim-linux-x86_64/bin is on your PATH,
# or symlink: ln -sf ~/.local/nvim-linux-x86_64/bin/nvim ~/.local/bin/nvim
```

After upgrading, confirm the version:

```sh
nvim --version   # should show NVIM v0.12.x or higher
```

> **Note:** If you have multiple `nvim` binaries on your PATH (e.g. an old `/usr/bin/nvim` alongside a new `~/.local/bin/nvim`), run `which nvim` to confirm you are launching the upgraded version.

---

## Quick Start

1. Open any `.cs` file — Roslyn attaches automatically.
2. If the project has multiple `.sln` files, run `:Roslyn target` to pick the solution.
3. Start the REPL with `,sl` on any line, or open it explicitly via iron.nvim's `:IronRepl`.

---

## LSP Features (Roslyn)

All standard LSP keybindings apply in `.cs` buffers:

| Keys | Action |
|---|---|
| `gd` | Go to definition |
| `K` | Hover documentation |
| `gr` | Find references |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action (includes *Fix all*, *Nested actions*, *Complex edits*) |
| `<leader>e` | Show diagnostic float |
| `[d` / `]d` | Previous / next diagnostic |

Roslyn also supports:

- **Multiple solution files** — use `:Roslyn target` to switch between them.
- **Source-generated files** — navigates into generated code transparently.
- **Broad root detection** — set `broad_search = true` in the plugin opts if your `.sln` lives above the project root.

---

## C# REPL (csharprepl via iron.nvim)

LocalLeader is `,` in `.cs` buffers.

| Keys | Action |
|---|---|
| `,sl` | Send current line to REPL |
| `,sc` | Send motion or visual selection |
| `,sp` | Send current paragraph |
| `,sf` | Send entire file |
| `,s<CR>` | Send carriage return |
| `,si` | Interrupt REPL |
| `,sq` | Quit / exit REPL |
| `,cl` | Clear REPL output |

The REPL opens as a horizontal split (40% height) at the bottom of the window.

---

## Formatting (CSharpier)

Format-on-save is enabled automatically in `.cs` buffers via `conform.nvim`. Manual trigger:

| Keys | Action |
|---|---|
| `<leader>f` | Format buffer or visual selection |

CSharpier is opinionated and zero-config — no project-level configuration file required.

---

## Typical Workflow

```
 ┌──────────────────────────────────────────────────────┐
 │  Neovim                                              │
 │  ┌──────────────────────────┬─────────────────────┐  │
 │  │  Program.cs              │  csharprepl REPL    │  │
 │  │                          │                     │  │
 │  │  var x = 42;             │  > var x = 42;      │  │
 │  │  Console.WriteLine(x);   │  > Console          │  │
 │  │                          │    .WriteLine(x);   │  │
 │  │  ,sl to send line ───────┘  42                 │  │
 │  └──────────────────────────┴─────────────────────┘  │
 └──────────────────────────────────────────────────────┘
```

1. Open a `.cs` file — Roslyn starts and diagnostics appear.
2. Send snippets to `csharprepl` with `,sl` / `,sc` to explore APIs interactively.
3. `<leader>f` (or save) formats with CSharpier.
4. Use `gd` / `gr` / `<leader>ca` for full IDE-style navigation and refactoring.
