# Copilot Cheatsheet

**Leader** = `Space`

→ Back to [main cheatsheet](index.md)

## Inline Suggestions (github/copilot.vim)

| Keys | Mode | Action |
|---|---|---|
| `Ctrl-j` | Insert | Accept the full inline suggestion |
| `Alt-f` | Insert | Accept only the next word of the suggestion |

`Alt-f` follows the readline/Emacs "forward-word" convention (`M-f`).

## Model Configuration

The active inline-completion model is set in `lua/plugins/copilot.lua`:

```lua
vim.g.copilot_model = "claude-sonnet-4-5"
```

Other available values: `"gpt-4o"`, `"gpt-4.1"`, `"claude-opus-4-5"`.

---

*Keymaps defined in `lua/keymaps.lua`. Plugin configured in `lua/plugins/copilot.lua`.*
