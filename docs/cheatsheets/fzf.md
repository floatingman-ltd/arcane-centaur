# Fuzzy Finder Cheatsheet (fzf-lua)

→ Back to [main cheatsheet](index.md)

## Built-in fzf-lua Keybindings

fzf-lua uses the default fzf key bindings inside its popup window. Open the
picker with any `:FzfLua <command>` call. Common built-in keys:

| Keys | Action |
|---|---|
| `Ctrl-j` / `↓` | Move to next item |
| `Ctrl-k` / `↑` | Move to previous item |
| `Enter` | Open selected file (default split) |
| `Ctrl-v` | Open selected file in vertical split |
| `Ctrl-s` / `Ctrl-x` | Open selected file in horizontal split |
| `Ctrl-t` | Open selected file in new tab |
| `Ctrl-c` / `Esc` | Close the picker |
| `Ctrl-a` | Select all items |
| `Ctrl-d` | Deselect all items |

## Example Commands

Run these from the Neovim command line or bind them to keys in `lua/keymaps.lua`:

```
:FzfLua files          — fuzzy-find files
:FzfLua live_grep      — live ripgrep across project
:FzfLua buffers        — switch between open buffers
:FzfLua lsp_references — LSP references for symbol under cursor
:FzfLua help_tags      — search Neovim help topics
```

---

*Plugin configured in `lua/plugins/fzf-lua.lua`.*
