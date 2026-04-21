# AI Tools Cheat Sheet

Covers in-editor keymaps for the **OpenSpec** workflow tool.

**Leader** = `Space`

---

## OpenSpec

Drive the OpenSpec change workflow from within Neovim.  Output is shown in a bottom split (close with `q` or `<Esc>`).

| Keys | Mode | Action |
|---|---|---|
| `<leader>osn` | Normal | Create a new change (`OpenspecNew`) |
| `<leader>oss` | Normal | Show status (`OpenspecStatus`) |
| `<leader>osl` | Normal | List all changes (`OpenspecList`) |

### Commands

| Command | Description |
|---|---|
| `:OpenspecNew [name]` | Prompt for a change name (or use argument) and create it |
| `:OpenspecStatus [name]` | Show status for all changes, or a specific `[name]` |
| `:OpenspecList` | List all changes in the repo |

---

→ [Full guide](../guides/ai-tools.md) · [Back to index](index.md)
