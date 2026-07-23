## Context

`lua/config/claude_cli.lua` (wired from `init.lua` via `M.setup()`):

- `:ClaudeSuggest` / `:ClaudeExplain` → `vim.system({ "claude", "-p", prompt })`, result shown in a float via `config.util.open_float`.
- Maps in `lua/keymaps.lua`: `<leader>gcs` / `<leader>gce` (normal + visual).
- Auth: relies on the `claude` binary on `$PATH` (Claude Code auth), **not** `ANTHROPIC_API_KEY`.

`lua/plugins/which-key.lua` already registers `{ "<leader>gc", group = "Claude" }`. Avante owns `<leader>aa`/`<leader>ao`/`<leader>ac`. The in-progress `upgrade-avante-drop-dressing` change states snacks adoption is deferred/out of scope.

claudecode.nvim (coder/claudecode.nvim) facts — **verified against the upstream README 2026-07-22**:
- Terminal provider: default is **`auto`** (prefers snacks.nvim when installed, else falls back), with `snacks`/`native`/`external`/`none`/custom alternatives. `native` uses Neovim's built-in terminal and needs no snacks. We set `provider = "native"` **explicitly** to guarantee a snacks-free install — relying on `auto` would pull snacks in if it happened to be present.
- Command names confirmed present: `:ClaudeCode`, `:ClaudeCodeFocus`, `:ClaudeCodeSend`, `:ClaudeCodeAdd`, `:ClaudeCodeTreeAdd`, `:ClaudeCodeDiffAccept`, `:ClaudeCodeDiffDeny` (upstream also ships `:ClaudeCodeSelectModel`, `:ClaudeCodeStatus`, `:ClaudeCodeStart`/`Stop`/`Open`/`Close`, `:ClaudeCodeSendText`, `:ClaudeCodeCloseAllDiffs`). Still v0.x — re-confirm against the installed version at implementation time.
- Neovim floor: the README's Requirements section and badge both state **≥ 0.8.0** (one optional feature — unified-diff layout — wants ≥ 0.9.0). This corrects an earlier unverified "≥ 0.10" assumption in this doc. Either way it is trivially satisfied — this config's own baseline is **≥ 0.12** (`CLAUDE.md`) and we run **0.12.x**, so the plugin imposes no additional constraint and all version-gated features are available.

## Goals / Non-Goals

**Goals**
- A persistent, editor-aware Claude session with diff accept/reject and context sharing.
- No snacks dependency (consistent with the avante change).
- Coexistence with the one-shot `claude_cli` commands.
- Keymaps that nest under the existing "Claude" group and avoid avante's `<leader>a`.

**Non-Goals**
- Removing `claude_cli.lua`.
- Adopting snacks.
- Custom MCP tool authoring.

## Decisions

### `lua/plugins/claudecode.lua`, native terminal provider
```lua
return {
  "coder/claudecode.nvim",
  -- intentionally NO snacks dependency; use the native terminal provider
  opts = {
    terminal = { provider = "native" },
    -- terminal_cmd defaults to `claude` on $PATH (same binary claude_cli uses)
  },
  keys = {
    { "<leader>gcc", "<cmd>ClaudeCode<cr>",          desc = "Claude Code: toggle session" },
    { "<leader>gcf", "<cmd>ClaudeCodeFocus<cr>",     desc = "Claude Code: focus window" },
    { "<leader>gcb", "<cmd>ClaudeCodeAdd %<cr>",     desc = "Claude Code: add current file to context" },
    { "<leader>gcv", "<cmd>ClaudeCodeSend<cr>",      mode = "v", desc = "Claude Code: send selection" },
    { "<leader>gca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude Code: accept diff" },
    { "<leader>gcr", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Claude Code: reject diff" },
  },
}
```

- **`provider = "native"`** is the crux: it keeps claudecode snacks-free, honoring the avante change's deferral. If `native` proves rougher than wanted, `external` (use a pre-existing terminal) is the next fallback — still snacks-free. Adopting snacks for the richer terminal is explicitly *not* done here.
- **`terminal_cmd`** defaults to `claude` on `$PATH` — the same binary `claude_cli.lua` already requires, so no new external dependency.
- The exact command names and `keys` are verified against the installed (beta) version; the table above is the documented v0.x form.

