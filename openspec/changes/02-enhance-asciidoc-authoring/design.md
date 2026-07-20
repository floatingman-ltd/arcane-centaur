## Context

AsciiDoc support today:

- **Filetype**: Neovim's built-in detection sets `*.adoc`/`*.asciidoc` → filetype `asciidoc`. No syntax plugin, no folding, no fenced-code highlighting.
- **Preview**: `after/ftplugin/asciidoc.lua` defines `<localleader>p`/`<localleader>pp` (Docker Asciidoctor → HTML → browser) and `<localleader>pa` (Docker Antora full-site build → browser). These are buffer-local maps keyed to the `asciidoc` filetype.
- **Cheatsheet**: `lua/config/cheatsheet.lua` `ft_map` has entries for lisp/clojure/.../markdown but **no `asciidoc`** — AsciiDoc never participated in context-aware cheatsheet resolution.
- **Docs**: `docs/modules/ROOT/pages/content/asciidoc-cheatsheet.adoc` exists; there is no `content/asciidoc.adoc` guide.

Two upstream facts to verify at implementation time (treat the README as authoritative):

- **vim-asciidoctor uses the `asciidoctor` filetype** and ships `ftdetect/asciidoctor.vim` remapping `*.adoc` etc. to it. Confirm the exact extension set and the global option names before wiring `init`.
- **markview.nvim lists AsciiDoc as supported** (v28+, 2026), but its renderer is keyed by filetype internally. Whether its AsciiDoc spec activates for a buffer whose filetype is `asciidoctor` (rather than `asciidoc`) is the open question this design hedges against.

## Goals / Non-Goals

**Goals**
- Fast AsciiDoc syntax + folding + fenced-code highlighting for every `.adoc` file.
- Keep the existing Docker/Antora preview maps working after the filetype change.
- Add an opt-in in-buffer render for focused reading, without Docker.
- One canonical AsciiDoc filetype across the config, with no dangling `asciidoc`-keyed code.

**Non-Goals**
- Replacing the Docker/Antora preview.
- Enabling markview for Markdown (owned by markdown-preview.nvim + glow).
- AsciiDoc LSP / treesitter parser.
- Auto-rendering markview on every AsciiDoc buffer (it starts disabled).

## Decisions

### Canonical filetype = `asciidoctor`, registered by us
Rather than fight vim-asciidoctor's `ftdetect`, adopt `asciidoctor` as the one true AsciiDoc filetype and register it ourselves so it is set at startup independent of plugin load:

```lua
-- lua/plugins/asciidoc.lua
return {
  {
    "habamax/vim-asciidoctor",
    ft = { "asciidoctor" },
    init = function()
      vim.filetype.add({
        extension = { adoc = "asciidoctor", asciidoc = "asciidoctor", asciidoctor = "asciidoctor" },
      })
      -- Docker ftplugin owns conversion — disable the plugin's compile commands.
      vim.g.asciidoctor_extensions = {}
      -- Reading affordances (verify exact option names against the README):
      vim.g.asciidoctor_folding = 1
      vim.g.asciidoctor_fold_options = 1
      vim.g.asciidoctor_fenced_languages = { "lua", "bash", "python", "clojure", "fsharp", "haskell" }
      vim.g.asciidoctor_syntax_conceal = 0   -- keep markup visible while editing
    end,
  },
  -- markview spec below
}
```

`vim.filetype.add` runs in `init` (at startup, cheap), so opening a `.adoc` fires the `asciidoctor` FileType event → lazy loads the plugin → its syntax/folding apply. We do **not** rely on the plugin's own `ftdetect` running before lazy-load (the classic lazy-loaded-ftplugin ordering trap).

*Alternative considered*: keep the native `asciidoc` filetype and source vim-asciidoctor's syntax under it. Rejected — the plugin's syntax/ftplugin files are named for `asciidoctor`; forcing them onto `asciidoc` is fragile and undocumented.

### Rename the ftplugin to match the filetype
`after/ftplugin/asciidoc.lua` → `after/ftplugin/asciidoctor.lua`. Neovim sources `after/ftplugin/<ft>.lua` by filetype, so the preview maps must live under `asciidoctor.lua` to keep firing. The map *bodies* (Docker Asciidoctor / Antora flows, `open_in_browser`, console/Docker guards) are unchanged — this is a pure rename. The markview toggle map is added here (see below), keeping all AsciiDoc maps filetype-local.

