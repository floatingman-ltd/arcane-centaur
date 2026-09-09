## Why

F# has no indentation support of any kind. Pressing Enter after a line ending in `=` or `->` copies the previous line's indent rather than indenting the body, and `>>`, `<<` and `=` are useless as reindent operators. `install-language-servers` measured the gap under `LS.7` and deliberately left it, recording in `openspec/specs/fsharp-lsp/spec.md` that it "SHALL remain recorded until addressed by a dedicated change". This is that change.

The gap exists because none of the mechanisms that serve every other language here can serve F#. There is no `indents.scm` for F# upstream — no `queries/fsharp` directory exists in nvim-treesitter at all, on `main` or `master` — so the treesitter path that gives Lua and markdown their indentation is unavailable. LSP has no indent-as-you-type concept, so `fsautocomplete` cannot help despite supplying folds and formatting. And `smartindent` keys off `{`, `}` and `cinwords`, none of which F# uses. A hand-written `indentexpr` is the only remaining mechanism.

Exactly one exists and is maintained: `indent/fsharp.vim` from `ionide/Ionide-vim`, rewritten in April 2026 from `PhilT/vim-fsharp`. Measured against this configuration's own constructs it takes indentation from 2 of 5 cases correct to 5 of 5.

## What Changes

- Vendor `indent/fsharp.vim` (283 lines, MIT) into the configuration at `indent/fsharp.vim`, verbatim apart from an added provenance header. Neovim's runtime loads `indent/<ft>.vim` on `FileType` and ships no F# indent file, so the file needs no registration.
- **Do not install Ionide-vim.** Of its functional code this configuration needs only that one file; everything else it ships duplicates something already working here, and three of those duplicates would override validated behaviour. See the design for the full accounting.
- **Set `commentstring` and `comments` for F#.** Found by this change's own validation: Neovim ships no `ftplugin` for F#, so `commentstring` was empty and `gcc` failed with *comment string is empty* — native commenting has never worked in an F# buffer here. Measured as `[]` on `main` as well, so it is pre-existing rather than caused by this change. Included because it is the same class of gap as indentation, editor-side behaviour no language server supplies.
- Update the F# language documentation and cheatsheet, which currently state that indentation does not work.
- Add a `## Change · add-fsharp-indent` section to `openspec/TEST_PLAN.md`.

Not a breaking change in the sense of removing anything, but it does change editing behaviour in every F# buffer, so it is the kind of change whose effect is felt on every keystroke rather than on demand.

## Capabilities

### New Capabilities

- `fsharp-indent`: F# indentation as its own capability. It is deliberately not folded into `fsharp-lsp`: indentation is not a language-server concern, it is served by a vendored Vimscript `indentexpr` with no dependency on `fsautocomplete`, and it must keep working when the server is absent or cannot resolve project options.

### Modified Capabilities

- `fsharp-lsp`: its requirement *"F# indentation remains unsupported"* becomes false and is removed, pointing at `fsharp-indent` in its place. That requirement exists specifically to stop the gap being misread as a regression, and it explicitly anticipated being retired by a dedicated change.

## Impact

- New file `indent/fsharp.vim`; new directory `indent/`, which this configuration does not currently have.
- No plugin, no `lazy.nvim` spec, no `lazy-lock.json` entry, no new binary. Nothing to install and nothing to keep in step at runtime.
- Affects every F# buffer's `indentexpr` and `indentkeys`. `after/ftplugin/fsharp.lua` keeps its `tabstop`/`shiftwidth` of 4 and is unaffected, and the treesitter indent guard in `lua/plugins/treesitter.lua` already excludes F# for want of an `indents.scm`, so nothing competes for `indentexpr`.
- Accepts a maintenance obligation: upstream fixes arrive only when pulled by hand. The file has changed three times since 2016, so the expected cost is close to zero, and the header records the upstream path so a refresh is mechanical.
- `openspec/specs/fsharp-lsp/spec.md` loses one requirement; `LS.7` in the archived `install-language-servers` test plan asserts the gap exists and is superseded rather than edited, since archived plans are a historical record.
