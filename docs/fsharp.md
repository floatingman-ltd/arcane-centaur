# Working with F#

F# support uses [iron.nvim](https://github.com/Vigemus/iron.nvim) for REPL interaction and `fsautocomplete` for LSP-powered completions, go-to-definition, hover docs, and formatting.

All F# plugins lazy-load only when you open a `.fs`, `.fsx`, or `.fsi` file.

## Prerequisites

| Dependency | Purpose | Install hint |
|---|---|---|
| **.NET SDK ≥ 6** | F# compiler and `dotnet fsi` REPL | <https://dotnet.microsoft.com/download> |
| **fsautocomplete** | F# LSP server | `dotnet tool install -g fsautocomplete` |

### Installing .NET SDK

Follow the official guide for Ubuntu/WSL:

```sh
# Add Microsoft package feed and install
wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update && sudo apt install -y dotnet-sdk-8.0
```

Or download directly from <https://dotnet.microsoft.com/download>.

## LSP

The `fsautocomplete` server is configured in `lua/config/lsp.lua`. Install it with:

```sh
dotnet tool install -g fsautocomplete
```

See [readme.md](../readme.md#lsp-support) for the shared LSP keybindings.

## Quick Start

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

4. **LSP features** work the same as for other languages — `gd`, `K`, `gr`, `<leader>rn`, `<leader>ca`, `<leader>e`, `[d`/`]d`.

5. **Format on save** is enabled via `conform.nvim` using the fsautocomplete formatter.
   You can also trigger it manually with `<leader>f`.

## Typical Workflow

```
 ┌──────────────────────────────────────────────────────┐
 │  Neovim                                              │
 │  ┌─────────────────────────┬────────────────────┐    │
 │  │  hello.fs               │  dotnet fsi REPL   │    │
 │  │                         │                    │    │
 │  │  let greet name =       │  > val greet :     │    │
 │  │    printfn "Hi %s" name │    string -> unit  │    │
 │  │                         │  > Hi Walt         │    │
 │  │  ,sl to send line ──────┘                    │    │
 │  └─────────────────────────┴────────────────────┘    │
 └──────────────────────────────────────────────────────┘
```