### Conceal off, folding on
vim-asciidoctor can conceal markup (bold markers, URLs). Conceal is kept **off** (`asciidoctor_syntax_conceal = 0`) so editing stays predictable and so it does not visually fight markview's extmark rendering when markview is toggled on. Folding is **on** — it is pure value with no downside.

### markview: opt-in, toggle-driven, scoped to `asciidoctor`
markview defaults to auto-rendering on attach, with a "hybrid" mode that hides decorations near the cursor — jarring while editing. So it is configured to start **disabled** and exposed via a toggle:

```lua
{
  "OXY2DEV/markview.nvim",
  ft = { "asciidoctor" },           -- do NOT include "markdown" — owned elsewhere
  opts = {
    preview = {
      enable = false,                -- start disabled; user toggles per buffer
      filetypes = { "asciidoctor" }, -- bind to our canonical ft (see risk below)
      ignore_buftypes = { "nofile" },
    },
  },
}
```

Toggle map (added in `after/ftplugin/asciidoctor.lua`, buffer-local):

```lua
vim.keymap.set("n", "<localleader>mv", "<cmd>Markview Toggle<CR>",
  { buffer = true, desc = "AsciiDoc: toggle markview in-buffer render" })
```

*The filetype-binding caveat*: if markview's AsciiDoc spec keys on the literal filetype `asciidoc` and does not activate for `asciidoctor`, `preview.filetypes = { "asciidoctor" }` alone will not render AsciiDoc. Verify in a live buffer. Fallbacks, in order of preference: (a) use markview's filetype-alias/registration API to bind its AsciiDoc spec to `asciidoctor`; (b) if no such API, defer markview-for-AsciiDoc and keep markview installed for a later Markdown-only or upstream-fix use. This is why markview is the lower-priority (TRIAL) half of this change — the `asciidoc-syntax` capability stands on its own regardless.

### markview does not touch Markdown
`ft = { "asciidoctor" }` and `preview.filetypes = { "asciidoctor" }` together keep markview off Markdown buffers, so `lua/plugins/markdown.lua` (markdown-preview.nvim + glow) is untouched and the existing Markdown preview workflow is unchanged.

## Risks / Trade-offs

- **Filetype rename (highest risk).** Any code keyed to `asciidoc` breaks. Audited: only `after/ftplugin/asciidoc.lua` (handled by rename). `cheatsheet.lua`, `conform.lua`, `treesitter.lua` have no `asciidoc` key. Mitigation: grep `asciidoc` across `lua/` + `after/` after the change to confirm no stragglers; verify the preview maps fire in a real `.adoc` buffer.
- **markview ↔ `asciidoctor` ft binding (second risk).** Covered above; markview-for-AsciiDoc is a trial with explicit fallbacks. The change still delivers value (syntax/folding) if markview cannot bind.
- **Double-conceal / visual fight.** vim-asciidoctor conceal is off, so when markview is toggled on it owns the rendering layer; toggled off, raw markup shows. No competing conceal.
- **Lazy-load ordering.** `vim.filetype.add` in `init` runs before any `.adoc` is opened, so the `asciidoctor` FileType event fires correctly and lazy loads the plugin. Verify the very first `.adoc` opened in a session highlights correctly (cold start).
- **Independence.** Decoupled from the completion / editing / avante changes — different files; no snacks dependency.

## Validation outline
1. Add `lua/plugins/asciidoc.lua`; rename the ftplugin; `:Lazy sync`.
2. Open a `.adoc` file cold: confirm `:set filetype?` → `asciidoctor`, syntax highlighting is active, headings/sections fold, and a fenced `[source,lua]` block is highlighted as Lua.
3. Confirm `<localleader>p`/`pp` (Docker HTML) and `<localleader>pa` (Antora) still fire.
4. Toggle markview (`<localleader>mv`): confirm in-buffer rendering appears, and toggling again restores raw markup. If it does not render, apply the markview binding fallback in Decisions.
5. Open a `.md` file: confirm markview does **not** activate and markdown-preview/glow still work.
6. `grep -rn asciidoc lua/ after/` shows no stale `asciidoc`-keyed logic.
7. `find . -name '*.lua' -print0 | xargs -0 luac -p`.
