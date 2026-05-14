# AI Tools Cheat Sheet

Covers in-editor keymaps for **GitHub Copilot CLI** (`copilot`) and the **OpenSpec** workflow tool.

**Leader** = `Space`

---

## GitHub Copilot CLI

These commands send the current visual selection (or whole buffer when no selection is active) to the `copilot` CLI and display the response in a floating window.

| Keys | Mode | Action |
|---|---|---|
| `<leader>gcs` | Normal / Visual | Ask Copilot to suggest a shell command |
| `<leader>gce` | Normal / Visual | Ask Copilot to explain the selected code |

### Commands

| Command | Description |
|---|---|
| `:CopilotSuggest` | Send buffer/selection to `copilot` for a shell command suggestion |
| `:CopilotExplain` | Send buffer/selection to `copilot` for a code explanation |

### Floating window controls

| Key | Action |
|---|---|
| `q` | Close result window |
| `<Esc>` | Close result window |

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
