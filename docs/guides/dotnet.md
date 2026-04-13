# .NET / C# Guide

Full C# editing support: syntax highlighting, LSP (Roslyn), formatting (CSharpier), and an interactive REPL (csharprepl via iron.nvim). F# support is unchanged — see [docs/guides/fsharp.md](fsharp.md).

---

## Prerequisites

Install the following .NET global tools:

```sh
dotnet tool install -g csharpier    # Formatter
dotnet tool install -g csharprepl   # Interactive REPL
```

### Installing the Roslyn Language Server

The Roslyn LSP is the official Microsoft C# language server used in VS Code's C# Dev Kit. It is **not** installed via `dotnet tool install`; download the native binary for your platform from the NuGet feed.

**Linux / WSL2 (x64):**

```sh
# 1. Create an install directory
mkdir -p ~/.local/share/roslyn && cd ~/.local/share/roslyn

# 2. Download the latest linux-x64 package (find the current version at:
#    https://dev.azure.com/azure-public/vside/_artifacts/feed/vs-impl/NuGet/Microsoft.CodeAnalysis.LanguageServer.linux-x64 )
VERSION="4.13.0.1"   # replace with the latest shown on the feed page
curl -L "https://www.nuget.org/api/v2/package/Microsoft.CodeAnalysis.LanguageServer.linux-x64/$VERSION" \
     -o /tmp/roslyn.nupkg

# 3. Extract and make executable
unzip -o /tmp/roslyn.nupkg
chmod +x content/LanguageServer/linux-x64/Microsoft.CodeAnalysis.LanguageServer

# 4. Add to PATH (add to ~/.bashrc or ~/.zshrc and reload)
echo 'export PATH="$HOME/.local/share/roslyn/content/LanguageServer/linux-x64:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 5. Verify
Microsoft.CodeAnalysis.LanguageServer --version
```

> **Tip:** The feed page above lists all available versions. Always pick the highest stable version. The `neutral` platform variant also works but requires running via `dotnet <path>/Microsoft.CodeAnalysis.LanguageServer.dll` instead of a native binary.

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
