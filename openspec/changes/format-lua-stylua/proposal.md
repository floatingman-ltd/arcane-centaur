## Why

`conform.nvim` runs `stylua` as the Lua formatter on save (`lua = { "stylua" }` in
`lua/plugins/conform.lua`), but the repository's Lua was never actually formatted with stylua, and
until Change 05 there was no `.stylua.toml`. Two consequences:

1. With no config, stylua falls back to its default indent (**tabs**), while every committed Lua
   file uses **2-space** indent — so saving any Lua file silently reindents it to tabs (churn).
2. Beyond indent, the existing Lua does not match stylua's other rules either — `stylua --check
   lua/` reports **~29 files** would change (trailing commas, one-array-item-per-line, expanded
   single-line `if`s, comment de-alignment). So even after pinning indent, editing any file yields
   a large, noisy diff mixed in with the real change.

Change 05 (`upgrade-avante-drop-dressing`) added a `.stylua.toml` pinning stylua to the repo's
2-space style, which stops the tab flip going forward. This change finishes the job: run stylua
across the whole tree once, so every Lua file already conforms and future edits produce clean,
minimal diffs.

## What Changes

- Run `stylua` over all Lua in the repo (`lua/`, `after/`, `init.lua`, and any `plugin/`/`ftplugin/`
  Lua) so every file matches `.stylua.toml` (2-space) and stylua's other defaults.
- Formatting only — **no behavioural change**. `luac -p` on every file must still pass and Neovim
  must start with no new errors.

## Capabilities

### Modified Capabilities

- `lua-formatting`: add the guarantee that the repo ships a `.stylua.toml` (2-space) **and** that all
  committed Lua already conforms to stylua under it, so format-on-save is a no-op on unedited files.

## Impact

- ~29 Lua files reformatted (whitespace / trailing commas / wrapping only — no logic changes).
- `.stylua.toml` — added in Change 05; this change depends on it being present.
- No plugin or runtime behaviour changes; purely cosmetic.

## Prerequisites and sequencing

**Run LAST — the "end game".** Apply this after all functional changes (05–08) *and* the parked
`document-setup-prerequisites` change have merged. Reformatting ~29 files early would muddy every
in-flight change's diff and cause needless merge conflicts; doing it last confines the formatting
churn to a single, reviewable commit and keeps the other changes' diffs clean.

- **Hard prerequisite:** Change 05 (adds `.stylua.toml`).
- **Sequence:** last — after 05–08 and `document-setup-prerequisites`.

## Out of scope

- Changing stylua's rules beyond the 2-space indent already pinned in Change 05 (accept stylua
  defaults for everything else — `column_width = 120`, quote/paren style, etc.).
- Formatting non-Lua files (AsciiDoc, JSON, shell) — different tools, separate concern.
- Adding or changing any format-on-save behaviour — `conform` already runs stylua; this change only
  makes the existing files conform.
