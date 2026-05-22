## 1. Remove conversion pipeline

- [x] 1.1 Delete `scripts/convert-docs.sh` (`git rm scripts/convert-docs.sh`)
- [x] 1.2 Remove pandoc install step and conversion step from `.github/workflows/docs.yml`; retain only the Antora build and gh-pages deploy steps
- [x] 1.3 Delete the entire `documentation/` folder (`git rm -r documentation/`)

## 2. Simplify README

- [x] 2.1 Rewrite `README.md` to contain only: repo name, one-line description, quick install (`git clone`), Neovim ≥ 0.12 requirement, and a prominent link to the hosted docs site
- [x] 2.2 Remove all detailed sections from README (plugin overview, keybinding tables, language guides, LSP table, terminal auto-detection table, Docker services, etc.)

## 3. Create getting-started guide

- [x] 3.1 Create `docs/modules/ROOT/pages/guides/getting-started.adoc` with: Neovim install (AppImage + tarball methods), Docker Engine / Docker Compose install + `docker compose version` verification, shared system deps (git, curl, unzip), first-run steps after cloning the config
- [x] 3.2 Apply the guide template: Quick Start first, jump menu, setup sections (Troubleshooting → Setup → Prerequisites) at the bottom

## 4. Distribute cli-console-mode sections

- [x] 4.1 Merge "Console Detection" + `is_console` flag table + "Open URL Behaviour" sections into `docs/modules/ROOT/pages/guides/architecture.adoc`
- [x] 4.2 Merge "Markdown Preview — Glow" section (install, usage, keymaps, popup close) into `docs/modules/ROOT/pages/guides/markdown.adoc`
- [x] 4.3 Merge "PlantUML ASCII Preview" section into `docs/modules/ROOT/pages/guides/diagrams.adoc`
- [x] 4.4 Merge "AI Research — Avante" section (both ollama and copilot backends, GPU opt-in, keymaps) into `docs/modules/ROOT/pages/guides/ai-tools.adoc`
- [x] 4.5 Delete `docs/modules/ROOT/pages/guides/cli-console-mode.adoc` (`git rm`)

## 5. Merge .NET (dotnet + fsharp)

- [x] 5.1 Rewrite `docs/modules/ROOT/pages/guides/dotnet.adoc` as a unified `.NET (C# and F#)` guide: shared .NET SDK section (moved from fsharp guide), then parallel `== C# — Roslyn` and `== F# — fsautocomplete` sections each covering LSP, REPL, Formatting; combined Typical Workflow
- [x] 5.2 Replace the Neovim version requirement and AppImage/tarball install sections in dotnet guide with a cross-reference to `getting-started.adoc`
- [x] 5.3 Delete `docs/modules/ROOT/pages/guides/fsharp.adoc` (`git rm`)
- [x] 5.4 Rewrite `docs/modules/ROOT/pages/cheatsheets/dotnet.adoc`: collapse the two identical REPL tables into one table with a note "REPL backend: csharprepl (C#) / dotnet fsi (F#)"; add fsautocomplete LSP row; remove fsharp cheatsheet cross-reference
- [x] 5.5 Delete `docs/modules/ROOT/pages/cheatsheets/fsharp.adoc` (`git rm`)

## 6. Merge cheatsheets

- [x] 6.1 Merge `comments.adoc` and `surround.adoc` into `editing.adoc`; add a `== Commenting (vim-commentary)` section and a `== Surround (vim-surround)` section; delete merged files (`git rm`)
- [x] 6.2 Merge `fzf.adoc`, `file-tree.adoc`, and `unimpaired.adoc` into `navigation.adoc`; add `== Fuzzy Finder (fzf-lua)`, `== File Tree (nvim-tree)`, and `== Unimpaired` sections; delete merged files (`git rm`)
- [x] 6.3 Create `docs/modules/ROOT/pages/cheatsheets/code-intelligence.adoc` combining the full content of `lsp.adoc`, `completion.adoc`, and `formatting.adoc` under sections `== LSP`, `== Auto-Completion`, `== Formatting`; delete the three source files (`git rm`)
- [x] 6.4 Merge `copilot.adoc` cheatsheet content into `ai-tools.adoc` cheatsheet under a `== Copilot` section; delete `copilot.adoc` (`git rm`)
- [x] 6.5 Merge `plantuml.adoc` and `html.adoc` cheatsheet content into `markdown.adoc` cheatsheet under `== PlantUML` and `== HTML Preview (Bracey)` sections; delete merged files (`git rm`)

