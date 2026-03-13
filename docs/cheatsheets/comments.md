# Comments Cheatsheet (vim-commentary)

→ Back to [main cheatsheet](index.md)

## Comment Toggling

| Keys | Mode | Action |
|---|---|---|
| `gcc` | Normal | Toggle comment on current line |
| `gc` | Visual | Toggle comment on selection |
| `gc<motion>` | Normal | Toggle comment over a motion (e.g. `gcap` = paragraph) |
| `Ctrl-/` | Normal | Toggle comment (`:Commentary`) |

`vim-commentary` uses the correct comment syntax for each filetype automatically
(`--` for Lua, `//` for JavaScript, `;;` for Lisp, `#` for Python, etc.).

---

*Plugin configured in `lua/plugins/vim-commentary.lua`. `gcc`, `gc`, and `Ctrl-/` keys are registered via lazy.nvim `keys` so the plugin loads on first use of any of them.*
