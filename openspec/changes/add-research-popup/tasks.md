## 1. Shared Float Helper

- [x] 1.1 Move `open_float(title, lines)` from `lua/config/claude_cli.lua` into `lua/config/util.lua` as `M.open_float` — faithful extraction: same dimensions (0.75 × 0.6), rounded border, centred, `style = "minimal"`, `filetype = markdown`, `nomodifiable`, `q`/`<Esc>` to close
- [x] 1.2 Update `lua/config/claude_cli.lua` to call `require("config.util").open_float(...)` and remove its private local copy
- [ ] 1.3 Syntax-check both files (`luac -p`) and manually verify `:ClaudeExplain` / `:ClaudeSuggest` still render in an identical window

## 2. Research Module

- [x] 2.1 Create `lua/config/research.lua` with `M.setup()` mirroring `claude_cli.lua`'s structure
- [x] 2.2 Implement a shared run helper: guard that `claude` is on `$PATH` (else `vim.notify` error + abort) → `vim.ui.input` for a free-form question → abort on empty/cancelled input → build prompt → `vim.system({ "claude", "-p", prompt }, {}, cb)` (async) → on success `util.open_float(title, lines)`, on non-zero exit `vim.notify` the error; emit an INFO "running…" notification before the call
- [x] 2.3 Implement local-context assembly: collect live keymaps with their `desc` via `vim.api.nvim_get_keymap()` (Normal + other relevant modes) and the assembled cheatsheet content (`core.md` + filetype sheet, reusing `cheatsheet.lua`'s assembly), formatted compactly
- [x] 2.4 `:ResearchLocal` — build a grounded prompt (config context + an instruction to answer only from that context and to state when the answer is absent) and run it; float title e.g. `"Research (local)"`
- [x] 2.5 `:ResearchAsk` — send the bare question with no local context; float title e.g. `"Research"`
- [x] 2.6 Register `:ResearchLocal` and `:ResearchAsk` user commands with `desc`

## 3. Wiring

- [x] 3.1 `init.lua` — call `require("config.research").setup()` alongside the existing `claude_cli` / `openspec` setup calls
- [x] 3.2 `lua/keymaps.lua` — add `<leader>?l` → `:ResearchLocal` and `<leader>?a` → `:ResearchAsk` (Normal mode), each with a `desc`, under the existing `<leader>?` namespace

## 4. Validation

- [x] 4.1 Syntax-check `util.lua`, `claude_cli.lua`, `research.lua` with `luac -p`
- [ ] 4.2 Manually verify `<leader>?a "Common Lisp format directives"` opens a float with a general answer
- [ ] 4.3 Manually verify `<leader>?l "how do I toggle the terminal?"` returns an answer that reflects the config's actual binding (`<leader>t`) — proves grounding works
- [ ] 4.4 Manually verify `<leader>?l` with a question not covered by the context makes the model say it cannot find it in the configuration (no generic fabrication)
- [ ] 4.5 Manually verify empty/cancelled input aborts with no window, and the `claude`-not-on-`$PATH` path notifies and aborts
- [ ] 4.6 Manually verify `q` / `<Esc>` dismiss the float and that the result window is visually identical to `:ClaudeExplain`'s

## 5. Documentation

- [x] 5.1 `docs/modules/ROOT/pages/ai/ai-tools.adoc` — add a "Research popup" section: the two keys, local vs general, the grounding behaviour, and that it uses Claude Code's built-in auth (no `ANTHROPIC_API_KEY`)
- [x] 5.2 `docs/modules/ROOT/pages/ai/ai-tools-cheatsheet.adoc` — add `<leader>?l` and `<leader>?a` rows
- [x] 5.3 `docs/modules/ROOT/pages/editor/keybindings.adoc` — add the two keys to the global reference
- [x] 5.4 `cheatsheets/core.md` — add `<leader>?l` / `<leader>?a` for in-editor discoverability via `<leader>?`