## 7. New git guide

- [x] 7.1 Create `docs/modules/ROOT/pages/guides/git.adoc`: overview of fugitive + gitsigns + diffview as a workflow trio; sections for common scenarios (reviewing changes with gitsigns, staging hunks, committing with fugitive, resolving conflicts with diffview, reading file history); apply guide template

## 8. Remove validation page

- [x] 8.1 Delete `docs/modules/ROOT/pages/guides/validation.adoc` (`git rm`)

## 9. Apply guide template to all remaining guides

Apply to each guide: dynamic jump menu below title, Quick Start as first body section, capability sections in logical order, Typical Workflow before separator, then Troubleshooting → Setup → Prerequisites at bottom. Remove sentinel comment headers.

- [x] 9.1 `architecture.adoc` (includes new console-detection content from task 4.1)
- [x] 9.2 `ai-tools.adoc` (includes new Avante content from task 4.4)
- [x] 9.3 `clipboard.adoc` — add cross-reference to `getting-started.adoc` for Neovim prereqs
- [x] 9.4 `confluence.adoc`
- [x] 9.5 `diagrams.adoc` (includes new PlantUML ASCII content from task 4.3)
- [x] 9.6 `dotnet.adoc` (unified .NET guide from task 5.1 — apply template as part of that rewrite)
- [x] 9.7 `haskell.adoc`
- [x] 9.8 `janet.adoc`
- [x] 9.9 `jira.adoc`
- [x] 9.10 `lisp.adoc`
- [x] 9.11 `markdown.adoc` (includes new Glow content from task 4.2)
- [x] 9.12 `presentations.adoc`
- [x] 9.13 `rest.adoc`

## 10. Update nav.adoc

- [x] 10.1 Rewrite `docs/modules/ROOT/nav.adoc` with these topic groups and co-located guide+cheatsheet pairs:
  - **Languages**: .NET Ecosystem (dotnet guide + cheatsheet), Lisp Family (lisp + janet guides + cheatsheets), Haskell
  - **Editor Core**: Editing cheatsheet, Navigation cheatsheet, Code Intelligence cheatsheet, Git (guide + cheatsheet)
  - **AI & Automation**: AI Tools guide + cheatsheet
  - **Content Creation**: Markdown guide + cheatsheet, Diagrams guide, Presentations guide, REST guide + cheatsheet
  - **Project Tooling**: Jira guide, Confluence guide
  - **Reference**: Getting Started guide, Architecture guide, Clipboard guide
- [x] 10.2 Verify every xref in nav.adoc resolves to an existing file; no entries for deleted pages

## 11. Update cheatsheet index

- [x] 11.1 Update `docs/modules/ROOT/pages/cheatsheets/index.adoc`: remove rows for deleted cheatsheets (comments, surround, fzf, file-tree, unimpaired, lsp, completion, formatting, copilot, plantuml, html, fsharp); add row for `code-intelligence.adoc`; update merged cheatsheet entries (editing, navigation, ai-tools, markdown, dotnet) to reflect their expanded coverage

## 12. Validate

- [ ] 12.1 Run Antora build locally and confirm zero broken xrefs and no missing pages
- [x] 12.2 Confirm `documentation/` folder is fully removed and no stale references to it remain in CI or scripts
- [x] 12.3 Verify `README.md` link to the hosted docs site resolves correctly
- [x] 12.4 Run `find . -name '*.lua' -not -path '*/lazy/*' -print0 | xargs -0 luac -p` to confirm no Lua regressions
