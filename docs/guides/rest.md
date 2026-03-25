# REST Client Guide (rest.nvim)

[rest.nvim](https://github.com/rest-nvim/rest.nvim) is a fast, tree-sitter-powered HTTP client built into Neovim. Write your API requests in `.http` files and execute them directly from the editor.

## Prerequisites

| Dependency | Purpose | Install hint |
|---|---|---|
| **curl** | Sends HTTP requests | `sudo apt install curl` |
| **Neovim ≥ 0.10.1** | Minimum version required by rest.nvim | `sudo snap install nvim --classic` |

The `http` tree-sitter grammar is installed automatically by lazy.nvim on first launch.

## Quick Start

1. Create a file with the `.http` extension, e.g. `api.http`.
2. Write a request:

```http
GET https://httpbin.org/get HTTP/1.1
Accept: application/json
```

3. Place the cursor anywhere inside the request block.
4. Press `,r` (or run `:Rest run`) to execute it.
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

Run by name with `:Rest run createUser`.

## Environment Variables

Store environment-specific values (base URLs, API keys, etc.) in an env file whose name matches the pattern `*.env.*` (e.g. `http.env.local`, `.env.development`):

```
# http.env.local
base_url=https://api.example.com
api_key=my-secret-key
```

Reference variables in your `.http` file:

```http
GET {{base_url}}/users HTTP/1.1
Authorization: Bearer {{api_key}}
```

Register the env file with `,e` (`:Rest env select`) and pick the file from the list.

## Typical Workflow

1. Create `requests.http` with your API calls.
2. Create `http.env.local` with base URL and credentials.
3. Press `,e` to register the env file.
4. Press `,r` on each request to run it.
5. Use `H` / `L` in the result pane to switch between response body, headers, and stats.
6. Press `,l` to quickly re-run the last request after editing it.

## Keybindings

→ See the [REST cheatsheet](../cheatsheets/rest.md) for the full keybinding reference.

| Keys | Action |
|---|---|
| `,r` | Run request under cursor |
| `,l` | Re-run last request |
| `,o` | Open result pane |
| `,e` | Select environment file |

## Configuration

rest.nvim is configured via `vim.g.rest_nvim`. The defaults are sensible for most use cases. To customise, add options in `lua/plugins/rest.lua`:

```lua
vim.g.rest_nvim = {
  request = {
    skip_ssl_verification = false,
  },
  response = {
    hooks = {
      format = true,   -- auto-format response body with gq
    },
  },
}
```

See `:h rest-nvim.config` for all available options.