### Keymaps under `<leader>gc` (not `<leader>a`)
All claudecode maps use the `<leader>gc` "Claude" prefix, which already exists as a which-key group. Third letters chosen to avoid the existing `<leader>gcs`/`<leader>gce` (claude_cli): `c`, `f`, `b`, `v`, `a`, `r`. `<leader>a*` is left entirely to avante. No new which-key group is needed.

*Alternative considered*: claudecode's upstream `<leader>a` default. Rejected — direct collision with avante.

### claude_cli.lua stays
The one-shot `:ClaudeSuggest`/`:ClaudeExplain` flow is a distinct, lighter capability (no server, no session). It is retained verbatim; `claude-cli-integration`'s spec scenarios must still pass. claudecode is additive.

### ToS / auth posture — no API key required; NOT the avante case (verified 2026-07-22)
claudecode.nvim is **not** a Claude API client. It never calls `api.anthropic.com` and never handles an API key or OAuth token. Per the upstream README it "creates a WebSocket server that Claude Code CLI connects to, implementing the same protocol as the official VS Code extension": the plugin writes a lock file to `~/.claude/ide/[port].lock` (or `$CLAUDE_CONFIG_DIR/ide/[port].lock`) and the official `claude` CLI discovers and connects to it (auto-discovery, or the user runs `/ide`). **All model calls and all authentication are performed by the official `claude` CLI**, using Claude Code's own auth; the plugin is purely an editor-context / diff layer exposing MCP tools the CLI calls.

This is the **same auth posture as the existing `claude_cli.lua`** (`:ClaudeSuggest`/`:ClaudeExplain` shell out to `claude -p`, on Claude Code auth, **no `ANTHROPIC_API_KEY`**), which `CLAUDE.md` already accepts. It is therefore **not** the situation that got avante's Anthropic provider disabled. That risk was a *third-party HTTP client* authenticating to the Anthropic API *as the user* with a subscription OAuth token; the sanctioned fix there was to supply a real API key. Here, no third-party code touches credentials or the API at all — the first-party CLI does, exactly as it is designed to. So **no API key is required to ship this change**, and doing so does not reintroduce the avante ToS concern.

**Residual caveat:** claudecode.nvim is an *unofficial* implementation of the IDE/MCP WebSocket protocol (the fully first-party equivalents are Anthropic's own VS Code / JetBrains extensions). Because the CLI performs the auth and the calls, this is materially different from credential misuse — but if zero ambiguity is ever required, the official extension is the sanctioned alternative. This is an engineering assessment, **not legal advice**; the governing terms are Anthropic's Consumer ToS plus the Claude Code usage terms.

## Risks / Trade-offs

- **Native terminal provider UX (primary trade-off).** snacks' terminal is slicker; the native provider is plainer but dependency-free. Mitigation: accept native for consistency; `external` is the fallback. Revisit snacks only if/when the avante change's snacks deferral is itself revisited.
- **Beta API drift (highest risk).** claudecode is v0.x; command/option names may move. Mitigation: verify command names and the provider option against the installed version; adjust the `keys` table accordingly.
- **WebSocket server lifecycle.** claudecode starts a local server; confirm it starts/stops cleanly and the `claude` CLI connects (the README documents the handshake). If the CLI does not auto-connect, document the `/ide` connect step.
- **Two Claude entry points.** `<leader>gc{s,e}` (one-shot) vs `<leader>gc{c,f,b,v,a,r}` (session) could confuse; mitigated by the shared, clearly-labelled which-key group and docs.
- **Independence.** No shared files with the other four changes; coordinates with avante only by not adding snacks.

## Validation outline
1. Add `lua/plugins/claudecode.lua`; `:Lazy sync` — confirm it installs **without** pulling in snacks.
2. `<leader>gcc` starts a Claude Code session in a native terminal; the `claude` CLI connects to the server.
3. Select lines, `<leader>gcv` — the selection reaches the session as context.
4. `<leader>gcb` adds the current file; ask Claude to edit it; `<leader>gca`/`<leader>gcr` accept/reject the proposed diff.
5. Confirm `<leader>gcs`/`<leader>gce` (claude_cli) still work unchanged.
6. Confirm `<leader>aa`/`<leader>ao`/`<leader>ac` (avante) are unaffected and snacks is absent from `:Lazy`.
7. `find . -name '*.lua' -print0 | xargs -0 luac -p`.
