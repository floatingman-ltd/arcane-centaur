# HTML Live Preview Cheatsheet (Bracey)

**LocalLeader** = `,` in HTML / CSS / JavaScript buffers

→ Back to [main cheatsheet](index.md)

## Live Preview (bracey.vim)

| Keys | Mode | Action |
|---|---|---|
| `,p` | Normal | Start HTML live preview in browser (`Bracey`) |
| `,x` | Normal | Stop the live preview server (`BraceyStop`) |
| `,r` | Normal | Reload the live preview (`BraceyReload`) |

Bracey starts a local server and opens the current HTML file in the default
browser. Changes to the HTML, CSS, or JavaScript are reflected live without a
manual reload.

## Prerequisites

The plugin's Node.js server dependency is built automatically on first install:

```sh
# Built by lazy.nvim via:
# build = "npm install --prefix server"
```

Node.js (e.g. via `nvm`) must be available at install time.

---

*Keymaps defined in `after/ftplugin/html.lua`. Plugin configured in `lua/plugins/html.lua`.*
