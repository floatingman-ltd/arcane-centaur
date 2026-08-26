## Why

`glow.nvim` and the `glow` binary were removed in `replace-glow-renderer` (archived 2026-08-25), replaced by in-editor rendering. Two capability specs still describe the system in terms of glow, and both do so in **normative** text rather than in passing:

- `asciidoc-inbuffer-preview` requires that "markdown-preview.nvim / glow.nvim SHALL behave exactly as before this change". glow.nvim does not exist, so the scenario cannot be satisfied as written.
- `ide-layout` names "Glow previews" among the floating windows the layout must not disturb, and a scenario begins "WHEN a Glow preview or which-key hint is triggered". That trigger is unreachable.

Neither was fixed at the time deliberately: editing a spec outside a delta is how specs drift from the changes meant to govern them. They were logged in `recommendations/ideas.md` for exactly this follow-up.

The intent behind both requirements is still valid and worth preserving — the Docker/Antora preview and the Markdown workflow must survive markview, and floats must be unaffected by the IDE layout. Only the examples naming a removed plugin are wrong.

**Scope has shrunk since this was logged.** The item listed three specs. `code-folding` is no longer one of them: its glow mention was rewritten by `align-treesitter-providers` into deliberate history explaining why treesitter folding was once disabled and why that reason no longer applies. That text is intentional and stays.

## What Changes

- `asciidoc-inbuffer-preview`'s "Markdown workflow untouched" scenario stops naming `glow.nvim` and refers to the current markdown preview stack instead — `markdown-preview.nvim` in a GUI, and the in-editor popup (`:MarkdownPopup`, `<localleader>p`/`pp`) elsewhere.
- The same scenario stops saying "exactly as before this change". That phrasing referred to the change that introduced the requirement; once promoted and archived it has no referent, so it is replaced with a statement of the behaviour itself.
- `ide-layout`'s "Floating UIs unaffected" requirement replaces "Glow previews" with the markdown popup float in both the requirement text and its scenario.
- No runtime behaviour changes. This is spec text only.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `asciidoc-inbuffer-preview`: the *In-buffer preview coexists with the Docker preview and the Markdown workflow* requirement names a plugin that no longer exists, making one of its scenarios unsatisfiable.
- `ide-layout`: the *Floating UIs unaffected* requirement, and its scenario, are written around a float that can no longer be triggered.

## Impact

**Specs only.** No Lua, no documentation, no keymaps, no plugin changes.

**Not a runtime change**, so no `TEST_PLAN.md` section and no live validation walk. Verification is `openspec validate --all --strict`, plus confirming no live spec still references glow except the deliberate history in `code-folding`.

**Risk**: minimal, and confined to wording. The one judgement call is whether `ide-layout`'s float list should name the markdown popup specifically or be generalised — naming it keeps the requirement concrete and testable, at the cost of needing another edit if that float is ever replaced in turn. Given this change exists precisely because a named float was replaced, that trade-off deserves stating rather than assuming.
