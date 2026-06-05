# IDE Layout — Manual Verification Checklist

## Setup

Open Neovim with a file: `nvim <some-file>`

---

## Scenarios

- [x] **`<leader>L` assembles layout** — tree opens left, terminal opens full-width at bottom, focus lands in editor
- [x] **`<leader>L` is idempotent** — press again; no duplicate windows
- [x] **`<leader>t` from inside the tree** — terminal opens full-width (not 30-col inside the tree column)
- [x] **Shell persists across toggles** — toggle terminal off (`<leader>t`), toggle back on; same shell session, history intact
- [x] **`:Bd` keeps the layout** — open two files, run `:Bd` on one; window stays open showing the other file, tree width unchanged
- [x] **`:q` last editor exits cleanly** — with layout assembled, `:q` the editor; Neovim exits, no full-width tree left behind
- [x] **Floats unaffected** — trigger `:Glow`, `<leader>?` cheatsheet; popups render over the layout normally
- [x] **Terminal height stable** — open another split (`:split`); terminal stays 15 lines tall

---

_Change: `add-ide-layout` | Branch: `feat/add-ide-layout`_
