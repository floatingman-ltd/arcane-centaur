## Why

Claude integration today is two one-shot commands in `lua/config/claude_cli.lua`: `:ClaudeSuggest` / `:ClaudeExplain` (`<leader>gcs` / `<leader>gce`) shell out to `claude -p <prompt>` and show the reply in a floating scratch window. Good for "ask Claude a question," but there is no editor-aware session: Claude cannot see what is open/selected, cannot propose diffs, and cannot have files added to its context.

`coder/claudecode.nvim` implements the same WebSocket MCP protocol the official VS Code / JetBrains extensions use. It runs a persistent server that the `claude` CLI connects to, enabling real-time selection/file context sharing, native diff viewing with accept/reject, and editor-driven context management — the difference between "ask Claude" and "Claude is a co-pilot watching the session."

Cross-validation of the *actual* config and the in-progress best-of-breed changes shaped three decisions:

1. **Stay snacks-free.** claudecode's *default* terminal provider is snacks.nvim, but the in-progress `upgrade-avante-drop-dressing` change deliberately **defers adopting snacks**. To remain consistent, claudecode is configured with the **native** terminal provider (Neovim's built-in terminal), which needs no snacks. The WebSocket/MCP/diff features do not require snacks regardless.
2. **Coexist with `claude_cli.lua`, don't replace it.** `claude-cli-integration` is a captured OpenSpec capability with its own spec; `<leader>gcs`/`<leader>gce` stay. The two are complementary (quick one-shot vs. persistent session). claudecode's maps nest under the existing `<leader>gc` "Claude" which-key group.
3. **Avoid the `<leader>a` namespace.** claudecode's upstream default prefix is `<leader>a`, which is **avante** in this config. Its maps are placed under `<leader>gc` instead.

## What Changes

- **Add** `coder/claudecode.nvim` in a new `lua/plugins/claudecode.lua`, with `terminal = { provider = "native" }` (no snacks dependency) and `terminal_cmd` left to the default `claude` on `$PATH`.
- **Map** session commands under the existing `<leader>gc` "Claude" group: toggle (`<leader>gcc`), focus (`<leader>gcf`), add buffer/file to context (`<leader>gcb`), send selection (`<leader>gcv`, visual), accept diff (`<leader>gca`), reject diff (`<leader>gcr`).
- **Keep** `lua/config/claude_cli.lua` and its `<leader>gcs`/`<leader>gce` maps exactly as they are.
- **Reuse** the existing `<leader>gc` "Claude" which-key group (no new group needed).

## Capabilities

### New Capabilities

- `claudecode-session`: a persistent, editor-aware Claude Code session via the WebSocket MCP protocol (coder/claudecode.nvim), with selection/file context sharing and native diff accept/reject, using Neovim's native terminal provider (no snacks dependency) and coexisting with the one-shot `claude_cli` commands.

### Modified Capabilities

<!-- none — claude-cli-integration is preserved verbatim (its <leader>gcs/<leader>gce maps and behavior are unchanged); this change adds a parallel capability rather than modifying the existing one -->

## Impact

- **`lua/plugins/claudecode.lua`** → new.
- **`lua/plugins/which-key.lua`** → no new group; the existing `{ "<leader>gc", group = "Claude" }` now hosts the session maps too.
- **`lua/config/claude_cli.lua`** → unchanged; `<leader>gcs`/`<leader>gce` preserved.
- **`lua/plugins/avante.lua`** → unaffected. claudecode does NOT pull in snacks, honoring the `upgrade-avante-drop-dressing` change's deferral; `<leader>a*` (avante) is left to avante.
- **External**: relies on the same `claude` binary on `$PATH` that `claude_cli.lua` uses (Claude Code auth, not `ANTHROPIC_API_KEY`).
- **Independence**: decoupled from the AsciiDoc / dotnet-debug / textobjects / diagnostics changes; coordinates with the avante change only by staying snacks-free.

## Prerequisites and sequencing

**Sequence position:** 08 of 08 — Wave B (after 05-upgrade-avante-drop-dressing).

- **Hard prerequisites:** none. Adds `lua/plugins/claudecode.lua`; reuses the existing `{ "<leader>gc", group = "Claude" }` which-key entry **without editing `which-key.lua`**, so it does not contend with the `<leader>b`/`<leader>x` editors.
- **Recommended after `upgrade-avante-drop-dressing`:** this change's "native terminal provider / no snacks dependency" requirement is derived from that change's decision to defer snacks. Implementing it afterward keeps the shared rationale coherent. It still works (native provider) if avante has not landed — a *soft* ordering, not a hard requirement.
- **Must stay snacks-free:** honoring the avante change's deferral. If snacks is later adopted (a future change), the provider choice may be revisited.
- **Implementation wave: B** (after Wave A).

## Out of scope

- Deprecating or removing `claude_cli.lua` — the one-shot commands are retained as a complementary capability.
- Adopting snacks.nvim (its terminal/UI modules) — deferred, consistent with the avante change.
- Using the `<leader>a` prefix — reserved for avante.
- Custom MCP tool exposure beyond claudecode's defaults.
