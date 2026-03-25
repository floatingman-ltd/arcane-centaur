# REST Client Guide (kulala.nvim)

[kulala.nvim](https://github.com/mistweaverco/kulala.nvim) is a fully-featured, pure-Lua REST client for Neovim. Write your API requests in `.http` files and execute them directly from the editor.

## Prerequisites

| Dependency | Purpose | Install hint |
|---|---|---|
| **curl** | Sends HTTP requests | `sudo apt install curl` |
| **Neovim ≥ 0.10.1** | Minimum version required | `sudo snap install nvim --classic` |
| **tree-sitter CLI** | Compiles kulala's custom HTTP parser on first launch | see below |

### Installing the tree-sitter CLI

kulala.nvim ships a custom `kulala_http` tree-sitter grammar that nvim-treesitter compiles from source the first time you open an `.http` file. This requires the `tree-sitter` CLI binary to be on your `PATH`.

**Via npm** (recommended if Node.js is already installed):

```sh
npm install -g tree-sitter-cli
```

**Via Cargo** (if you have a Rust toolchain):

```sh
cargo install tree-sitter-cli
```

**Pre-built binary**: download the latest release for your platform from
<https://github.com/tree-sitter/tree-sitter/releases/latest> and place it
somewhere on your `PATH` (e.g. `~/.local/bin/`).

The compilation happens once; subsequent launches use the cached parser.

kulala.nvim has **no LuaRocks dependencies** and installs as a plain git plugin.

## Quick Start

1. Create a file with the `.http` extension, e.g. `api.http`.
2. Write a request:

```http
GET https://httpbin.org/get HTTP/1.1
Accept: application/json
```

3. Place the cursor anywhere inside the request block.
4. Press `,r` to execute it.
5. The result pane opens automatically with the response body, headers, and timing stats.

## HTTP File Syntax

```http
Method Request-URI HTTP-Version
Header-field: Header-value

Request-Body
```

### Example: GET request

```http
GET https://api.example.com/users HTTP/1.1
Accept: application/json
```

### Example: POST request with JSON body

```http
POST https://api.example.com/users HTTP/1.1
Content-Type: application/json

{
  "name": "Alice",
  "email": "alice@example.com"
}
```

### Example: Named request

```http
# @name createUser
POST https://api.example.com/users HTTP/1.1
Content-Type: application/json

{
  "name": "Alice"
}
```

## Environment Variables

kulala.nvim supports two env file formats:

**`http-client.env.json`** (named environments, selected with `,e`):

```json
{
  "dev": {
    "base_url": "https://api.example.com",
    "api_key": "my-secret-key"
  },
  "prod": {
    "base_url": "https://api.example.com",
    "api_key": "prod-key"
  }
}
```

**`.env`** (dotenv format, loaded automatically from any parent directory):

```
base_url=https://api.example.com
api_key=my-secret-key
```

Reference variables in your `.http` file using either format:

```http
GET {{base_url}}/users HTTP/1.1
Authorization: Bearer {{api_key}}
```

Use `,e` to pick which named environment from `http-client.env.json` is active.

## Typical Workflow

1. Create `requests.http` with your API calls.
2. Create `http-client.env.json` with base URL and credentials.
3. Press `,e` to select the environment.
4. Press `,r` on each request to run it.
5. Press `,l` to quickly re-run the last request after editing it.
6. Press `,o` to re-open the result pane if closed.

## Keybindings

→ See the [REST cheatsheet](../cheatsheets/rest.md) for the full keybinding reference.

| Keys | Action |
|---|---|
| `,r` | Run request under cursor |
| `,l` | Re-run last request |
| `,o` | Open result pane |
| `,e` | Select environment |

## Troubleshooting

### `ENOENT: no such file or directory (cmd): 'tree-sitter'`

kulala.nvim builds its custom `kulala_http` tree-sitter grammar on first launch using the
`tree-sitter` CLI. If the binary is not on your `PATH` you will see:

```
[nvim-treesitter/install/kulala_http] error: Error during "tree-sitter build": … ENOENT: 'tree-sitter'
```

**Fix:** install the tree-sitter CLI (see [Installing the tree-sitter CLI](#installing-the-tree-sitter-cli) above), then **restart Neovim**.

### `async.lua: timeout` / `Failed to run config for kulala.nvim`

Same root cause — nvim-treesitter timed out waiting for `tree-sitter build` to complete because the binary was not found.

**Fix:** same as above — install the tree-sitter CLI, then **restart Neovim**.

### `'fzf' is not a valid executable` when pressing `,e`

kulala.nvim's default `display_mode` is `"fzf"`, which calls the standalone `fzf`
system binary. This config uses the **fzf-lua** Neovim plugin (ibhagwan/fzf-lua) which
does *not* place an `fzf` executable on `PATH`, so you will see:

```
'fzf' is not a valid executable, aborting. Please make sure 'fzf' is installed.
```

**Fix:** `lua/plugins/rest.lua` sets `display_mode = "vim_ui_select"` in kulala's opts,
which routes environment selection through Neovim's built-in `vim.ui.select` and
requires no external binary. If you still see the error after updating, run
`:Lazy sync` to ensure kulala.nvim is up-to-date and then restart Neovim.

### All keymaps (`,r` `,l` `,o` `,e`) do nothing after the error

When kulala's `setup()` errors (either due to the missing CLI or the timeout), the UI layer is never initialized. Every keymap that calls into the UI — including `,o` (open result pane) — will silently fail or show `nil` errors until kulala initializes successfully.

**Fix:** install the tree-sitter CLI, restart Neovim, and open an `.http` file. The grammar is compiled once on this first successful launch; subsequent starts will use the cached parser and load instantly.

## Configuration

kulala.nvim is configured via `opts` in `lua/plugins/rest.lua`. The defaults are sensible for most use cases. To customise:

```lua
return {
  {
    "mistweaverco/kulala.nvim",
    ft = { "http" },
    opts = {
      default_env = "dev",
      debug = false,
    },
  },
}
```

See the [kulala.nvim documentation](https://neovim.getkulala.net/docs/getting-started/configuration-options) for all available options.
