# AI Tools Guide

This guide covers three AI / workflow tools that are integrated directly into Neovim:

| Tool | What it does |
|---|---|
| **GitHub Copilot CLI** | Ask Copilot to suggest or explain shell commands without leaving the editor |
| **OpenSpec** | Drive the in-repo OpenSpec change workflow from Neovim keymaps |
| **Serena MCP server** | Provides symbol-aware code intelligence to GitHub Copilot chat and completions |

---

## GitHub Copilot CLI

### Prerequisites

1. Install [GitHub CLI](https://cli.github.com/):
   ```sh
   # Debian / Ubuntu
   sudo apt install gh
   # macOS
   brew install gh
   ```
2. Authenticate:
   ```sh
   gh auth login
   ```
3. Install the Copilot extension:
   ```sh
   gh extension install github/gh-copilot
   ```

### Usage

Select code in visual mode (or stay in normal mode to use the whole buffer), then:

| Keys | Action |
|---|---|
| `<leader>gcs` | Ask Copilot to **suggest** a shell command based on context |
| `<leader>gce` | Ask Copilot to **explain** the selected code or command |

The response appears in a floating window.  Press `q` or `<Esc>` to close it.

You can also run the commands directly:
- `:CopilotSuggest` — suggest
- `:CopilotExplain` — explain

### How it works

`lua/config/copilot_cli.lua` uses `vim.system()` to call `gh copilot <subcommand>` asynchronously with the buffer text piped as stdin.  The result is rendered in a scratch buffer inside a `nvim_open_win` floating window.

---

## OpenSpec

OpenSpec is the change-management workflow tool used in this repo (see `openspec/` directory).

### Prerequisites

`openspec` must be on your `$PATH`.  Install it following the project's own README, or check `openspec --help` to confirm it's available.

### Usage

| Keys | Command | Action |
|---|---|---|
| `<leader>osn` | `:OpenspecNew` | Prompt for a change name and create it |
| `<leader>oss` | `:OpenspecStatus` | Show overall change status |
| `<leader>osl` | `:OpenspecList` | List all changes |

**Scoped status:** pass a change name to `:OpenspecStatus` to see only that change:
```
:OpenspecStatus add-copilot-openspec-serena
```

Output is shown in a read-only bottom split (15 lines tall).  Press `q` or `<Esc>` to close it.

### How it works

`lua/config/openspec.lua` uses synchronous `vim.fn.system()` (appropriate because `openspec` commands complete in well under a second) and opens a scratch buffer in a `botright split`.

---

## Serena MCP Server

[Serena](https://github.com/oramasearch/serena) is a symbol-aware code-intelligence MCP (Model Context Protocol) server.  When running, it allows GitHub Copilot to perform semantic operations — go-to-definition, find-references, workspace symbol search — that it cannot do from text alone.

### Prerequisites

Node.js 18+ is required.  Install Serena globally to avoid `npx` startup latency on every request:

```sh
npm install -g @oramasearch/serena
```

Or rely on on-demand `npx` (slower first call, no install needed):

```sh
# No install needed; npx downloads on first use
```

### Configuration

Serena is declared in `lua/plugins/copilot.lua` via `vim.g.copilot_mcp_servers`.  No extra setup is needed — it is auto-discovered by `copilot.vim` at startup.

The config prefers the global `serena` binary when found on `$PATH`; otherwise it falls back to `npx -y @oramasearch/serena`.

### Verifying

To confirm the MCP server is configured, run inside Neovim:

```vim
:lua print(vim.inspect(vim.g.copilot_mcp_servers))
```

You should see a table with a `serena` key containing `type = "stdio"` and the launch command.

---

→ [Keybinding cheatsheet](../cheatsheets/ai-tools.md)
