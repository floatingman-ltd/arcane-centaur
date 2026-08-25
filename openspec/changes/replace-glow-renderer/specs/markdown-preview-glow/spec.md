## REMOVED Requirements

### Requirement: Glow documentation lives in the Markdown guide
**Reason**: The feature being documented no longer exists — `glow.nvim` and the `glow` binary are removed. The requirement was also already stale: it names `documentation/guides/markdown.md`, a path from before the Antora migration.
**Migration**: Markdown preview is documented in `docs/modules/ROOT/pages/content/markdown.adoc`, which now describes in-editor rendering and no longer lists `glow` as a prerequisite.

### Requirement: Glow plugin is available in all environments
**Reason**: `glow.nvim` is removed. Rendering no longer depends on a plugin that must be present in particular environments; it uses treesitter parsers the config already installs.
**Migration**: No action. The native renderer loads for markdown filetypes in every environment, so the console/GUI distinction this requirement guarded no longer exists. `markdown-preview.nvim` continues to load only when `term.is_console` is `false`, unchanged — see `markdown-popup-preview`.

### Requirement: Glow renders in a floating popup by default
**Reason**: Superseded by *One rendering path serves every markdown surface* in the `markdown-native-rendering` capability, which keeps the centred floating popup but renders it in-editor.
**Migration**: No user-visible change. The popup remains centred, bordered, and dismissible with `q`/`<Esc>`.

### Requirement: Glow binary check
**Reason**: There is no binary to check for. The `vim.fn.executable("glow")` guards and their install-instruction notifications are removed with it.
**Migration**: No action. *Markdown renders in-editor without an external binary* in `markdown-native-rendering` now requires that no binary-missing notification can occur.

### Requirement: Consistent preview keymap across environments
**Reason**: The requirement is defined in terms of `:Glow`, which no longer exists. The consistency guarantee it expresses is retained, restated against the replacement command.
**Migration**: `:Glow` is replaced by `:MarkdownPopup`. `<localleader>p` still routes on environment — `:MarkdownPopup` in a console, `:MarkdownPreviewToggle` in a GUI — as restated in `markdown-popup-preview`.
