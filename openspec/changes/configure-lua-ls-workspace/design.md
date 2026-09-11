## Context

`lua/config/lsp.lua` registers every server through the same shared `on_attach` and `capabilities`. Most servers need nothing further — `fsautocomplete`, `marksman` and the rest infer their environment from the project on disk. `lua_ls` is the exception: a Neovim configuration is not an ordinary Lua project. The `vim` global is injected by the host program, and the API definitions live in `$VIMRUNTIME` rather than anywhere `lua_ls` would look on its own.

The result, measured on 2026-09-11 with `lua-language-server` 3.18.2-dev:

| Configuration | Total diagnostics | `Undefined global` | Other |
|---|---|---|---|
| As shipped today | 661 | 659 | 2 |
| `workspace.library` + `globals = { "vim" }` | 26 | 18 (all `pandoc`) | 8 |
| **As shipped by this change** | **8** | **0** | **8** |

The two "other" findings in the current state are an undefined type alias in `lua/plugins/fzf-lua.lua` and an unused local in `testdocs/hello.lua`. Everything else a reader sees is `Undefined global \`vim\``.

This is recorded in `openspec/DEFERRED_VERIFICATION.md` (group F) as "pre-existing and cosmetic". It is not cosmetic. On 2026-09-08 a genuine `unpack` deprecation nearly went unnoticed for exactly this reason, and that is the failure mode a 99.7%-noise list produces: not a missed message, but a list nobody opens.

## Goals / Non-Goals

**Goals:**

- Make the Lua diagnostics list readable, so that a real finding is visible without being hunted for.
- Teach `lua_ls` the actual Neovim API, so deprecations and type errors are reported at all.
- Leave the count at a number a person can hold in their head, and know what each remaining entry is.

**Non-Goals:**

- Fixing the findings this surfaces. They are real and they are recorded, but they are six unrelated bugs and this change is about the configuration that hid them.
- Adding `lazydev.nvim` or any other plugin. The problem is a missing settings table, not a missing dependency.
- Changing `on_attach`, the shared capabilities, or any keymap.
- Touching any other server's configuration.

## Decisions

### D1 — Configure `workspace.library`, not just `diagnostics.globals`

Both are set, but they do different jobs and only one of them matters.

Adding `"vim"` to `diagnostics.globals` silences the reports. It teaches `lua_ls` nothing: `vim` becomes a name it has agreed not to complain about, with no type behind it. Measured, it produces the same zero `Undefined global` count as the full fix on a sample file — and that equivalence is the trap, because it looks like the problem is solved.

Adding `$VIMRUNTIME` to `workspace.library` gives `lua_ls` the real definitions. That is what makes hover, completion and signature help work on `vim.*`, and it is what makes deprecation and type diagnostics possible at all. The six findings this change surfaces exist only under this variant; the globals-only variant reports none of them.

*Alternative considered — `vim.api.nvim_get_runtime_file("", true)` as the library.* This is the more common recipe and indexes every installed plugin as well as the runtime. Rejected for this configuration: it is roughly 45 extra plugin trees for a benefit this repo does not need, since nothing here writes against plugin internals often enough to justify indexing all of them. `$VIMRUNTIME` alone resolves everything the diagnostics actually needed.

### D2 — `pandoc` is in the globals list, and that is not a workaround

Eighteen `Undefined global` reports survive the `vim` fix, and all eighteen are `pandoc`, across three files: `docker/md2pdf/mermaid-filter.lua`, `docker/md2pdf/plantuml-filter.lua`, `scripts/confluence_filter.lua`.

Those are Pandoc Lua filters. They are not Neovim Lua and never run inside Neovim — Pandoc injects `pandoc` the same way Neovim injects `vim`. Reporting it is a false positive of exactly the class this change exists to remove, so it is treated the same way.

Leaving them would be worse than it sounds. Eighteen is small enough to look tolerable and large enough to re-establish the habit of not reading the list, which is the actual defect being fixed.

*Alternative considered — a `.luarc.json` scoping the Pandoc directories separately.* More correct in principle, since those files also want Lua 5.4 rather than LuaJIT. Rejected as disproportionate: it adds a second configuration mechanism and a file that has to be kept in step with this one, to fix a stdlib-version mismatch that produces no diagnostics today.

**Known imprecision, accepted.** `diagnostics.globals` is workspace-wide, so a typo'd `pandoc` in a Neovim file would not be flagged, and `runtime.version = "LuaJIT"` is wrong for the Pandoc filters. Both are noted here rather than solved, because the alternative costs more than the imprecision does.

### D3 — Surfaced findings are recorded, not fixed

Six findings appear once the library is configured: four missing nil checks in `lua/config/http_preview.lua`, a parameter type mismatch in `lua/config/claude_cli.lua`, and a `uv_tcp_t`/`uv_stream_t` optional-type assignment.

They go to `recommendations/ideas.md`. Fixing them here would make the change about six small unrelated bugs, and would mean the diff that fixes the *configuration* could not be reviewed on its own. Recording them is not a deferral dodge: the entire value of this change is that these became visible, so leaving them written down nowhere would undo it.

## Risks / Trade-offs

**The surfaced findings get re-buried under a different noise source.** → The remaining count is 8, every entry is a real finding, and all eight are listed in `recommendations/ideas.md`. If a future change pushes it back into the hundreds, the same failure returns. The TEST_PLAN case records the expected number so a later reader has something to compare against.

**`workspace.library` slows `lua_ls`.** → Measured rather than assumed, on 2026-09-11. Attach time is unchanged at roughly 80 ms either way. Time to first diagnostic rises from ~0.9 s to ~3.4 s, which is `lua_ls` indexing `$VIMRUNTIME`. That cost is **one-off per session, not per file**: opening a second and third Lua file in the same session produced diagnostics in 101 ms each, against 3546 ms for the first. Judged worth paying for diagnostics that are readable at all. If it ever is not, the fallback is the globals-only configuration, which fixes the noise but loses the deprecation and type reporting that is the point.

**A real `vim` typo is now unreportable.** → Inherent to `diagnostics.globals`, and unchanged from any other Neovim Lua setup. The library makes this less likely to matter, since `vim.foo` with a bad `foo` is now a type error rather than an unknown global.

**`runtime.version = "LuaJIT"` is wrong for the Pandoc filters.** → Accepted in D2. It produces no diagnostics today; revisit only if a stdlib-version mismatch actually reports something.

## Open Questions

- **Should `testdocs/` be excluded from analysis?** `testdocs/hello.lua` contributes an unused-local warning and exists only as a fixture. Out of scope here, but if fixture noise grows it is the next thing to look at.
