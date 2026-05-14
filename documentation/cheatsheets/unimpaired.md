# Unimpaired Cheatsheet (vim-unimpaired)

→ Back to [main cheatsheet](index.md)

vim-unimpaired provides pairs of bracket mappings — `[` for "previous / enable" and `]` for "next / disable".

---

## Buffer navigation

| Keys | Action |
|---|---|
| `[b` | Previous buffer |
| `]b` | Next buffer |
| `[B` | First buffer |
| `]B` | Last buffer |

## Quickfix / location list

| Keys | Action |
|---|---|
| `[q` | Previous quickfix entry |
| `]q` | Next quickfix entry |
| `[Q` | First quickfix entry |
| `]Q` | Last quickfix entry |
| `[l` | Previous location list entry |
| `]l` | Next location list entry |

## Argument list

| Keys | Action |
|---|---|
| `[a` | Previous file in argument list |
| `]a` | Next file in argument list |

## Line operations

| Keys | Action |
|---|---|
| `[<Space>` | Add blank line above cursor |
| `]<Space>` | Add blank line below cursor |
| `[e` | Exchange current line with line above |
| `]e` | Exchange current line with line below |

## Option toggles

Prefix with `[o` to enable, `]o` to disable, `yo` to toggle.

| Keys | Option toggled |
|---|---|
| `[oh` / `]oh` / `yoh` | `hlsearch` (search highlight) |
| `[oi` / `]oi` / `yoi` | `ignorecase` |
| `[on` / `]on` / `yon` | `number` (line numbers) |
| `[or` / `]or` / `yor` | `relativenumber` |
| `[os` / `]os` / `yos` | `spell` |
| `[ow` / `]ow` / `yow` | `wrap` |
| `[ox` / `]ox` / `yox` | `cursorline` + `cursorcolumn` |

## URL / XML encoding

| Keys | Action |
|---|---|
| `[u{motion}` | URL-encode text |
| `]u{motion}` | URL-decode text |
| `[x{motion}` | XML-encode text (`&amp;`, `&lt;`, etc.) |
| `]x{motion}` | XML-decode text |

---

*Plugin loaded via `lua/plugins/init.lua`. No custom configuration — default vim-unimpaired keybindings apply.*
